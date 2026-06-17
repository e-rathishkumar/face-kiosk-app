import 'package:equatable/equatable.dart';

import '../../../domain/entities/attendance_record.dart';
import '../../../domain/entities/activity_record.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {
  const AttendanceInitial();
}

class AttendanceLoading extends AttendanceState {
  const AttendanceLoading();
}

class AttendanceLoaded extends AttendanceState {
  final List<AttendanceRecord> records;
  final List<ActivityRecord> activities;
  final AttendanceRecord? todayRecord;
  final Map<String, dynamic>? dashboardData;

  const AttendanceLoaded({
    required this.records,
    this.activities = const [],
    this.todayRecord,
    this.dashboardData,
  });

  @override
  List<Object?> get props => [records, activities, todayRecord, dashboardData];

  AttendanceLoaded copyWith({
    List<AttendanceRecord>? records,
    List<ActivityRecord>? activities,
    AttendanceRecord? todayRecord,
    Map<String, dynamic>? dashboardData,
  }) {
    return AttendanceLoaded(
      records: records ?? this.records,
      activities: activities ?? this.activities,
      todayRecord: todayRecord ?? this.todayRecord,
      dashboardData: dashboardData ?? this.dashboardData,
    );
  }
}

class AttendanceActionLoading extends AttendanceState {
  final AttendanceLoaded previousState;

  const AttendanceActionLoading({required this.previousState});

  @override
  List<Object?> get props => [previousState];
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError({required this.message});

  @override
  List<Object?> get props => [message];
}
