import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class AttendanceTodayRequested extends AttendanceEvent {
  final String employeeId;

  const AttendanceTodayRequested({required this.employeeId});

  @override
  List<Object?> get props => [employeeId];
}

class AttendanceCheckInRequested extends AttendanceEvent {
  final String employeeId;

  const AttendanceCheckInRequested({required this.employeeId});

  @override
  List<Object?> get props => [employeeId];
}

class AttendanceCheckOutRequested extends AttendanceEvent {
  final String employeeId;

  const AttendanceCheckOutRequested({required this.employeeId});

  @override
  List<Object?> get props => [employeeId];
}

class AttendanceDashboardRequested extends AttendanceEvent {
  final String employeeId;

  const AttendanceDashboardRequested({required this.employeeId});

  @override
  List<Object?> get props => [employeeId];
}

class AttendanceResetRequested extends AttendanceEvent {
  const AttendanceResetRequested();
}
