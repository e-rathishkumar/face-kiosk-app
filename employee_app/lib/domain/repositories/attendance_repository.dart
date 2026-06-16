import 'package:dartz/dartz.dart';

import '../entities/attendance_record.dart';

abstract class AttendanceRepository {
  Future<Either<String, AttendanceRecord?>> getTodayLog(String employeeId);
  Future<Either<String, List<AttendanceRecord>>> getHistory(String employeeId);
  Future<Either<String, AttendanceRecord>> checkIn({required String employeeId});
  Future<Either<String, AttendanceRecord>> checkOut({required String employeeId});
  Future<Either<String, Map<String, dynamic>>> getDashboard(String employeeId);
}
