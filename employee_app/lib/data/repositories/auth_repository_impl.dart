import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/local_storage.dart';
import '../datasources/remote/api_client.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final LocalStorage _localStorage;

  AuthRepositoryImpl({
    required ApiClient apiClient,
    required LocalStorage localStorage,
  })  : _apiClient = apiClient,
        _localStorage = localStorage;

  @override
  Future<Either<String, Employee>> login(
      String username, String password) async {
    try {
      final response = await _apiClient.login(username, password);

      // Save tokens
      final accessToken = response['access_token']?.toString();
      final refreshToken = response['refresh_token']?.toString();
      final userId = response['id']?.toString();
      final mustResetPassword =
          response['must_reset_password'] as bool? ?? false;

      if (accessToken != null) {
        await _localStorage.saveAccessToken(accessToken);
      }
      if (refreshToken != null) {
        await _localStorage.saveRefreshToken(refreshToken);
      }
      await _localStorage.saveUsername(username);

      // Now fetch the employee profile using the user ID
      // The login response has the user ID, but the employee may have a different ID
      // Try fetching employee by user ID first
      Employee employee;
      try {
        final allEmployeesResponse = await _apiClient.getEmployees();
        final allEmployees = allEmployeesResponse as List;

        final matchedEmpJson = allEmployees.firstWhere(
          (emp) {
            final empCode = emp['employee_code']?.toString().toLowerCase() ?? '';
            final empEmail = emp['email']?.toString().toLowerCase() ?? '';
            final searchUsername = username.toLowerCase();
            return empCode == searchUsername || empEmail == searchUsername;
          },
          orElse: () => null,
        );

        if (matchedEmpJson != null) {
          employee = Employee.fromJson(matchedEmpJson);

          // Try to fetch face
          try {
            final faces = await _apiClient.getEmployeeFaces(employee.id);
            if (faces.isNotEmpty) {
              final face = faces.first as Map<String, dynamic>;
              final imageUrl = face['image_url'] as String?;
              if (imageUrl != null) {
                // Prepend base URL since backend stores relative path like 'uploads/faces/...'
                final fullUrl = '${ApiConstants.baseUrl}/$imageUrl';
                matchedEmpJson['profile_photo_url'] = fullUrl;
                employee = Employee.fromJson(matchedEmpJson);
              }
            }
          } catch (_) {
            // Ignore if faces can't be fetched
          }

          // Override isNewUser from login response
          employee = Employee(
            id: employee.id,
            employeeCode: employee.employeeCode,
            firstName: employee.firstName,
            lastName: employee.lastName,
            email: employee.email,
            phone: employee.phone,
            department: employee.department,
            designation: employee.designation,
            isActive: employee.isActive,
            profilePhotoUrl: employee.profilePhotoUrl,
            gender: employee.gender,
            isNewUser: mustResetPassword,
            faceRegistered: employee.faceRegistered,
            joinedAt: employee.joinedAt,
          );
        } else {
          throw Exception('Employee not found for username: $username');
        }
      } catch (_) {
        // If employee fetch fails, create a minimal employee from login data
        employee = Employee(
          id: userId ?? '',
          employeeCode: username,
          firstName: username,
          lastName: '',
          isNewUser: mustResetPassword,
          joinedAt: DateTime.now(),
        );
      }

      // Save user data
      await _localStorage.saveUserData(employee.toJson());

      return Right(employee);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map) {
        return Left(data['detail']?.toString() ?? 'Login failed');
      }
      return const Left('Login failed. Please check your credentials.');
    } catch (e) {
      return Left('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Employee>> getProfile(String employeeId) async {
    try {
      final response = await _apiClient.getEmployee(employeeId);

      // Try to fetch face
      try {
        final faces = await _apiClient.getEmployeeFaces(employeeId);
        if (faces.isNotEmpty) {
          final face = faces.first as Map<String, dynamic>;
          final imageUrl = face['image_url'] as String?;
          if (imageUrl != null) {
            final fullUrl = '${ApiConstants.baseUrl}/$imageUrl';
            response['profile_photo_url'] = fullUrl;
          }
        }
      } catch (_) {}

      final employee = Employee.fromJson(response);
      await _localStorage.saveUserData(employee.toJson());
      return Right(employee);
    } on DioException catch (e) {
      return Left(
        e.response?.data?['detail']?.toString() ?? 'Failed to load profile',
      );
    } catch (e) {
      return Left('Failed to load profile');
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> resetPassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.resetPassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      // Update cached user data
      final userData = _localStorage.getUserData();
      if (userData != null) {
        userData['is_new_user'] = false;
        userData['must_reset_password'] = false;
        await _localStorage.saveUserData(userData);
      }

      return Right(response);
    } on DioException catch (e) {
      final data = e.response?.data;
      return Left(data is Map
          ? data['detail']?.toString() ?? 'Failed to update password'
          : 'Failed to update password');
    } catch (e) {
      return Left('Failed to update password: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    await _localStorage.clearAll();
  }

  @override
  Future<Either<String, void>> register360Face(
    String employeeId,
    List<Map<String, dynamic>> captures,
  ) async {
    try {
      for (final capture in captures) {
        final pose = capture['angle'] as String;
        final bytes = capture['bytes'] as List<int>;
        await _apiClient.uploadFace(
          employeeId: employeeId,
          pose: pose
              .toUpperCase(), // Ensure enum matches backend (FRONT, LEFT, RIGHT, UP, DOWN)
          imageBytes: bytes,
        );
      }
      return const Right(null);
    } on DioException catch (e) {
      final data = e.response?.data;
      return Left(data is Map
          ? data['detail']?.toString() ?? 'Failed to register face'
          : 'Failed to register face');
    } catch (e) {
      return Left('Failed to register face: ${e.toString()}');
    }
  }

  @override
  Future<Employee?> getCachedUser() async {
    final token = await _localStorage.getAccessToken();
    if (token == null || token.isEmpty) return null;

    final userData = _localStorage.getUserData();
    if (userData == null) return null;

    return Employee.fromJson(userData);
  }
}
