import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants.dart';
import 'login_screen.dart';
import 'main.dart';

/// API base URL - use your machine's local network IP for physical devices
// const String kApiBaseUrl = 'http://192.168.37.200:8000';

// const String kApiBaseUrl = 'http://127.0.0.1:5000';    // kiosk runs on the same machine as the server, so localhost is fine

/// Possible kiosk states
enum KioskState {
  scanning,
  welcome,
  alreadyIn,
  alreadyOut,
}

/// Represents a detected face with its bounding box info
class DetectedFace {
  final String employeeId;
  final String name;
  final double confidence;
  final Rect headRect;
  final bool matched;
  final String action;
  final String? gender;

  DetectedFace({
    required this.employeeId,
    required this.name,
    required this.confidence,
    required this.headRect,
    required this.matched,
    this.action = '',
    this.gender,
  });
}

class KioskScreen extends StatefulWidget {
  const KioskScreen({super.key});

  @override
  State<KioskScreen> createState() => _KioskScreenState();
}

class _KioskScreenState extends State<KioskScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isDetecting = false;
  bool _isDisposed = false;
  Timer? _detectionTimer;
  Timer? _returnToScanTimer;
  FlutterTts? _tts;

  KioskState _kioskState = KioskState.scanning;
  String _currentUserName = '';
  String _currentEmployeeId = '';
  String? _currentGender;
  bool _currentIsAdmin = false;
  String? _avatarUrl;
  String? _profilePhotoUrl;
  bool _isOnline = true;
  String _statusMessage = 'Initializing camera...';

  final Map<String, DateTime> _cooldownFaces = {};
  final Map<String, String> _avatarCache = {};
  final Map<String, String> _profilePhotoCache = {};
  final Map<String, String?> _genderCache = {};

  List<DetectedFace> _detectedFaces = [];
  double _imgWidth = 1;
  double _imgHeight = 1;

  bool _isTtsSpeaking = false;
  bool _isInitializingCamera = false;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
  ));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _detectionTimer?.cancel();
    _returnToScanTimer?.cancel();
    _cameraController?.dispose();
    _tts?.stop();
    super.dispose();
  }

  Future<FlutterTts> _getTts() async {
    if (_tts != null) return _tts!;
    _tts = FlutterTts();
    if (Platform.isIOS) {
      await _tts!.setSharedInstance(true);
      await _tts!.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.defaultMode,
      );
    }
    await _tts!.setSpeechRate(0.45);
    await _tts!.setVolume(1.0);
    await _tts!.setPitch(1.0);
    return _tts!;
  }

  Future<void> _speakMessage(String message, {bool isMale = true}) async {
    final tts = await _getTts();
    if (Platform.isIOS) {
      if (isMale) {
        await tts.setVoice({'name': 'Aaron', 'locale': 'en-US'});
      } else {
        await tts.setVoice({'name': 'Samantha', 'locale': 'en-US'});
      }
    } else {
      await tts.setLanguage('en-US');
      await _setAndroidVoice(tts, isMale);
    }
    await Future.delayed(const Duration(milliseconds: 100));
    if (_isDisposed) return;
    _isTtsSpeaking = true;
    tts.setCompletionHandler(() {
      _isTtsSpeaking = false;
      // For welcome screen: auto-return to scanning after TTS finishes
      if (mounted && !_isDisposed && _kioskState == KioskState.welcome) {
        _returnToScanTimer?.cancel();
        _returnToScanTimer = Timer(const Duration(seconds: 3), () {
          if (mounted && !_isDisposed && _kioskState == KioskState.welcome) {
            _returnToScanning();
          }
        });
      }
    });
    await tts.speak(message);
  }

  Future<void> _setAndroidVoice(FlutterTts tts, bool isMale) async {
    try {
      final dynamic rawVoices = await tts.getVoices;
      if (rawVoices is! List) {
        await tts.setPitch(isMale ? 0.82 : 1.3);
        return;
      }
      Map<String, String>? best;
      for (final dynamic v in rawVoices) {
        if (v is! Map) continue;
        final String name = v['name']?.toString() ?? '';
        final String locale = v['locale']?.toString() ?? '';
        final String gender = v['gender']?.toString().toLowerCase() ?? '';
        if (!locale.toLowerCase().startsWith('en')) continue;
        final bool genderKnown = gender == 'male' || gender == 'female';
        final bool isVoiceFemale = genderKnown
            ? gender == 'female'
            : name.contains('iof') || name.contains('gba') || name.contains('tpf') || name.contains('-f-') || name.contains('sff') || name.toLowerCase().contains('female');
        final bool isVoiceMale = genderKnown
            ? gender == 'male'
            : name.contains('iom') || name.contains('sfm') || name.contains('tpm') || name.contains('-m-') || name.toLowerCase().contains('male');
        final bool matches = isMale ? isVoiceMale : isVoiceFemale;
        if (matches) {
          best = {'name': name, 'locale': locale};
          if (name.contains('network')) break;
        }
      }
      if (best != null) {
        await tts.setVoice(best);
        await tts.setPitch(1.0);
      } else {
        await tts.setPitch(isMale ? 0.82 : 1.3);
      }
    } catch (_) {
      await tts.setPitch(isMale ? 0.82 : 1.3);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _detectionTimer?.cancel();
      _cameraController?.dispose();
      _cameraController = null;
      if (mounted) setState(() => _isCameraReady = false);
    } else if (state == AppLifecycleState.resumed) {
      if (_cameraController == null || !(_cameraController!.value.isInitialized)) {
        _initCamera();
      }
    }
  }

  Future<void> _initCamera({int retryCount = 0}) async {
    if (_isDisposed || _isInitializingCamera) return;
    _isInitializingCamera = true;
    _detectionTimer?.cancel();
    _isCameraReady = false;

    final oldController = _cameraController;
    _cameraController = null;
    if (oldController != null) {
      try { await oldController.dispose(); } catch (_) {}
    }

    if (retryCount > 0) {
      await Future.delayed(Duration(milliseconds: 500 * retryCount));
    }
    if (_isDisposed) {
      _isInitializingCamera = false;
      return;
    }

    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    final controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    _cameraController = controller;

    try {
      await controller.initialize();
      if (!mounted || _isDisposed) {
        controller.dispose();
        _cameraController = null;
        _isInitializingCamera = false;
        return;
      }
      if (mounted) {
        setState(() {
          _isCameraReady = true;
          _statusMessage = 'Step in front of the camera to check in';
        });
      }
      // Delay detection start to let camera and TTS settle
      Future.delayed(const Duration(seconds: 3), () {
        if (!_isDisposed && mounted) _startDetectionLoop();
      });
    } catch (e) {
      if (!mounted || _isDisposed) {
        _isInitializingCamera = false;
        return;
      }
      if (retryCount < 3) {
        _isInitializingCamera = false;
        await _initCamera(retryCount: retryCount + 1);
        return;
      } else {
        setState(() => _statusMessage = 'Camera error. Restart the app.');
      }
    }
    _isInitializingCamera = false;
  }

  void _startDetectionLoop() {
    _detectionTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      if (!_isDetecting && _kioskState == KioskState.scanning && !_isDisposed && !_isTtsSpeaking) {
        if (!_isOnline) {
          // When offline, do a health check instead of sending frames
          _checkServerHealth();
          return;
        }
        _captureAndDetect();
      }
    });
  }

  Rect _expandToHead(int top, int right, int bottom, int left, double imgW, double imgH) {
    final faceW = (right - left).toDouble();
    final faceH = (bottom - top).toDouble();
    final headTop = (top - faceH * 0.08).clamp(0, imgH);
    final headBottom = (bottom + faceH * 0.02).clamp(0, imgH);
    final headLeft = (left - faceW * 0.03).clamp(0, imgW);
    final headRight = (right + faceW * 0.03).clamp(0, imgW);
    return Rect.fromLTRB(headLeft.toDouble(), headTop.toDouble(), headRight.toDouble(), headBottom.toDouble());
  }

  Future<void> _captureAndDetect() async {
    if (!_isCameraReady || _isDisposed || _cameraController == null) return;
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized || controller.value.isTakingPicture) return;

    _isDetecting = true;
    Uint8List? imageBytes;

    try {
      final XFile imageFile = await controller.takePicture();
      imageBytes = await imageFile.readAsBytes();
    } catch (_) {
      _isDetecting = false;
      return;
    }

    if (_isDisposed || !mounted) {
      _isDetecting = false;
      return;
    }

    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          imageBytes,
          filename: 'frame.jpg',
          contentType: DioMediaType('image', 'jpeg'),
        ),
      });

      final response = await _dio.post('/api/v1/face/detect-and-mark', data: formData);

      if (_isDisposed || !mounted) return;

      if (response.statusCode == 200) {
        final data = response.data;
        final List faces = data['faces'] ?? [];
        final List unmatchedFaces = data['unmatched_faces'] ?? [];

        // --- Client-side validation: reject non-face detections ---
        final List validFaces = [];
        for (final face in faces) {
          final bb = face['bounding_box'];
          final int top = bb['top'] as int;
          final int right = bb['right'] as int;
          final int bottom = bb['bottom'] as int;
          final int left = bb['left'] as int;
          final int bw = right - left;
          final int bh = bottom - top;
          final double aspect = bw / (bh == 0 ? 1 : bh).toDouble();
          final double confidence = (face['confidence'] as num).toDouble();

          // Reject if aspect ratio is too elongated (hands are tall/thin or wide/flat)
          if (aspect < 0.5 || aspect > 2.0) {
            debugPrint('[KIOSK] Rejected non-face aspect ratio: $aspect at ($top,$left)-($bottom,$right)');
            continue;
          }
          // Reject if bounding box is too small (< 40px in either dimension)
          if (bw < 40 || bh < 40) {
            debugPrint('[KIOSK] Rejected too-small detection: ${bw}x$bh');
            continue;
          }
          // Reject low-confidence matches (likely false positives from edge server)
          if (confidence < 0.45) {
            debugPrint('[KIOSK] Rejected low confidence match: $confidence for ${face['name']}');
            continue;
          }
          validFaces.add(face);
        }

        setState(() {
          _isOnline = true;

          final List<DetectedFace> newFaces = [];

          for (final face in validFaces) {
            final bb = face['bounding_box'];
            final imgW = (face['image_width'] ?? 640).toDouble();
            final imgH = (face['image_height'] ?? 480).toDouble();
            _imgWidth = imgW;
            _imgHeight = imgH;

            debugPrint('[FACE_BOX] imgW=$imgW imgH=$imgH bb={top:${bb['top']}, right:${bb['right']}, bottom:${bb['bottom']}, left:${bb['left']}}');

            final headRect = _expandToHead(
              bb['top'] as int, bb['right'] as int,
              bb['bottom'] as int, bb['left'] as int,
              imgW, imgH,
            );

            final logAction = face['log']?['action'] as String? ?? 'detected';

            newFaces.add(DetectedFace(
              employeeId: face['employee_id'] as String,
              name: face['name'] as String,
              confidence: (face['confidence'] as num).toDouble(),
              headRect: headRect,
              matched: true,
              action: logAction,
              gender: face['gender'] as String?,
            ));
          }

          for (final uface in unmatchedFaces) {
            final bb = uface['bounding_box'];
            final int uTop = bb['top'] as int;
            final int uRight = bb['right'] as int;
            final int uBottom = bb['bottom'] as int;
            final int uLeft = bb['left'] as int;
            final int ubw = uRight - uLeft;
            final int ubh = uBottom - uTop;
            final double uAspect = ubw / (ubh == 0 ? 1 : ubh).toDouble();

            // Reject non-face shaped detections
            if (uAspect < 0.5 || uAspect > 2.0 || ubw < 40 || ubh < 40) {
              debugPrint('[KIOSK] Rejected unmatched non-face: aspect=$uAspect size=${ubw}x$ubh');
              continue;
            }

            final imgW = (uface['image_width'] ?? 640).toDouble();
            final imgH = (uface['image_height'] ?? 480).toDouble();
            _imgWidth = imgW;
            _imgHeight = imgH;

            final headRect = _expandToHead(
              uTop, uRight,
              uBottom, uLeft,
              imgW, imgH,
            );

            newFaces.add(DetectedFace(
              employeeId: '',
              name: 'Face not recognized',
              confidence: 0,
              headRect: headRect,
              matched: false,
            ));
          }

          _detectedFaces = newFaces;

          if (validFaces.isEmpty && unmatchedFaces.isEmpty) {
            _detectedFaces = [];
            if (_kioskState != KioskState.scanning) {
              _returnToScanning();
            }
            return;
          }

          // Show "Face not recognized" message if only unmatched faces
          if (validFaces.isEmpty && unmatchedFaces.isNotEmpty) {
            _statusMessage = 'Face not recognized. Please register first.';
            // Auto-clear message after 4 seconds
            Future.delayed(const Duration(seconds: 4), () {
              if (mounted && !_isDisposed && _kioskState == KioskState.scanning) {
                setState(() {
                  _statusMessage = 'Step in front of the camera to check in';
                  _detectedFaces = [];
                });
              }
            });
            return;
          }

          if (validFaces.isNotEmpty) {
            final now = DateTime.now();
            _cooldownFaces.removeWhere((_, t) => now.difference(t).inSeconds >= 30);

            for (final face in validFaces) {
              final logAction = face['log']?['action'] as String? ?? 'detected';
              final name = face['name'] as String;
              final empId = face['employee_id'] as String;
              final gender = face['gender'] as String?;
              final rawAvatarUrl = face['avatar_glb_url'] as String?;
              final rawProfilePhotoUrl = face['profile_photo_url'] as String?;

              final avatarHttpUrl = rawAvatarUrl != null
                  ? (rawAvatarUrl.startsWith('/') ? '${ApiConstants.baseUrl}$rawAvatarUrl' : rawAvatarUrl)
                  : null;

              if (rawProfilePhotoUrl != null && rawProfilePhotoUrl.isNotEmpty) {
                final fullPhotoUrl = rawProfilePhotoUrl.startsWith('/')
                    ? '${ApiConstants.baseUrl}$rawProfilePhotoUrl'
                    : rawProfilePhotoUrl;
                _profilePhotoCache[empId] = fullPhotoUrl;
              }

              if (gender != null) {
                _genderCache[empId] = gender;
              }

              if (_cooldownFaces.containsKey(empId)) continue;

              final cachedDataUri = _avatarCache[empId];

              void setUserAndShow(KioskState state) {
                // Keep scanning state for 1.5s so bounding box overlay is visible,
                // then transition to the result screen.
                _cooldownFaces[empId] = now;
                _currentIsAdmin = false;

                Future.delayed(const Duration(milliseconds: 1500), () {
                  if (!mounted || _isDisposed) return;
                  setState(() {
                    _currentUserName = name;
                    _currentEmployeeId = empId;
                    _currentGender = gender ?? _genderCache[empId];
                    _avatarUrl = cachedDataUri;
                    _profilePhotoUrl = _profilePhotoCache[empId];
                    _kioskState = state;
                    _detectedFaces = [];
                  });
                  _scheduleReturnToScan();
                  if (cachedDataUri == null) {
                    if (avatarHttpUrl != null) {
                      _downloadAndCacheAvatar(empId, avatarHttpUrl);
                    } else {
                      _triggerAvatarGeneration(empId);
                    }
                  }
                  _checkIfAdmin(empId);

                  // TTS: speak the screen message
                  final isMale = (gender ?? _genderCache[empId])?.toLowerCase() != 'female';
                  final greeting = _getGreeting();
                  String ttsMessage;
                  switch (state) {
                    case KioskState.welcome:
                      ttsMessage = 'Hey $name, $greeting! Your check-in is completed. Wishing you a wonderful and productive day ahead!';
                      break;
                    case KioskState.alreadyIn:
                      ttsMessage = 'Welcome back $name! It looks like you are already checked in. Would you like to continue working or check out?';
                      break;
                    case KioskState.alreadyOut:
                      ttsMessage = 'Hey $name! You have already checked out today. Would you like to check in again?';
                      break;
                    default:
                      ttsMessage = '';
                  }
                  if (ttsMessage.isNotEmpty) {
                    _speakMessage(ttsMessage, isMale: isMale);
                  }
                });
              }

              if (logAction == 'check_in') {
                setUserAndShow(KioskState.welcome);
                break;
              } else if (logAction == 'already_in' || logAction == 'cooldown') {
                setUserAndShow(KioskState.alreadyIn);
                break;
              } else if (logAction == 'already_out') {
                setUserAndShow(KioskState.alreadyOut);
                break;
              } else if (logAction == 'check_out') {
                setUserAndShow(KioskState.alreadyOut);
                break;
              }
            }
          }
        });
      }
    } on DioException catch (e) {
      if (mounted && !_isDisposed) {
        // Only mark offline for connection-level failures, not 4xx/5xx responses
        final isConnectionError = e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.connectionError;
        if (isConnectionError) {
          setState(() {
            _isOnline = false;
            _statusMessage = 'Server unreachable. Retrying...';
          });
          // Try a lightweight health check to confirm server status
          _checkServerHealth();
        }
      }
    } catch (_) {
      // Ignore
    } finally {
      _isDetecting = false;
    }
  }

  Future<void> _checkServerHealth() async {
    // Background health probe — if server recovers, mark online again
    try {
      final response = await Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      )).get('/health');
      if (response.statusCode == 200 && mounted && !_isDisposed) {
        setState(() {
          _isOnline = true;
          _statusMessage = 'Step in front of the camera to check in';
        });
      }
    } catch (_) {
      // Still offline — the next detection loop iteration will retry
    }
  }

  /// Check if the detected employee has admin role
  Future<void> _checkIfAdmin(String empId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('kiosk_token') ?? '';
      if (token.isEmpty) return;

      final parts = token.split('.');
      if (parts.length == 3) {
        final payload = parts[1];
        final normalized = base64Url.normalize(payload);
        final decoded = utf8.decode(base64Url.decode(normalized));
        final map = jsonDecode(decoded) as Map<String, dynamic>;
        final role = map['role'] as String? ?? '';
        final tokenEmail = map['email'] as String? ?? '';

        final response = await _dio.get(
          '/api/v1/employees/$empId',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
        if (response.statusCode == 200) {
          final empEmail = response.data['email'] as String? ?? '';
          if (empEmail == tokenEmail && role == 'admin') {
            if (mounted && !_isDisposed && _currentEmployeeId == empId) {
              setState(() => _currentIsAdmin = true);
            }
          }
        }
      }
    } catch (_) {}
  }

  void _scheduleReturnToScan() {
    _returnToScanTimer?.cancel();
    // Auto-close any result screen (welcome, alreadyIn, alreadyOut) after 30 seconds
    _returnToScanTimer = Timer(const Duration(seconds: 30), () {
      if (mounted && !_isDisposed) {
        _returnToScanning();
      }
    });
  }

  void _returnToScanning() {
    _returnToScanTimer?.cancel();
    _tts?.stop();
    _isTtsSpeaking = false;
    setState(() {
      _kioskState = KioskState.scanning;
      _currentUserName = '';
      _currentEmployeeId = '';
      _currentGender = null;
      _currentIsAdmin = false;
      _avatarUrl = null;
      _profilePhotoUrl = null;
      _detectedFaces = [];
      _statusMessage = 'Step in front of the camera to check in';
    });
  }

  Future<void> _downloadAndCacheAvatar(String empId, String avatarHttpUrl) async {
    if (_avatarCache.containsKey(empId)) return;
    try {
      final path = avatarHttpUrl.contains('://')
          ? avatarHttpUrl.replaceFirst(ApiConstants.baseUrl, '')
          : avatarHttpUrl;
      final response = await _dio.get<List<int>>(
        path,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        final bytes = Uint8List.fromList(response.data!);
        final b64 = base64Encode(bytes);
        final dataUri = 'data:model/gltf-binary;base64,$b64';
        _avatarCache[empId] = dataUri;
        if (mounted && !_isDisposed && _currentEmployeeId == empId) {
          setState(() => _avatarUrl = dataUri);
        }
      }
    } catch (_) {}
  }

  Future<void> _triggerAvatarGeneration(String empId) async {
    try {
      final response = await _dio.post(
        '/api/v1/avatar/generate/$empId',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
      if (mounted && !_isDisposed && response.statusCode == 200) {
        final rawUrl = response.data['avatar_url'] as String?;
        if (rawUrl != null) {
          final fullUrl = rawUrl.startsWith('/') ? '${ApiConstants.baseUrl}$rawUrl' : rawUrl;
          await _downloadAndCacheAvatar(empId, fullUrl);
        }
      }
    } catch (_) {}
  }

  Future<void> _handleContinue() async {
    _tts?.stop();
    _isTtsSpeaking = false;
    try {
      await _dio.post('/api/v1/face/kiosk-continue/$_currentEmployeeId');
    } catch (_) {}
    _returnToScanning();
  }

  Future<void> _handleCheckout() async {
    _tts?.stop();
    _isTtsSpeaking = false;
    try {
      await _dio.post('/api/v1/face/kiosk-checkout/$_currentEmployeeId');
    } catch (_) {}
    setState(() {
      _kioskState = KioskState.scanning;
      _statusMessage = 'Check-out recorded. Have a great evening!';
      _currentUserName = '';
      _currentEmployeeId = '';
      _currentGender = null;
      _currentIsAdmin = false;
      _avatarUrl = null;
      _profilePhotoUrl = null;
      _detectedFaces = [];
    });
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _statusMessage = 'Step in front of the camera to check in');
      }
    });
  }

  Future<void> _handleReCheckin() async {
    _tts?.stop();
    _isTtsSpeaking = false;
    try {
      await _dio.post('/api/v1/face/kiosk-recheckin/$_currentEmployeeId');
    } catch (_) {}
    setState(() {
      _kioskState = KioskState.scanning;
      _statusMessage = 'Re-checked in successfully!';
      _currentUserName = '';
      _currentEmployeeId = '';
      _currentGender = null;
      _currentIsAdmin = false;
      _avatarUrl = null;
      _profilePhotoUrl = null;
      _detectedFaces = [];
    });
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _statusMessage = 'Step in front of the camera to check in');
      }
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Logout', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        content: Text(
          'Are you sure you want to logout from the kiosk?',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Logout', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Log the logout action as a kiosk log entry
      try {
        await _dio.post('/api/v1/face/kiosk-continue/$_currentEmployeeId');
      } catch (_) {}

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('kiosk_logged_in', false);
      await prefs.remove('kiosk_token');

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  IconData _getGenderIcon() {
    switch (_currentGender?.toLowerCase()) {
      case 'female':
        return Icons.face_3;
      case 'male':
        return Icons.face;
      default:
        return Icons.person;
    }
  }

  List<Color> _getGenderColors() {
    switch (_currentGender?.toLowerCase()) {
      case 'female':
        return [const Color(0xFFE91E63), const Color(0xFFF48FB1)];
      case 'male':
        return [const Color(0xFF1976D2), const Color(0xFF64B5F6)];
      default:
        return [const Color(0xFF00C853), const Color(0xFF69F0AE)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isCameraReady && _cameraController != null && _cameraController!.value.isInitialized)
            Opacity(
              opacity: _kioskState == KioskState.scanning ? 1.0 : 0.15,
              child: _buildCameraPreview(),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          if (_kioskState == KioskState.scanning && _detectedFaces.isNotEmpty)
            _buildHeadOverlays(),

          if (_kioskState == KioskState.welcome) _buildWelcomeScreen(),
          if (_kioskState == KioskState.alreadyIn) _buildAlreadyInScreen(),
          if (_kioskState == KioskState.alreadyOut) _buildAlreadyOutScreen(),

          if (_kioskState == KioskState.scanning) _buildStatusBar(),
          if (_kioskState == KioskState.scanning) _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    final controller = _cameraController!;
    final previewSize = controller.value.previewSize;
    if (previewSize == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: previewSize.height,
          height: previewSize.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  Widget _buildHeadOverlays() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const SizedBox.shrink();
    }
    final previewSize = _cameraController!.value.previewSize;
    if (previewSize == null) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewW = constraints.maxWidth;
        final viewH = constraints.maxHeight;

        // Camera preview is displayed in portrait orientation.
        // previewSize is reported in landscape notation (e.g. Size(1280,720)).
        // In _buildCameraPreview, we use SizedBox(width: previewSize.height, height: previewSize.width)
        // with FittedBox.cover. We must use the SAME dimensions here for consistent mapping.
        final double previewW = previewSize.height; // portrait width
        final double previewH = previewSize.width;  // portrait height

        // Determine effective captured image dimensions in portrait orientation.
        final bool imgIsLandscape = _imgWidth > _imgHeight;
        final double effW = imgIsLandscape ? _imgHeight : _imgWidth;
        final double effH = imgIsLandscape ? _imgWidth : _imgHeight;

        // BoxFit.cover scaling from PREVIEW dimensions to screen (matches _buildCameraPreview)
        final scale = math.max(viewW / previewW, viewH / previewH);
        final scaledW = previewW * scale;
        final scaledH = previewH * scale;
        final offsetX = (scaledW - viewW) / 2;
        final offsetY = (scaledH - viewH) / 2;

        // Scale factor to convert from captured image coords to preview coords
        final double imgToPreviewX = previewW / effW;
        final double imgToPreviewY = previewH / effH;

        return Stack(
          children: _detectedFaces.map((face) {
            double fL = face.headRect.left;
            double fR = face.headRect.right;
            double fT = face.headRect.top;
            double fB = face.headRect.bottom;

            // If image was landscape, rotate bounding box 90° CW to portrait
            if (imgIsLandscape) {
              final newL = _imgHeight - fB;
              final newR = _imgHeight - fT;
              final newT = fL;
              final newB = fR;
              fL = newL;
              fR = newR;
              fT = newT;
              fB = newB;
            }

            // Convert from captured image coords to preview coords
            fL *= imgToPreviewX;
            fR *= imgToPreviewX;
            fT *= imgToPreviewY;
            fB *= imgToPreviewY;

            // Mirror X for front camera (preview is mirrored)
            final left = (previewW - fR) * scale - offsetX;
            final right = (previewW - fL) * scale - offsetX;
            final top = fT * scale - offsetY;
            final bottom = fB * scale - offsetY;

            final clampedLeft = left.clamp(0.0, viewW);
            final clampedTop = top.clamp(0.0, viewH);
            final clampedRight = right.clamp(0.0, viewW);
            final clampedBottom = bottom.clamp(0.0, viewH);

            final rectWidth = (clampedRight - clampedLeft).abs();
            final rectHeight = (clampedBottom - clampedTop).abs();

            if (rectWidth < 10 || rectHeight < 10) return const SizedBox.shrink();
            // Skip if bounding box covers more than 70% of screen (likely false detection or too close)
            if (rectWidth > viewW * 0.7 || rectHeight > viewH * 0.7) return const SizedBox.shrink();

            final color = face.matched ? Colors.green : Colors.red;
            final label = face.matched
                ? '${face.name} (${(face.confidence * 100).toInt()}%)'
                : 'Face not recognized';

            return Positioned(
              left: clampedLeft,
              top: clampedTop,
              width: rectWidth,
              height: rectHeight,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: color, width: 3),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Transform.translate(
                    offset: Offset(0, 24.h),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ─── Gender-based Avatar or Fallback ──────────────────────────────
  Widget _buildAvatarOrIcon({
    required IconData fallbackIcon,
    required List<Color> fallbackColors,
    required Color fallbackGlowColor,
    required double size,
  }) {
    final s = size.r;
    if (_avatarUrl != null && (_avatarUrl!.endsWith('.glb') || _avatarUrl!.startsWith('data:'))) {
      return Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: fallbackGlowColor.withOpacity(0.4), blurRadius: 30, spreadRadius: 5),
          ],
        ),
        child: ClipOval(
          child: ModelViewer(
            src: _avatarUrl!,
            alt: 'Employee 3D Avatar',
            autoRotate: true,
            autoRotateDelay: 0,
            rotationPerSecond: '30deg',
            cameraControls: false,
            disableZoom: true,
            backgroundColor: const Color(0xFF1A1A2E),
            innerModelViewerHtml: '<style>model-viewer { --poster-color: #1A1A2E; }</style>',
          ),
        ),
      );
    }
    if (_profilePhotoUrl != null && _profilePhotoUrl!.isNotEmpty) {
      return _buildProfilePhotoAvatar(fallbackColors, fallbackGlowColor, s);
    }
    if (_avatarUrl == null && _currentEmployeeId.isNotEmpty && !_avatarCache.containsKey(_currentEmployeeId)) {
      return _buildLoadingAvatar(fallbackColors, fallbackGlowColor, s);
    }
    return _buildGenderAvatar(fallbackColors, fallbackGlowColor, s);
  }

  Widget _buildProfilePhotoAvatar(List<Color> colors, Color glowColor, double s) {
    return Container(
      width: s, height: s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: glowColor.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)],
      ),
      child: ClipOval(
        child: Image.network(
          _profilePhotoUrl!,
          width: s, height: s,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildGenderAvatar(colors, glowColor, s),
        ),
      ),
    );
  }

  Widget _buildLoadingAvatar(List<Color> colors, Color glowColor, double s) {
    final initial = _currentUserName.isNotEmpty ? _currentUserName[0].toUpperCase() : '';
    return Container(
      width: s, height: s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: colors),
        boxShadow: [BoxShadow(color: glowColor.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (initial.isNotEmpty)
            Text(initial, style: GoogleFonts.poppins(fontSize: (s * 0.35).sp, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.4))),
          SizedBox(width: s * 0.5, height: s * 0.5, child: const CircularProgressIndicator(color: Colors.white70, strokeWidth: 3)),
        ],
      ),
    );
  }

  Widget _buildGenderAvatar(List<Color> colors, Color glowColor, double s) {
    final genderColors = _getGenderColors();
    // Use DiceBear "notionists" style for adult-looking avatar illustrations
    final seed = Uri.encodeComponent(_currentUserName.isNotEmpty ? _currentUserName : 'employee');
    final avatarImageUrl = 'https://api.dicebear.com/9.x/notionists/png?seed=$seed&size=512&backgroundColor=transparent';

    return Container(
      width: s, height: s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: genderColors),
        boxShadow: [BoxShadow(color: glowColor.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)],
      ),
      child: ClipOval(
        child: Image.network(
          avatarImageUrl,
          width: s, height: s,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitialAvatar(genderColors, glowColor, s),
        ),
      ),
    );
  }

  Widget _buildInitialAvatar(List<Color> colors, Color glowColor, double s) {
    final initial = _currentUserName.isNotEmpty ? _currentUserName[0].toUpperCase() : '';
    return Container(
      width: s, height: s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: colors),
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.poppins(fontSize: (s * 0.4).sp, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Positioned(
      top: 50.h,
      right: 20.w,
      child: GestureDetector(
        onTap: _handleLogout,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, color: Colors.white70, size: 16.sp),
              SizedBox(width: 6.w),
              Text('Logout', style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white70, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Welcome Screen (Check-in) ────────────────────────────────────
  Widget _buildWelcomeScreen() {
    final genderColors = _getGenderColors();
    return Stack(
      children: [
        Container(
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAvatarOrIcon(
                    fallbackIcon: _getGenderIcon(),
                    fallbackColors: genderColors,
                    fallbackGlowColor: genderColors.first,
                    size: 160,
                  ),
                  SizedBox(height: 40.h),
                  Text(
                    'Hey $_currentUserName!',
                    style: GoogleFonts.poppins(fontSize: 36.sp, fontWeight: FontWeight.w700, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '${_getGreeting()}! Welcome to the office.',
                    style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.w400, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Wishing you a wonderful and productive day ahead!',
                    style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white54),
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
                          'Checked in at ${TimeOfDay.now().format(context)}',
                          style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_currentIsAdmin) _buildLogoutButton(),
      ],
    );
  }

  // ─── Already In Screen ────────────────────────────────────────────
  Widget _buildAlreadyInScreen() {
    final genderColors = _getGenderColors();
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1A1A2E).withOpacity(0.95),
                const Color(0xFF0D253F).withOpacity(0.95),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAvatarOrIcon(
                      fallbackIcon: _getGenderIcon(),
                      fallbackColors: genderColors,
                      fallbackGlowColor: const Color(0xFF42A5F5),
                      size: 140,
                    ),
                    SizedBox(height: 36.h),
                    Text(
                      'Welcome back, $_currentUserName!',
                      style: GoogleFonts.poppins(fontSize: 28.sp, fontWeight: FontWeight.w600, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'It looks like you\'re already checked in. Would you like to continue your day or are you heading out?',
                      style: GoogleFonts.poppins(fontSize: 17.sp, color: Colors.white70, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 48.h),
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton.icon(
                        onPressed: _handleContinue,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: Text('Continue Working', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF42A5F5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                          elevation: 4,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: OutlinedButton.icon(
                        onPressed: _handleCheckout,
                        icon: const Icon(Icons.logout_rounded),
                        label: Text('Check Out', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF5350),
                          side: const BorderSide(color: Color(0xFFEF5350), width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_currentIsAdmin) _buildLogoutButton(),
      ],
    );
  }

  // ─── Already Out Screen ───────────────────────────────────────────
  Widget _buildAlreadyOutScreen() {
    final genderColors = _getGenderColors();
    return Stack(
      children: [
        Container(
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
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAvatarOrIcon(
                      fallbackIcon: _getGenderIcon(),
                      fallbackColors: genderColors,
                      fallbackGlowColor: const Color(0xFFFF9800),
                      size: 140,
                    ),
                    SizedBox(height: 36.h),
                    Text(
                      'Hey $_currentUserName!',
                      style: GoogleFonts.poppins(fontSize: 28.sp, fontWeight: FontWeight.w600, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'You have already checked out today. Would you like to check in again?',
                      style: GoogleFonts.poppins(fontSize: 17.sp, color: Colors.white70, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 48.h),
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton.icon(
                        onPressed: _handleReCheckin,
                        icon: const Icon(Icons.login_rounded),
                        label: Text('Check In Again', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                          elevation: 4,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: OutlinedButton.icon(
                        onPressed: _returnToScanning,
                        icon: const Icon(Icons.close_rounded),
                        label: Text('No, Thanks', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white54,
                          side: const BorderSide(color: Colors.white24, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_currentIsAdmin) _buildLogoutButton(),
      ],
    );
  }

  // ─── Status Bar ──────────────────────────────────────────────────
  Widget _buildStatusBar() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 50.h, 20.w, 16.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10.w, height: 10.w,
              decoration: BoxDecoration(color: _isOnline ? Colors.green : Colors.red, shape: BoxShape.circle),
            ),
            SizedBox(width: 8.w),
            Text(
              _isOnline ? 'LIVE' : 'OFFLINE',
              style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const Spacer(),
            Text(
              'Siddhan Logs Kiosk',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (_, __) {
                final now = DateTime.now();
                return Text(
                  '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w500),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Bottom Bar ────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 40.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _statusMessage,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            if (_isDetecting)
              SizedBox(
                width: 120.w,
                child: const LinearProgressIndicator(color: Color(0xFF4F46E5), backgroundColor: Colors.white24),
              ),
          ],
        ),
      ),
    );
  }
}
