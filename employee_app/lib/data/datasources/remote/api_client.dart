import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../core/constants/api_constants.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {
        'username': username,
        'password': password,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> resetPassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await _dio.post(
      ApiConstants.resetPassword,
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  // ── Employee ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getEmployee(String employeeId) async {
    final response = await _dio.get(ApiConstants.employee(employeeId));
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getEmployees() async {
    final response = await _dio.get(ApiConstants.employees);
    return response.data as List<dynamic>;
  }

  // ── Faces ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> uploadFace({
    required String employeeId,
    required String pose,
    required List<int> imageBytes,
  }) async {
    final formData = FormData.fromMap({
      'employee_id': employeeId,
      'pose': pose,
      'image': MultipartFile.fromBytes(
        imageBytes,
        filename: 'face_$pose.jpg',
        contentType: MediaType('image', 'jpeg'),
      ),
    });
    
    final response = await _dio.post(
      ApiConstants.faceUpload,
      data: formData,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getEmployeeFaces(String employeeId) async {
    final response = await _dio.get('/employee-faces/$employeeId');
    return response.data as List<dynamic>;
  }

  // ── Attendance ────────────────────────────────────────────────────────────

  Future<List<dynamic>> getEmployeeAttendance(String employeeId) async {
    final response = await _dio.get(ApiConstants.employeeAttendance(employeeId));
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> checkIn({
    required String employeeId,
    String? kioskId,
  }) async {
    final response = await _dio.post(
      ApiConstants.checkIn,
      data: {
        'employee_id': employeeId,
        'kiosk_id': kioskId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> checkOut({
    required String employeeId,
  }) async {
    final response = await _dio.post(
      ApiConstants.checkOut,
      data: {
        'employee_id': employeeId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  // ── Recognition Logs ──────────────────────────────────────────────────────

  Future<List<dynamic>> getRecognitionLogs(String employeeId) async {
    final response = await _dio.get(ApiConstants.employeeRecognitionLogs(employeeId));
    return response.data as List<dynamic>;
  }

  // ── Dashboard ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboardSummary() async {
    final response = await _dio.get(ApiConstants.dashboardSummary);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getEmployeeDashboard(String employeeId) async {
    final response = await _dio.get(ApiConstants.employeeDashboard(employeeId));
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getEmployeeActivities(String employeeId) async {
    final response = await _dio.get(ApiConstants.employeeActivities(employeeId));
    return response.data as List<dynamic>;
  }
}
