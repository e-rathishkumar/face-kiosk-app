/// Core constants for the kiosk edge AI system.
library;

class AppConstants {
  AppConstants._();

  static const String appName = 'Siddhan Logs Kiosk';
  static const String appVersion = '2.0.0';

  // Recognition thresholds
  static const double faceMatchThreshold = 0.55; // Cosine similarity
  static const double livenessThreshold = 0.3;

  // Timing
  static const int detectionIntervalMs = 2000; // 0.5 FPS base rate
  static const int cooldownSeconds = 60;
  static const int returnToScanSeconds = 8;
  static const int syncIntervalSeconds = 30;
  static const int heartbeatIntervalSeconds = 60;

  // Thermal
  static const double thermalWarningCelsius = 45.0;
  static const double thermalCriticalCelsius = 55.0;
  static const int thermalCooldownMs = 5000; // Slow down when hot

  // Camera
  static const int cameraRecoveryDelayMs = 3000;
  static const int maxCameraRetries = 5;

  // Database
  static const String dbName = 'kiosk_edge.db';
  static const int dbVersion = 3;

  // Model
  static const String modelFileName = 'mobilefacenet.onnx';
  static const int embeddingDimension = 512;
}

class ApiConstants {
  ApiConstants._();

  /// Edge backend runs ON the Android device (via Termux) at port 5000.
  /// The kiosk app connects to localhost because the backend is on the same device.
  static const String baseUrl = 'http://127.0.0.1:5000';

  // For testing with central backend on Mac (port 8000):
  // static const String baseUrl = 'http://<MAC_IP>:8000';

  static const String apiPrefix = '/api/v1';

  // Sync endpoints
  static const String syncEmployees = '$apiPrefix/sync/employees';
  static const String syncAttendance = '$apiPrefix/sync/attendance';
  static const String syncEnroll = '$apiPrefix/sync/enroll';
  static const String syncHeartbeat = '$apiPrefix/sync/heartbeat';
  static const String syncStatus = '$apiPrefix/sync/status';

  // Auth
  static const String login = '$apiPrefix/auth/login';
  static const String refresh = '$apiPrefix/auth/refresh';

  // Legacy (still used for some operations)
  static const String kioskCheckout = '$apiPrefix/face/kiosk-checkout';
  static const String kioskContinue = '$apiPrefix/face/kiosk-continue';
}
