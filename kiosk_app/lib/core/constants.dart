/// Core constants for the Face Recognition Kiosk system.
library;

class AppConstants {
  AppConstants._();

  static const String appName = 'Face Recognition Kiosk';
  static const String appVersion = '1.0.0';

  // Recognition cooldown
  static const int cooldownSeconds = 60;
  static const int returnToScanSeconds = 8;

  // Heartbeat
  static const int heartbeatIntervalSeconds = 60;

  // Camera
  static const int detectionIntervalMs = 2000;
  static const int cameraRecoveryDelayMs = 3000;
  static const int maxCameraRetries = 5;
}

class ApiConstants {
  ApiConstants._();

  /// Backend URL - matches the FastAPI backend running locally
  static const String baseUrl = 'https://rathishkumar-07-face-kiosk.hf.space';

  // Auth
  static const String login = '/auth/login';

  // Recognition
  static const String recognize = '/recognition';

  // Attendance
  static const String checkIn = '/attendance/check-in';
  static const String checkOut = '/attendance/check-out';
  static const String activeAttendance = '/attendance/active';

  // Heartbeat
  static const String heartbeat = '/heartbeat';

  // Health
  static const String health = '/health/kiosks';

  // Employees
  static const String employees = '/employees';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 60);
}
