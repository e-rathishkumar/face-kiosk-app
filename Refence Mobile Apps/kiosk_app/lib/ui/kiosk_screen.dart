/// Edge AI Kiosk Screen — Main attendance kiosk with local face recognition.
/// 
/// Architecture:
/// Camera → ML Kit face detection → Validate face quality → ONNX embedding →
/// RAM cache match → Local attendance → Queue sync → TTS feedback
///
/// All recognition is OFFLINE. Only sync requires connectivity.
library;

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../core/constants.dart';
import '../data/database/edge_database.dart';
import '../face/face_engine_service.dart';
import '../face/liveness_detector.dart';
import '../services/attendance_service.dart';
import '../services/sync_service.dart';
import '../services/thermal_monitor.dart';
import '../main.dart' show cameras;

enum KioskState { scanning, welcome, alreadyIn, alreadyOut }

class KioskScreen extends StatefulWidget {
  const KioskScreen({super.key});

  @override
  State<KioskScreen> createState() => _KioskScreenState();
}

class _KioskScreenState extends State<KioskScreen> with WidgetsBindingObserver {
  // Camera
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isDetecting = false;
  bool _isDisposed = false;
  Timer? _detectionTimer;
  Timer? _returnToScanTimer;
  int _cameraRetryCount = 0;

  // ML Kit
  late FaceDetector _faceDetector;

  // Edge AI
  final FaceEngineService _faceEngine = FaceEngineService();
  final LivenessDetector _livenessDetector = LivenessDetector();
  late AttendanceService _attendanceService;
  late SyncService _syncService;
  late ThermalMonitor _thermalMonitor;
  late EdgeDatabase _db;

  // TTS
  FlutterTts? _tts;
  bool _isTtsSpeaking = false;

  // State
  KioskState _kioskState = KioskState.scanning;
  String _currentUserName = '';
  String _currentEmployeeId = '';
  String? _currentGender;
  double _currentConfidence = 0.0;
  bool _isOnline = false;
  bool _modelLoaded = false;
  String _statusMessage = 'Initializing...';
  int _queueDepth = 0;
  int _cachedEmployees = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAll();
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _detectionTimer?.cancel();
    _returnToScanTimer?.cancel();
    _cameraController?.dispose();
    _faceDetector.close();
    _faceEngine.dispose();
    _syncService.stop();
    _thermalMonitor.stop();
    _tts?.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_isCameraReady) _initCamera();
    } else if (state == AppLifecycleState.paused) {
      _detectionTimer?.cancel();
    }
  }

  Future<void> _initializeAll() async {
    _db = EdgeDatabase.instance;

    // Initialize ML Kit face detector
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true, // For liveness (eye open, smile)
        enableLandmarks: true,
        enableTracking: true,
        performanceMode: FaceDetectorMode.fast,
        minFaceSize: 0.25,
      ),
    );

    // Initialize services
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kiosk_token') ?? '';

    final dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Authorization': 'Bearer $token'},
    ));

    _attendanceService = AttendanceService(db: _db);
    _syncService = SyncService(
      dio: dio,
      db: _db,
      deviceId: 'kiosk_${const Uuid().v4().substring(0, 8)}',
    );
    _thermalMonitor = ThermalMonitor(engine: _faceEngine);

    _syncService.onConnectivityChanged = (online) {
      if (mounted) setState(() => _isOnline = online);
    };
    _syncService.onEmbeddingsUpdated = (count) {
      _faceEngine.loadEmbeddingsIntoCache().then((c) {
        if (mounted) setState(() => _cachedEmployees = c);
      });
    };

    _thermalMonitor.onStateChanged = (state) {
      if (mounted) setState(() {});
      // Restart detection timer with adjusted interval
      _restartDetectionTimer();
    };

    // Initialize ONNX model
    setState(() => _statusMessage = 'Loading face model...');
    try {
      await _faceEngine.initialize();
      _modelLoaded = true;
      setState(() => _statusMessage = 'Model loaded');
    } catch (e) {
      setState(() => _statusMessage = 'Model load failed: $e');
    }

    // Load cached embeddings
    setState(() => _statusMessage = 'Loading embeddings...');
    _cachedEmployees = await _faceEngine.loadEmbeddingsIntoCache();

    // Sync employees from server
    setState(() => _statusMessage = 'Syncing employees...');
    final synced = await _syncService.syncEmployees();
    if (synced > 0) {
      _cachedEmployees = await _faceEngine.loadEmbeddingsIntoCache();
    }

    // Start background services
    _syncService.start();
    _thermalMonitor.start();

    // Initialize camera
    await _initCamera();
    setState(() => _statusMessage = 'Ready');
  }

  Future<void> _initCamera() async {
    if (_isDisposed) return;

    try {
      final cams = cameras.isNotEmpty
          ? cameras
          : await availableCameras();

      if (cams.isEmpty) {
        setState(() => _statusMessage = 'No camera found');
        return;
      }

      // Prefer front camera
      final camera = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cams.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium, // 480p is sufficient for face detection
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await _cameraController!.initialize();
      if (_isDisposed) return;

      _isCameraReady = true;
      _cameraRetryCount = 0;
      setState(() => _statusMessage = 'Scanning...');

      _restartDetectionTimer();
    } catch (e) {
      _cameraRetryCount++;
      if (_cameraRetryCount < AppConstants.maxCameraRetries) {
        await Future.delayed(
          Duration(milliseconds: AppConstants.cameraRecoveryDelayMs),
        );
        if (!_isDisposed) _initCamera();
      } else {
        setState(() => _statusMessage = 'Camera failed after $_cameraRetryCount attempts');
      }
    }
  }

  void _restartDetectionTimer() {
    _detectionTimer?.cancel();
    final interval = _thermalMonitor.recommendedIntervalMs;
    _detectionTimer = Timer.periodic(
      Duration(milliseconds: interval),
      (_) => _detectAndRecognize(),
    );
  }

  /// Main recognition pipeline — runs at throttled intervals.
  Future<void> _detectAndRecognize() async {
    if (_isDetecting || !_isCameraReady || !_modelLoaded || _isDisposed) return;
    if (_kioskState != KioskState.scanning) return;

    _isDetecting = true;

    try {
      // 1. Capture frame
      final image = await _cameraController!.takePicture();
      final bytes = await File(image.path).readAsBytes();

      // 2. ML Kit face detection
      final inputImage = InputImage.fromFilePath(image.path);
      final faces = await _faceDetector.processImage(inputImage);

      // Clean up temp file
      try { await File(image.path).delete(); } catch (_) {}

      if (faces.isEmpty) {
        _isDetecting = false;
        return;
      }

      // 3. Validate: single face, frontal, good quality
      if (faces.length > 1) {
        _isDetecting = false;
        return; // Multiple faces — skip
      }

      final face = faces.first;

      // Check face quality
      if (!_isFaceQualityOk(face)) {
        _isDetecting = false;
        return;
      }

      // 4. Liveness check
      final livenessResult = _livenessDetector.evaluate(face);
      if (!livenessResult.isLive) {
        _isDetecting = false;
        return;
      }

      // 5. Generate embedding via ONNX
      final embedding = await _faceEngine.generateEmbedding(
        bytes,
        face.boundingBox.width.toInt(),
        face.boundingBox.height.toInt(),
      );

      // 6. Match against cache
      final match = _faceEngine.matchEmbedding(embedding);
      if (match == null) {
        _isDetecting = false;
        return; // No match
      }

      // 7. Mark attendance locally
      final result = await _attendanceService.markAttendance(match: match);

      if (result.action == 'cooldown') {
        _isDetecting = false;
        return;
      }

      // 8. Update UI and provide feedback
      if (mounted && !_isDisposed) {
        setState(() {
          _currentUserName = match.name;
          _currentEmployeeId = match.employeeId;
          _currentGender = match.gender;
          _currentConfidence = match.confidence;

          switch (result.action) {
            case 'check_in':
              _kioskState = KioskState.welcome;
              break;
            case 'already_in':
              _kioskState = KioskState.alreadyIn;
              break;
            case 'already_out':
              _kioskState = KioskState.alreadyOut;
              break;
          }
        });

        // Update queue depth
        _queueDepth = await _db.getQueueDepth();

        // TTS feedback
        _provideFeedback(result);
      }
    } catch (e) {
      // Don't crash — just log and continue scanning
      debugPrint('Recognition error: $e');
    } finally {
      _isDetecting = false;
    }
  }

  bool _isFaceQualityOk(Face face) {
    final box = face.boundingBox;

    // Face must be reasonable size (at least 80x80 pixels)
    if (box.width < 80 || box.height < 80) return false;

    // Head rotation check (must be roughly frontal)
    final eulerY = face.headEulerAngleY ?? 0;
    final eulerZ = face.headEulerAngleZ ?? 0;
    if (eulerY.abs() > 35 || eulerZ.abs() > 25) return false;

    return true;
  }

  void _provideFeedback(AttendanceAction result) {
    final isMale = _currentGender?.toLowerCase() != 'female';
    final firstName = _currentUserName.split(' ').first;

    switch (result.action) {
      case 'check_in':
        _speakMessage('Welcome $firstName! You are checked in.', isMale: isMale);
        _scheduleReturnToScanning();
        break;
      case 'already_in':
        _speakMessage('Hello $firstName. You are already checked in.', isMale: isMale);
        _scheduleReturnToScanning(seconds: 10);
        break;
      case 'already_out':
        _speakMessage('$firstName, you already checked out today.', isMale: isMale);
        _scheduleReturnToScanning();
        break;
    }
  }

  void _scheduleReturnToScanning({int seconds = 8}) {
    _returnToScanTimer?.cancel();
    _returnToScanTimer = Timer(Duration(seconds: seconds), () {
      if (mounted && !_isDisposed) {
        setState(() {
          _kioskState = KioskState.scanning;
          _livenessDetector.reset();
        });
      }
    });
  }

  void _returnToScanning() {
    _returnToScanTimer?.cancel();
    if (mounted && !_isDisposed) {
      setState(() {
        _kioskState = KioskState.scanning;
        _livenessDetector.reset();
      });
    }
  }

  Future<void> _handleCheckout() async {
    await _attendanceService.forceCheckout(_currentEmployeeId, _currentUserName);
    _queueDepth = await _db.getQueueDepth();
    if (mounted) setState(() {});

    final firstName = _currentUserName.split(' ').first;
    final isMale = _currentGender?.toLowerCase() != 'female';
    _speakMessage('Goodbye $firstName! You are checked out.', isMale: isMale);
    _scheduleReturnToScanning(seconds: 5);
  }

  void _handleContinue() {
    final firstName = _currentUserName.split(' ').first;
    final isMale = _currentGender?.toLowerCase() != 'female';
    _speakMessage('Have a great day, $firstName!', isMale: isMale);
    _scheduleReturnToScanning(seconds: 3);
  }

  // === TTS ===

  Future<FlutterTts> _getTts() async {
    if (_tts != null) return _tts!;
    _tts = FlutterTts();
    if (Platform.isIOS) {
      await _tts!.setSharedInstance(true);
    }
    await _tts!.setSpeechRate(0.45);
    await _tts!.setVolume(1.0);
    await _tts!.setPitch(1.0);
    return _tts!;
  }

  Future<void> _speakMessage(String message, {bool isMale = true}) async {
    final tts = await _getTts();
    if (Platform.isAndroid) {
      await tts.setLanguage('en-US');
      await tts.setPitch(isMale ? 0.85 : 1.3);
    }
    if (_isDisposed) return;
    _isTtsSpeaking = true;
    tts.setCompletionHandler(() => _isTtsSpeaking = false);
    await tts.speak(message);
  }

  // === Logout ===

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('kiosk_logged_in');
    await prefs.remove('kiosk_token');
    if (mounted) {
      setState(() {
        _kioskState = KioskState.scanning;
      });
    }
  }

  // === UI ===

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1080, 1920),
      builder: (_, __) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Camera preview (full screen)
            if (_isCameraReady && _cameraController != null)
              Positioned.fill(
                child: ClipRect(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _cameraController!.value.previewSize?.height ?? 480,
                      height: _cameraController!.value.previewSize?.width ?? 640,
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
                ),
              ),

            // Status overlay (top)
            _buildStatusBar(),

            // Main content overlay
            _buildMainOverlay(),

            // Queue & sync status (bottom)
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    final thermalColor = switch (_thermalMonitor.state) {
      ThermalState.normal => Colors.green,
      ThermalState.warm => Colors.orange,
      ThermalState.hot => Colors.deepOrange,
      ThermalState.critical => Colors.red,
    };

    return Positioned(
      top: 40.h,
      left: 20.w,
      right: 20.w,
      child: Row(
        children: [
          // Online/Offline status
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _isOnline ? Colors.green.withOpacity(0.8) : Colors.red.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: Colors.white,
                  size: 16.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  _isOnline ? 'ONLINE' : 'OFFLINE',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Thermal indicator
          if (_thermalMonitor.temperature > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: thermalColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${_thermalMonitor.temperature.toStringAsFixed(0)}°C',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          SizedBox(width: 8.w),
          // Model status
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _modelLoaded ? Colors.blue.withOpacity(0.8) : Colors.grey.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '$_cachedEmployees faces',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainOverlay() {
    switch (_kioskState) {
      case KioskState.scanning:
        return _buildScanningOverlay();
      case KioskState.welcome:
        return _buildWelcomeOverlay();
      case KioskState.alreadyIn:
        return _buildAlreadyInOverlay();
      case KioskState.alreadyOut:
        return _buildAlreadyOutOverlay();
    }
  }

  Widget _buildScanningOverlay() {
    return Positioned(
      bottom: 120.h,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // Scanning animation
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              children: [
                Icon(Icons.face_retouching_natural, color: Colors.white70, size: 48.sp),
                SizedBox(height: 12.h),
                Text(
                  _statusMessage == 'Scanning...' ? 'Look at the camera' : _statusMessage,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Face recognition active — fully offline',
                  style: GoogleFonts.inter(
                    color: Colors.white54,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.green.withOpacity(0.85),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 80.sp),
              SizedBox(height: 20.h),
              Text(
                'Welcome!',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                _currentUserName,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Checked in • ${(_currentConfidence * 100).toStringAsFixed(0)}% match',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlreadyInOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.blue.withOpacity(0.85),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, color: Colors.white, size: 80.sp),
              SizedBox(height: 20.h),
              Text(
                'Hello, $_currentUserName!',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'You are already checked in.',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 18.sp,
                ),
              ),
              SizedBox(height: 40.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                    'Check Out',
                    Icons.logout,
                    Colors.red,
                    _handleCheckout,
                  ),
                  SizedBox(width: 20.w),
                  _buildActionButton(
                    'Continue',
                    Icons.arrow_forward,
                    Colors.green,
                    _handleContinue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlreadyOutOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.orange.withOpacity(0.85),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 80.sp),
              SizedBox(height: 20.h),
              Text(
                _currentUserName,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'You already checked out today.',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 18.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'See you tomorrow!',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 20.h,
      left: 20.w,
      right: 20.w,
      child: Row(
        children: [
          // Queue depth
          if (_queueDepth > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Queue: $_queueDepth',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const Spacer(),
          // Logout (small, subtle)
          GestureDetector(
            onLongPress: _logout,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Siddhan Logs v${AppConstants.appVersion}',
                style: GoogleFonts.inter(
                  color: Colors.white30,
                  fontSize: 10.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
