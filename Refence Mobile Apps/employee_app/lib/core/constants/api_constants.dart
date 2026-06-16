class ApiConstants {
  ApiConstants._();

  // Base URL - hardcoded for local dev (use dart-define for production)
  static const String baseUrl = 'http://127.0.0.1:5000/api/v1';


  // local URL for physical devices (replace with your machine's IP address) 
  // static const String baseUrl = 'http://192.168.37.200:8000/api/v1';

  // WebSocket URL - derived from base URL
  static String get wsUrl {
    final httpUrl = baseUrl;
    final wsBase = httpUrl.replaceFirst('http://', 'ws://').replaceFirst('https://', 'wss://');
    return wsBase;
  }

  // Auth
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String updatePassword = '/auth/update-password';

  // Employee
  static const String profile = '/employees/me';
  static const String updateProfile = '/employees/me';

  // Face
  static const String faceValidate = '/face/validate';
  static const String faceRegisterSelf = '/face/register-self';
  static const String faceRegister360 = '/face/register-360';

  // Logs (Check-in / Check-out)
  static const String logs = '/logs';
  static const String checkIn = '/logs/check-in';
  static const String checkOut = '/logs/check-out';
  static const String todayLog = '/logs/today';

  // Geofence
  static const String geofences = '/geofences';
  static const String geofenceCheck = '/geofences/check';

  // Timeouts (generous for Render free tier cold start ~30s + face recognition processing)
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 120);
  static const Duration sendTimeout = Duration(seconds: 60);
}
