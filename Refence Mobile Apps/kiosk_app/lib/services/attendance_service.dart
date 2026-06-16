/// Attendance service — handles local attendance marking and queue management.
/// Fully offline-first: marks attendance locally, queues for cloud sync.
library;

import 'package:uuid/uuid.dart';
import '../data/database/edge_database.dart';
import '../face/face_engine_service.dart';

class AttendanceService {
  final EdgeDatabase _db;
  final _uuid = const Uuid();

  // Per-employee cooldown tracking (prevents repeat scans)
  final Map<String, DateTime> _cooldowns = {};
  static const _cooldownDuration = Duration(seconds: 60);

  AttendanceService({required EdgeDatabase db}) : _db = db;

  /// Check if employee is in cooldown period.
  bool isInCooldown(String employeeId) {
    final lastSeen = _cooldowns[employeeId];
    if (lastSeen == null) return false;
    return DateTime.now().difference(lastSeen) < _cooldownDuration;
  }

  /// Mark attendance locally. Returns the action taken.
  Future<AttendanceAction> markAttendance({
    required MatchResult match,
  }) async {
    if (isInCooldown(match.employeeId)) {
      return AttendanceAction(
        action: 'cooldown',
        employeeId: match.employeeId,
        employeeName: match.name,
      );
    }

    // Set cooldown
    _cooldowns[match.employeeId] = DateTime.now();

    // Determine action based on today's local records
    final recent = await _db.getRecentAttendance(limit: 50);
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);

    final todayRecords = recent
        .where((r) =>
            r['employee_id'] == match.employeeId &&
            (r['timestamp'] as String).startsWith(todayStr))
        .toList();

    String action;
    if (todayRecords.isEmpty) {
      action = 'check_in';
    } else {
      final lastAction = todayRecords.first['action'] as String;
      if (lastAction == 'check_in') {
        action = 'already_in';
      } else if (lastAction == 'check_out') {
        action = 'already_out';
      } else {
        action = 'check_in';
      }
    }

    // Only queue check_in and check_out for sync
    if (action == 'check_in' || action == 'check_out') {
      final id = _uuid.v4();

      // Add to sync queue
      await _db.enqueueAttendance(
        id: id,
        employeeId: match.employeeId,
        action: action,
        confidence: match.confidence,
      );

      // Add to local attendance log
      await _db.addLocalAttendance(
        id: id,
        employeeId: match.employeeId,
        employeeName: match.name,
        action: action,
        confidence: match.confidence,
      );
    }

    return AttendanceAction(
      action: action,
      employeeId: match.employeeId,
      employeeName: match.name,
      confidence: match.confidence,
    );
  }

  /// Force checkout for an employee.
  Future<AttendanceAction> forceCheckout(String employeeId, String employeeName) async {
    final id = _uuid.v4();

    await _db.enqueueAttendance(
      id: id,
      employeeId: employeeId,
      action: 'check_out',
      confidence: 1.0,
    );

    await _db.addLocalAttendance(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      action: 'check_out',
      confidence: 1.0,
    );

    _cooldowns[employeeId] = DateTime.now();

    return AttendanceAction(
      action: 'check_out',
      employeeId: employeeId,
      employeeName: employeeName,
    );
  }

  /// Force check-in again (after previous checkout in same day).
  Future<AttendanceAction> forceCheckin(String employeeId, String employeeName, {double confidence = 1.0}) async {
    final id = _uuid.v4();

    await _db.enqueueAttendance(
      id: id,
      employeeId: employeeId,
      action: 'check_in',
      confidence: confidence,
    );

    await _db.addLocalAttendance(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      action: 'check_in',
      confidence: confidence,
    );

    _cooldowns[employeeId] = DateTime.now();

    return AttendanceAction(
      action: 'check_in',
      employeeId: employeeId,
      employeeName: employeeName,
      confidence: confidence,
    );
  }

  /// Clear cooldown (for testing).
  void clearCooldown(String employeeId) {
    _cooldowns.remove(employeeId);
  }
}

class AttendanceAction {
  final String action;
  final String employeeId;
  final String employeeName;
  final double? confidence;

  AttendanceAction({
    required this.action,
    required this.employeeId,
    required this.employeeName,
    this.confidence,
  });
}
