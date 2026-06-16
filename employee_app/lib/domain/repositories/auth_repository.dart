import 'package:dartz/dartz.dart';

import '../entities/employee.dart';

abstract class AuthRepository {
  Future<Either<String, Employee>> login(String username, String password);
  Future<Either<String, Employee>> getProfile(String employeeId);
  Future<Either<String, Map<String, dynamic>>> resetPassword({
    required String oldPassword,
    required String newPassword,
  });
  Future<Either<String, void>> register360Face(
    String employeeId,
    List<Map<String, dynamic>> captures,
  );
  Future<void> logout();
  Future<Employee?> getCachedUser();
}
