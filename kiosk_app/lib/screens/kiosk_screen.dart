import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import '../core/image_converter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../main.dart';
import '../core/constants.dart';
import '../data/api_client.dart';
import '../services/heartbeat_service.dart';
import 'login_screen.dart';

enum KioskState {
  detection,
  recognizing,
  checkinSuccess,
  checkoutMode,
  checkoutSuccess,
  interactiveMode,
  error,
}

class KioskScreen extends StatefulWidget {
  const KioskScreen({super.key});

  @override
  State<KioskScreen> createState() => _KioskScreenState();
}

class _KioskScreenState extends State<KioskScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  final ApiClient _apiClient = ApiClient();
  HeartbeatService? _heartbeatService;

  KioskState _state = KioskState.detection;
  String _statusText = 'Scanning for faces...';
  String _employeeName = '';
  String _kioskId = '';

  Timer? _returnTimer;
  bool _isProcessing = false;

  // MLKit Face Detection

  // Interactive mode state
  String? _interactiveEmployeeId;
  String? _interactiveName;
  bool _interactiveHasActiveSession = false;
  bool _interactiveHasCheckedOutToday = false;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableTracking: false,
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  Face? _detectedFace;
  Size? _imageSize;
  InputImageRotation? _imageRotation;
  Color _boxColor = Colors.white;
  String? _recognizedText;

  // Cooldown tracking: employee_id -> last recognition time
  final Map<String, DateTime> _cooldownMap = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kiosk_token') ?? '';
    _kioskId = prefs.getString('kiosk_id') ?? '';

    // Auto-recover kiosk_id from token if they haven't logged out since the update
    if (_kioskId.isEmpty && token.isNotEmpty) {
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload =
              utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
          final Map<String, dynamic> data = json.decode(payload);
          _kioskId = data['sub'] ?? '';
          if (_kioskId.isNotEmpty) {
            await prefs.setString('kiosk_id', _kioskId);
          }
        }
      } catch (_) {}
    }

    // Final fallback to a valid UUID to prevent 500/422 DB crashes
    if (_kioskId == 'default-kiosk' || _kioskId.isEmpty) {
      _kioskId = '00000000-0000-0000-0000-000000000000';
    }

    _apiClient.setToken(token);

    _heartbeatService = HeartbeatService(
      apiClient: _apiClient,
      kioskId: _kioskId,
    );
    _heartbeatService?.start();

    await _initCamera();
    _startDetection();
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) {
      setState(() {
        _state = KioskState.error;
        _statusText = 'No camera available';
      });
      return;
    }

    // Use front camera
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('[Camera] Init error: $e');
      setState(() {
        _state = KioskState.error;
        _statusText = 'Camera initialization failed';
      });
    }
  }

  void _startDetection() {
    if (_cameraController?.value.isStreamingImages == true) return;
    _cameraController?.startImageStream((CameraImage image) {
      if (!_isProcessing) {
        _processCameraImage(image);
      }
    });
  }

  void _stopDetection() {
    if (_cameraController?.value.isStreamingImages == true) {
      _cameraController?.stopImageStream();
    }
  }

  bool _isUploading = false;
  bool _faceInViewRecognized = false;

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessing) return;
    if (_state != KioskState.detection && 
        _state != KioskState.checkoutMode && 
        _state != KioskState.recognizing) {
      return;
    }

    _isProcessing = true;

    try {
      final Size imageSize =
          Size(image.width.toDouble(), image.height.toDouble());
      final InputImageRotation imageRotation =
          InputImageRotationValue.fromRawValue(
                  _cameraController!.description.sensorOrientation) ??
              InputImageRotation.rotation0deg;

      final InputImageFormat inputImageFormat =
          InputImageFormatValue.fromRawValue(image.format.raw) ??
              InputImageFormat.nv21;

      final metadata = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      Uint8List imageBytes;
      if (image.planes.length == 1) {
        imageBytes = image.planes[0].bytes;
      } else {
        final WriteBuffer allBytes = WriteBuffer();
        for (final Plane plane in image.planes) {
          allBytes.putUint8List(plane.bytes);
        }
        imageBytes = allBytes.done().buffer.asUint8List();
      }

      final inputImage = InputImage.fromBytes(bytes: imageBytes, metadata: metadata);
      final List<Face> faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        if (mounted) {
          setState(() {
            _detectedFace = null;
            _recognizedText = null;
            _faceInViewRecognized = false;
            
            // Instantly abort recognition UI and go back to scanning
            _state = _state == KioskState.checkoutMode
                ? KioskState.checkoutMode
                : KioskState.detection;
            if (_state != KioskState.checkoutMode) {
              _statusText = 'Scanning for faces...';
            }
          });
        }
        
        // If we were uploading, mark it false so the background result is ignored
        // or a new upload can start immediately if someone else steps in!
        _isUploading = false; 
        _isProcessing = false;
        return;
      }

      final face = faces.first;
      
      if (mounted) {
        setState(() {
          _detectedFace = face;
          
          bool shouldSwap = Platform.isAndroid && 
                            (imageRotation == InputImageRotation.rotation90deg ||
                             imageRotation == InputImageRotation.rotation270deg);
          
          _imageSize = Size(
            shouldSwap ? imageSize.height : imageSize.width,
            shouldSwap ? imageSize.width : imageSize.height,
          );
          
          _imageRotation = imageRotation;
          
          if (!_isUploading && !_faceInViewRecognized) {
            _boxColor = Colors.transparent;
            _recognizedText = null;
          }
        });
      }

      // Only start a new upload if we aren't currently uploading AND we haven't already recognized this face
      if (!_isUploading && !_faceInViewRecognized) {
        _isUploading = true;
        
        // Deep copy the planes to release the camera buffer immediately!
        final List<Uint8List> copiedPlanes = image.planes.map((p) => Uint8List.fromList(p.bytes)).toList();
        final List<int> bytesPerRow = image.planes.map((p) => p.bytesPerRow).toList();
        final List<int?> bytesPerPixel = image.planes.map((p) => p.bytesPerPixel).toList();

        _uploadFaceInBackground(
            copiedPlanes, bytesPerRow, bytesPerPixel, 
            image.width, image.height, image.format.group, 
            face, imageSize, imageRotation);
      }
    } catch (e) {
      debugPrint('[MLKit] Error processing frame: $e');
    } finally {
      _isProcessing = false;
    }
  }
  

  Future<void> _uploadFaceInBackground(
      List<Uint8List> planes, List<int> bytesPerRow, List<int?> bytesPerPixel,
      int width, int height, ImageFormatGroup formatGroup,
      Face face, Size imageSize, InputImageRotation imageRotation) async {
    try {
      if (mounted) {
        setState(() {
          _state = _state == KioskState.checkoutMode
              ? KioskState.checkoutMode
              : KioskState.recognizing;
          if (_state != KioskState.checkoutMode) {
            _statusText = 'Recognizing face...';
          }
        });
      }

      final Uint8List? imageBytes = await convertCameraImageToJpeg(
        planes, bytesPerRow, bytesPerPixel, width, height, formatGroup, imageRotation
      );
      
      if (imageBytes == null) {
        throw Exception("Failed to encode image");
      }

      final result = await _apiClient.recognize(
        kioskId: _kioskId,
        imageBytes: imageBytes,
        filename: 'capture_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // If the face disappeared while we were uploading, abort processing the result!
      if (!mounted || _detectedFace == null) {
        return;
      }

      final String? detail = result['detail']?.toString();

      if (detail != null && detail.contains('FACE_001')) {
        if (mounted) {
          setState(() {
            _detectedFace = null;
            _state = _state == KioskState.checkoutMode
                ? KioskState.checkoutMode
                : KioskState.detection;
            if (_state != KioskState.checkoutMode) {
              _statusText = 'Scanning for faces...';
            }
          });
        }
        _startDetection();
        _isUploading = false;
        _isProcessing = false;
        return;
      }

      final bool recognized = result['recognized'] == true;
      final String? employeeId = result['employee_id']?.toString();
      final String? name = result['employee_name']?.toString();
      final bool hasActiveSession = result['has_active_session'] == true;
      final bool hasCheckedOutToday = result['has_checked_out_today'] == true;

      if (recognized && employeeId != null) {
        if (mounted) {
          setState(() {
            _boxColor = Colors.green;
            _recognizedText = name ?? 'Employee';
            _faceInViewRecognized = true;
          });
        }

        final isCheckout = _state == KioskState.checkoutMode;

        if (_isInCooldown(employeeId)) {
          if (mounted) {
            setState(() {
              _statusText = isCheckout
                  ? 'Already checked out.'
                  : 'Welcome back! Please wait a minute.';
            });
          }
          _scheduleReturnToDetection();
          _isUploading = false;
          _isProcessing = false;
          return;
        }

        _updateCooldown(employeeId);

        if (hasActiveSession) {
          if (isCheckout) {
            await _performCheckout(employeeId, name ?? 'Employee');
          } else {
            // Already checked in. Recognition is already logged by backend.
            if (mounted) {
              setState(() {
                _statusText = 'Face detected and logged for ${name ?? 'Employee'}';
              });
            }
            _scheduleReturnToDetection();
          }
        } else {
          // No active session!
          if (hasCheckedOutToday) {
            // Already checked out today. Show prompt to check in again, regardless of mode.
            if (mounted) {
              setState(() {
                _state = KioskState.interactiveMode;
                _interactiveEmployeeId = employeeId;
                _interactiveName = name ?? 'Employee';
                _interactiveHasActiveSession = false;
                _interactiveHasCheckedOutToday = true;
              });
            }
            _scheduleReturnToDetection(customSeconds: 15);
          } else {
            if (isCheckout) {
              await _performCheckout(employeeId, name ?? 'Employee');
            } else {
              await _performCheckin(employeeId, name ?? 'Employee');
            }
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _boxColor = Colors.red;
            _recognizedText = 'Not Recognized';
            _state = KioskState.error;
            _statusText = 'Face not recognized. Please try again.';
          });
        }
        _scheduleQuickReturn();
      }
    } on DioException catch (e) {
      final detail = e.response?.data is Map
          ? e.response?.data['detail']?.toString()
          : null;
      if (detail != null && detail.contains('FACE_001')) {
        if (mounted) setState(() => _detectedFace = null);
        _startDetection();
      } else {
        if (mounted) {
          setState(() {
            _boxColor = Colors.red;
            _recognizedText = 'Error';
            _state = KioskState.error;
            _statusText = 'Network Error. Please try again.';
          });
        }
        _scheduleQuickReturn();
      }
    } catch (e) {
      if (e.toString().contains('FACE_001')) {
        if (mounted) setState(() => _detectedFace = null);
        _startDetection();
      } else {
        if (mounted) {
          setState(() {
            _boxColor = Colors.red;
            _recognizedText = 'Error';
            _state = KioskState.error;
            _statusText = 'Recognition error. Retrying...';
          });
        }
        _scheduleQuickReturn();
      }
    } finally {
      _isUploading = false;
      _isProcessing = false;
    }
  }

  void _scheduleQuickReturn() {
    _returnTimer?.cancel();
    _returnTimer = Timer(
      const Duration(seconds: 1), // Only wait 1 second on errors
      () {
        if (mounted) {
          setState(() {
            _state = KioskState.detection;
            _statusText = 'Scanning for faces...';
            _employeeName = '';
            _detectedFace = null;
            _recognizedText = null;
            _faceInViewRecognized = false;
          });
          _startDetection();
        }
      },
    );
  }


  bool _isInCooldown(String employeeId) {
    final lastSeen = _cooldownMap[employeeId];
    if (lastSeen == null) return false;
    return DateTime.now().difference(lastSeen).inSeconds <
        AppConstants.cooldownSeconds;
  }

  void _updateCooldown(String employeeId) {
    _cooldownMap[employeeId] = DateTime.now();
  }

  String _getGreetingMessage(String name) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning, $name!';
    } else if (hour < 17) {
      return 'Good afternoon, $name!';
    } else {
      return 'Good evening, $name!';
    }
  }



  Future<void> _performCheckin(String employeeId, String name) async {
    try {
      await _apiClient.checkIn(
        employeeId: employeeId,
        kioskId: _kioskId,
      );

      setState(() {
        _state = KioskState.checkinSuccess;
        _employeeName = name;
        _statusText = 'Check-In successful!';
      });
    } catch (e) {
      setState(() {
        _state = KioskState.error;
        _statusText = 'Check-In failed.';
      });
    }

    _scheduleReturnToDetection();
  }

  Future<void> _performCheckout(String employeeId, String name) async {
    try {
      await _apiClient.checkOut(employeeId: employeeId);

      setState(() {
        _state = KioskState.checkoutSuccess;
        _employeeName = name;
        _statusText = 'Check-Out successful!';
      });
    } catch (e) {
      setState(() {
        _state = KioskState.error;
        _statusText = 'Check-Out failed. No active session found.';
      });
    }

    _scheduleReturnToDetection();
  }

  void _scheduleReturnToDetection({int? customSeconds}) {
    _returnTimer?.cancel();
    _returnTimer = Timer(
      Duration(seconds: customSeconds ?? AppConstants.returnToScanSeconds),
      () {
        if (mounted) {
          setState(() {
            _state = KioskState.detection;
            _statusText = 'Scanning for faces...';
            _employeeName = '';
            _detectedFace = null;
            _recognizedText = null;
            _faceInViewRecognized = false;
          });
          _startDetection();
        }
      },
    );
  }

  void _closeOverlay() {
    _returnTimer?.cancel();
    if (mounted) {
      setState(() {
        _state = KioskState.detection;
        _statusText = 'Scanning for faces...';
        _employeeName = '';
        _detectedFace = null;
        _recognizedText = null;
        _faceInViewRecognized = false;
      });
      _startDetection();
    }
  }

  Timer? _checkoutTimer;
  int _checkoutCountdown = 15;

  void _startCheckoutTimer() {
    _checkoutCountdown = 15;
    _checkoutTimer?.cancel();
    _checkoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_checkoutCountdown > 0) {
          _checkoutCountdown--;
          _statusText =
              'Checkout mode: Show your face to check out ($_checkoutCountdown s)';
        } else {
          _cancelCheckoutTimer();
          _state = KioskState.detection;
          _statusText = 'Scanning for faces...';
          _detectedFace = null;
        }
      });
    });
  }

  void _cancelCheckoutTimer() {
    _checkoutTimer?.cancel();
    _checkoutTimer = null;
  }

  void _toggleCheckoutMode() {
    setState(() {
      _detectedFace = null;
      _recognizedText = null;
      _faceInViewRecognized = false;
      _isUploading = false;

      if (_state == KioskState.checkoutMode) {
        _cancelCheckoutTimer();
        _state = KioskState.detection;
        _statusText = 'Scanning for faces...';
      } else {
        _state = KioskState.checkoutMode;
        _statusText = 'Checkout mode: Show your face to check out (15 s)';
        _startCheckoutTimer();
      }
    });
  }

  Future<void> _logout() async {
    _stopDetection();
    _heartbeatService?.stop();
    _returnTimer?.cancel();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('kiosk_logged_in', false);
    await prefs.remove('kiosk_token');

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopDetection();
    _heartbeatService?.stop();
    _returnTimer?.cancel();
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _stopDetection();
    } else if (state == AppLifecycleState.resumed) {
      _startDetection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Preview
            if (_cameraController != null &&
                _cameraController!.value.isInitialized)
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _cameraController!.value.previewSize!.height < _cameraController!.value.previewSize!.width
                        ? _cameraController!.value.previewSize!.height
                        : _cameraController!.value.previewSize!.width,
                    height: _cameraController!.value.previewSize!.width > _cameraController!.value.previewSize!.height
                        ? _cameraController!.value.previewSize!.width
                        : _cameraController!.value.previewSize!.height,
                    child: CustomPaint(
                      foregroundPainter:
                          (_detectedFace != null && _imageSize != null)
                              ? FacePainter(
                                  face: _detectedFace!,
                                  imageSize: _imageSize!,
                                  rotation: _imageRotation ??
                                      InputImageRotation.rotation270deg,
                                  color: _boxColor,
                                  text: _recognizedText,
                                )
                              : null,
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
                ),
              ),

            // Overlay gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.0, 0.2, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            // Top bar
            Positioned(
              top: 16.h,
              left: 16.w,
              right: 16.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: _getStateColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: _getStateColor().withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8.r,
                          height: 8.r,
                          decoration: BoxDecoration(
                            color: _getStateColor(),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          _getStateLabel(),
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings,
                        color: Colors.white54, size: 24.sp),
                    onPressed: () => _showSettingsDialog(),
                  ),
                ],
              ),
            ),

            if (_state == KioskState.checkinSuccess)
              Positioned.fill(child: _buildWelcomeScreen()),

            if (_state == KioskState.checkoutSuccess)
              Positioned.fill(child: _buildCheckoutScreen()),

            if (_state == KioskState.interactiveMode)
              Positioned.fill(child: _buildInteractiveScreen()),

            // Bottom bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _statusText,
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 14.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButton(
                          label: _state == KioskState.checkoutMode
                              ? 'Cancel Checkout'
                              : 'Checkout',
                          icon: _state == KioskState.checkoutMode
                              ? Icons.close
                              : Icons.logout,
                          color: _state == KioskState.checkoutMode
                              ? Colors.grey
                              : Colors.orangeAccent,
                          onPressed: _toggleCheckoutMode,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18.sp),
      label: Text(
        label,
        style:
            GoogleFonts.outfit(fontSize: 13.sp, fontWeight: FontWeight.w500),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(color: color.withOpacity(0.4)),
        ),
        elevation: 0,
      ),
    );
  }

  Color _getStateColor() {
    switch (_state) {
      case KioskState.detection:
        return const Color(0xFF10B981);
      case KioskState.recognizing:
        return const Color(0xFF6366F1);
      case KioskState.checkinSuccess:
        return const Color(0xFF10B981);
      case KioskState.checkoutMode:
        return Colors.orangeAccent;
      case KioskState.checkoutSuccess:
        return const Color(0xFF6366F1);
      case KioskState.interactiveMode:
        return Colors.blueAccent;
      case KioskState.error:
        return Colors.red;
    }
  }

  String _getStateLabel() {
    switch (_state) {
      case KioskState.detection:
        return 'Detection Mode';
      case KioskState.recognizing:
        return 'Recognizing';
      case KioskState.checkinSuccess:
        return 'Check-In';
      case KioskState.checkoutMode:
        return 'Checkout Mode';
      case KioskState.checkoutSuccess:
        return 'Check-Out';
      case KioskState.interactiveMode:
        return 'User Selection';
      case KioskState.error:
        return 'Error';
    }
  }

  Future<void> _showAdminPinDialog() async {
    String pin = '';
    final bool? result = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            title: const Text('Admin Access',
                style: TextStyle(color: Colors.white)),
            content: TextField(
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Enter Admin PIN',
                hintStyle: TextStyle(color: Colors.white54),
              ),
              onChanged: (value) => pin = value,
              onSubmitted: (value) {
                Navigator.pop(context, pin == '1234');
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, pin == '1234'),
                child: const Text('Submit'),
              ),
            ],
          );
        });

    if (result == true) {
      _logout();
    } else if (result == false) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect PIN')),
        );
      }
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Kiosk Settings',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _settingsRow('App', AppConstants.appName),
            _settingsRow('Version', AppConstants.appVersion),
            _settingsRow(
                'Kiosk ID',
                _kioskId.length > 8
                    ? '${_kioskId.substring(0, 8)}...'
                    : _kioskId),
            _settingsRow('Backend', ApiConstants.baseUrl),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showAdminPinDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.2),
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Logout',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13.sp),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildWelcomeScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A2E).withOpacity(0.95),
            const Color(0xFF16213E).withOpacity(0.95),
            const Color(0xFF0F3460).withOpacity(0.95),
          ],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16.h,
              left: 16.w,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 28.sp),
                onPressed: _closeOverlay,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                    width: 140.w,
                    height: 140.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF81C784)]),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _employeeName.isNotEmpty
                            ? _employeeName[0].toUpperCase()
                            : 'E',
                        style: GoogleFonts.outfit(
                            fontSize: 56.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 36.h),
                  Text(
                    'Hey $_employeeName!',
                    style: GoogleFonts.outfit(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    '${_getGreeting()}! Welcome to the office.',
                    style: GoogleFonts.outfit(
                        fontSize: 17.sp,
                        color: Colors.white70,
                        height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Hope you have a fantastic day!',
                    style:
                        GoogleFonts.outfit(fontSize: 16.sp, color: Colors.white54),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 48.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, color: Colors.white60, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Checked In at ${TimeOfDay.now().format(context)}',
                          style: GoogleFonts.outfit(
                              fontSize: 14.sp, color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveScreen() {
    return Container(
      color: const Color(0xFF1A1A2E).withOpacity(0.95),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.white12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.touch_app_rounded,
                    color: Colors.blue, size: 48.sp),
              ),
              SizedBox(height: 24.h),
              Text(
                _interactiveName != null
                    ? _getGreetingMessage(_interactiveName!)
                    : 'Welcome!',
                style: GoogleFonts.outfit(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                _interactiveHasCheckedOutToday
                    ? 'You have already checked out today. Do you want to check in again?'
                    : 'Welcome! What would you like to do?',
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_interactiveHasActiveSession) ...[
                    _buildInteractiveButton(
                      'Check Out',
                      Icons.logout_rounded,
                      Colors.red,
                      () {
                        if (_interactiveEmployeeId != null &&
                            _interactiveName != null) {
                          _performCheckout(
                              _interactiveEmployeeId!, _interactiveName!);
                        }
                      },
                    ),
                    SizedBox(height: 16.h),
                  ],
                  _buildInteractiveButton(
                    _interactiveHasCheckedOutToday
                        ? 'Check In Again'
                        : 'Check In',
                    Icons.login_rounded,
                    Colors.green,
                    () {
                      if (_interactiveEmployeeId != null &&
                          _interactiveName != null) {
                        _performCheckin(
                            _interactiveEmployeeId!, _interactiveName!);
                      }
                    },
                  ),
                  SizedBox(height: 16.h),
                  _buildInteractiveButton(
                    'No Thanks',
                    Icons.close_rounded,
                    Colors.grey,
                    () {
                      _closeOverlay();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildInteractiveButton(
      String text, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 240.w,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.15),
          foregroundColor: color,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24.sp),
            SizedBox(width: 12.w),
            Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A1A2E).withOpacity(0.95),
            const Color(0xFF1B2838).withOpacity(0.95),
          ],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16.h,
              left: 16.w,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 28.sp),
                onPressed: _closeOverlay,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                    width: 140.w,
                    height: 140.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                          colors: [Color(0xFFFF9800), Color(0xFFFFCC80)]),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF9800).withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _employeeName.isNotEmpty
                            ? _employeeName[0].toUpperCase()
                            : 'E',
                        style: GoogleFonts.outfit(
                            fontSize: 56.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 36.h),
                  Text(
                    'Hey $_employeeName!',
                    style: GoogleFonts.outfit(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'You have successfully checked out today.',
                    style: GoogleFonts.outfit(
                        fontSize: 17.sp, color: Colors.white70, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Have a great evening!',
                    style:
                        GoogleFonts.outfit(fontSize: 16.sp, color: Colors.white54),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 48.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, color: Colors.white60, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Checked Out at ${TimeOfDay.now().format(context)}',
                          style: GoogleFonts.outfit(
                              fontSize: 14.sp, color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FacePainter extends CustomPainter {
  final Face face;
  final Size imageSize;
  final InputImageRotation rotation;
  final Color color;
  final String? text;

  FacePainter({
    required this.face,
    required this.imageSize,
    required this.rotation,
    required this.color,
    this.text,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = color;

    double scaleX = size.width / imageSize.width;
    double scaleY = size.height / imageSize.height;

    // Mirror horizontal for front camera
    final left = size.width - (face.boundingBox.right * scaleX);
    final right = size.width - (face.boundingBox.left * scaleX);
    final top = face.boundingBox.top * scaleY;
    final bottom = face.boundingBox.bottom * scaleY;

    final double width = right - left;
    final double height = bottom - top;

    // Use exact height to perfectly fit forehead to chin, and reduce width for a vertical rectangle
    final double adjustedWidth = width * 0.75;
    final double adjustedHeight = height;

    final double centerX = left + width / 2;
    final double centerY = top + height / 2;

    final double adjustedLeft = centerX - adjustedWidth / 2;
    final double adjustedRight = centerX + adjustedWidth / 2;
    final double adjustedTop = centerY - adjustedHeight / 2;
    final double adjustedBottom = centerY + adjustedHeight / 2;

    final Rect rect = Rect.fromLTRB(adjustedLeft, adjustedTop, adjustedRight, adjustedBottom);
    canvas.drawRect(rect, paint);

    if (text != null && text!.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            backgroundColor: color.withOpacity(0.8),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final bgRect = Rect.fromLTWH(
          adjustedLeft, adjustedBottom + 4, textPainter.width + 16, textPainter.height + 8);
      canvas.drawRect(bgRect, Paint()..color = color.withOpacity(0.9));

      textPainter.paint(canvas, Offset(adjustedLeft + 8, adjustedBottom + 8));
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return oldDelegate.face != face ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.rotation != rotation ||
        oldDelegate.color != color ||
        oldDelegate.text != text;
  }
}
