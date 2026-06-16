import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../core/constants.dart';

/// API client for communicating with the Face Recognition backend.
class ApiClient {
  late final Dio _dio;
  String? _token;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      headers: {'Content-Type': 'application/json'},
      validateStatus: (status) => status != null && status < 500,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null && _token!.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  /// Login with username/password
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {'username': username, 'password': password},
    );
    return response.data as Map<String, dynamic>;
  }

  /// Upload a frame for face recognition
  Future<Map<String, dynamic>> recognize({
    required String kioskId,
    required Uint8List imageBytes,
    required String filename,
  }) async {
    final formData = FormData.fromMap({
      'kiosk_id': kioskId,
      'image': MultipartFile.fromBytes(
        imageBytes,
        filename: filename,
      ),
    });

    final response = await _dio.post(
      ApiConstants.recognize,
      data: formData,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Check in an employee
  Future<Map<String, dynamic>> checkIn({
    required String employeeId,
    required String kioskId,
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

  /// Check out an employee
  Future<Map<String, dynamic>> checkOut({
    required String employeeId,
  }) async {
    final response = await _dio.post(
      ApiConstants.checkOut,
      data: {'employee_id': employeeId},
    );
    return response.data as Map<String, dynamic>;
  }

  /// Send heartbeat data
  Future<void> sendHeartbeat({
    required String kioskId,
    int? batteryLevel,
    double? cpuUsage,
    double? memoryUsage,
    double? temperature,
    double? storageTotal,
    double? storageAvailable,
    int? networkStrength,
    String? deviceModel,
    String? appVersion,
  }) async {
    await _dio.post(
      ApiConstants.heartbeat,
      data: {
        'kiosk_id': kioskId,
        'battery_level': batteryLevel,
        'cpu_usage': cpuUsage,
        'memory_usage': memoryUsage,
        'temperature': temperature,
        'storage_total': storageTotal,
        'storage_available': storageAvailable,
        'network_strength': networkStrength,
        'device_model': deviceModel,
        'app_version': appVersion,
      },
    );
  }

  /// Get employee by ID
  Future<Map<String, dynamic>> getEmployee(String employeeId) async {
    final response = await _dio.get('${ApiConstants.employees}/$employeeId');
    return response.data as Map<String, dynamic>;
  }

  /// Get active attendance sessions
  Future<List<dynamic>> getActiveAttendance() async {
    final response = await _dio.get(ApiConstants.activeAttendance);
    return response.data as List<dynamic>;
  }
}
