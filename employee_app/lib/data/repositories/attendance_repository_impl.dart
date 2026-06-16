import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/remote/api_client.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final ApiClient _apiClient;

  AttendanceRepositoryImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<Either<String, List<AttendanceRecord>>> getHistory(String employeeId) async {
    try {
      final response = await _apiClient.getEmployeeAttendance(employeeId);
      final records = response
          .map((json) => AttendanceRecord.fromJson(json as Map<String, dynamic>))
          .toList();

      return Right(records);
    } on DioException catch (e) {
      return Left(
          e.response?.data?['detail']?.toString() ?? 'Failed to load history');
    } catch (e) {
      return Left('Failed to load log history');
    }
  }

  @override
  Future<Either<String, AttendanceRecord?>> getTodayLog(String employeeId) async {
    try {
      // The backend doesn't have a specific /today endpoint for a single employee in the new API
      // Instead, we'll fetch the history and filter for today
      final response = await _apiClient.getEmployeeAttendance(employeeId);
      final records = response
          .map((json) => AttendanceRecord.fromJson(json as Map<String, dynamic>))
          .toList();

      final today = DateTime.now();
      
      // Find a record where check_in or check_out is today
      try {
        final todayRecord = records.firstWhere((record) {
          final checkIn = record.checkIn;
          final checkOut = record.checkOut;
          
          if (checkIn != null && 
              checkIn.year == today.year && 
              checkIn.month == today.month && 
              checkIn.day == today.day) {
            return true;
          }
          if (checkOut != null && 
              checkOut.year == today.year && 
              checkOut.month == today.month && 
              checkOut.day == today.day) {
            return true;
          }
          return false;
        });
        return Right(todayRecord);
      } catch (_) {
        // No record found for today
        return const Right(null);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return const Right(null);
      return Left(e.response?.data?['detail']?.toString() ??
          'Failed to load today\'s log');
    } catch (e) {
      return const Right(null);
    }
  }

  @override
  Future<Either<String, AttendanceRecord>> checkIn({
    required String employeeId,
    String? kioskId,
  }) async {
    try {
      final response = await _apiClient.checkIn(
        employeeId: employeeId,
        kioskId: kioskId ?? 'mobile-app',
      );
      return Right(AttendanceRecord.fromJson(response));
    } on DioException catch (e) {
      return Left(
          e.response?.data?['detail']?.toString() ?? 'Check-in failed');
    } catch (e) {
      return Left('Check-in failed: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, AttendanceRecord>> checkOut({
    required String employeeId,
  }) async {
    try {
      final response = await _apiClient.checkOut(employeeId: employeeId);
      return Right(AttendanceRecord.fromJson(response));
    } on DioException catch (e) {
      return Left(
          e.response?.data?['detail']?.toString() ?? 'Check-out failed');
    } catch (e) {
      return Left('Check-out failed: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> getDashboard(String employeeId) async {
    try {
      final response = await _apiClient.getDashboardSummary();
      return Right(response);
    } on DioException catch (e) {
      return Left(
          e.response?.data?['detail']?.toString() ?? 'Failed to load dashboard');
    } catch (e) {
      return Left('Failed to load dashboard');
    }
  }
}
