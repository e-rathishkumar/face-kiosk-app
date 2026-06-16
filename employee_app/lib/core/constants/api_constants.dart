class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://192.168.37.200:8001';

  // Auth
  static const String login = '/auth/login';
  static const String resetPassword = '/auth/reset-password';

  // Employees
  static const String employees = '/employees';
  static String employee(String id) => '/employees/$id';
  static const String faceUpload = '/employee-faces/upload';

  // Attendance
  static const String attendance = '/attendance';
  static const String activeAttendance = '/attendance/active';
  static const String checkIn = '/attendance/check-in';
  static const String checkOut = '/attendance/check-out';
  static String employeeAttendance(String id) => '/attendance/employee/$id';

  // Recognition Logs
  static const String recognitionLogs = '/recognition-logs';
  static String employeeRecognitionLogs(String id) => '/recognition-logs/$id';

  // Dashboard
  static const String dashboardSummary = '/dashboard/summary';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 60);
}
