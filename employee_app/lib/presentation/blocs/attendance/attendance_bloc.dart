import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/attendance_record.dart';
import '../../../domain/repositories/attendance_repository.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository _attendanceRepository;

  AttendanceBloc({required AttendanceRepository attendanceRepository})
      : _attendanceRepository = attendanceRepository,
        super(const AttendanceInitial()) {
    on<AttendanceTodayRequested>(_onTodayRequested);
    on<AttendanceCheckInRequested>(_onCheckIn);
    on<AttendanceCheckOutRequested>(_onCheckOut);
    on<AttendanceDashboardRequested>(_onDashboardRequested);
    on<AttendanceResetRequested>(_onReset);
  }

  Future<void> _onTodayRequested(
    AttendanceTodayRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    final currentState = state;
    List<AttendanceRecord> currentRecords = [];
    Map<String, dynamic>? currentDashboard;

    if (currentState is AttendanceLoaded) {
      currentRecords = currentState.records;
      currentDashboard = currentState.dashboardData;
    }

    emit(const AttendanceLoading());

    // Fetch history instead of just today (since backend doesn't have specific today endpoint)
    final historyResult = await _attendanceRepository.getHistory(event.employeeId);
    
    // Fetch today's log (which filters the history under the hood)
    final todayResult = await _attendanceRepository.getTodayLog(event.employeeId);

    List<AttendanceRecord> newRecords = currentRecords;
    AttendanceRecord? todayRecord;

    historyResult.fold(
      (error) {
        // Keep existing records on error
      },
      (records) {
        newRecords = records;
      },
    );

    todayResult.fold(
      (error) {
        // Leave todayRecord null
      },
      (record) {
        todayRecord = record;
      },
    );

    emit(AttendanceLoaded(
      records: newRecords,
      todayRecord: todayRecord,
      dashboardData: currentDashboard,
    ));
  }

  Future<void> _onCheckIn(
    AttendanceCheckInRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AttendanceLoaded) return;

    emit(AttendanceActionLoading(previousState: currentState));

    final result = await _attendanceRepository.checkIn(
      employeeId: event.employeeId,
    );

    result.fold(
      (error) {
        emit(AttendanceError(message: error));
        emit(currentState);
      },
      (record) {
        emit(currentState.copyWith(todayRecord: record));
        // Refresh dashboard to reflect check-in
        add(AttendanceDashboardRequested(employeeId: event.employeeId));
      },
    );
  }

  Future<void> _onCheckOut(
    AttendanceCheckOutRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AttendanceLoaded) return;

    emit(AttendanceActionLoading(previousState: currentState));

    final result = await _attendanceRepository.checkOut(
      employeeId: event.employeeId,
    );

    result.fold(
      (error) {
        emit(AttendanceError(message: error));
        emit(currentState);
      },
      (record) {
        emit(currentState.copyWith(todayRecord: record));
        // Refresh dashboard to reflect check-out
        add(AttendanceDashboardRequested(employeeId: event.employeeId));
      },
    );
  }

  Future<void> _onDashboardRequested(
    AttendanceDashboardRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    final result = await _attendanceRepository.getDashboard(event.employeeId);
    
    result.fold(
      (error) {
        if (state is AttendanceLoaded) {
          // Keep current state if dashboard fetch fails
        } else {
          emit(AttendanceError(message: error));
        }
      },
      (data) {
        if (state is AttendanceLoaded) {
          emit((state as AttendanceLoaded).copyWith(dashboardData: data));
        } else {
          emit(AttendanceLoaded(
            records: const [],
            dashboardData: data,
          ));
        }
      },
    );
  }

  void _onReset(
    AttendanceResetRequested event,
    Emitter<AttendanceState> emit,
  ) {
    emit(const AttendanceInitial());
  }
}
