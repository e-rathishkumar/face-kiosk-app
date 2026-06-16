/// Background sync service — handles attendance upload and embedding download.
/// Implements idempotent sync with exponential backoff retry.
library;

import 'dart:async';
import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../core/constants.dart';
import '../data/database/edge_database.dart';

class SyncService {
  final Dio _dio;
  final EdgeDatabase _db;
  Timer? _syncTimer;
  Timer? _heartbeatTimer;
  bool _isSyncing = false;
  bool _isOnline = false;
  final String _deviceId;

  // Callbacks
  void Function(int count)? onEmbeddingsUpdated;
  void Function(bool online)? onConnectivityChanged;

  SyncService({
    required Dio dio,
    required EdgeDatabase db,
    required String deviceId,
  })  : _dio = dio,
        _db = db,
        _deviceId = deviceId;

  bool get isOnline => _isOnline;

  /// Start background sync loop.
  void start() {
    // Sync attendance every 30s
    _syncTimer = Timer.periodic(
      Duration(seconds: AppConstants.syncIntervalSeconds),
      (_) => syncAttendance(),
    );

    // Heartbeat every 60s
    _heartbeatTimer = Timer.periodic(
      Duration(seconds: AppConstants.heartbeatIntervalSeconds),
      (_) => sendHeartbeat(),
    );

    // Monitor connectivity
    Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      _isOnline = hasConnection;
      onConnectivityChanged?.call(hasConnection);
      if (hasConnection) {
        // Trigger immediate sync when connectivity returns
        syncAttendance();
      }
    });

    // Initial sync
    _checkConnectivity();
    syncAttendance();
  }

  void stop() {
    _syncTimer?.cancel();
    _heartbeatTimer?.cancel();
    _syncTimer = null;
    _heartbeatTimer = null;
  }

  /// Sync employee embeddings from server to local database.
  Future<int> syncEmployees() async {
    try {
      final response = await _dio.get(ApiConstants.syncEmployees);
      if (response.statusCode == 200) {
        final data = response.data;
        final employees = data['employees'] as List;

        for (final emp in employees) {
          await _db.upsertEmployee(emp);
          if (emp['embeddings'] != null) {
            await _db.upsertEmbeddings(
              emp['employee_id'] as String,
              emp['embeddings'] as List,
            );
          }
        }

        final count = employees.length;
        onEmbeddingsUpdated?.call(count);
        dev.log('Synced $count employees with embeddings');
        return count;
      }
    } catch (e) {
      dev.log('Employee sync failed: $e');
    }
    return 0;
  }

  /// Upload pending attendance records to server.
  Future<void> syncAttendance() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final records = await _db.getUnsyncedAttendance();
      if (records.isEmpty) {
        _isSyncing = false;
        return;
      }

      // Check connectivity first
      if (!await _hasConnectivity()) {
        _isSyncing = false;
        return;
      }

      final recordsList = records.map((r) {
        return {
          'idempotency_key': r['id'],
          'employee_id': r['employee_id'],
          'action': r['action'],
          'confidence': r['confidence'],
          'detected_at': r['detected_at'],
          'device_id': _deviceId,
        };
      }).toList();

      final payload = {
        'device_id': _deviceId,
        'records': recordsList,
      };

      final response = await _dio.post(
        ApiConstants.syncAttendance,
        data: payload,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final synced = data['synced'] as int;
        final errors = data['errors'] as List;

        // Mark successfully synced records
        final syncedIds = records
            .where((r) => !errors.any((e) => e['idempotency_key'] == r['id']))
            .map((r) => r['id'] as String)
            .toList();

        if (syncedIds.isNotEmpty) {
          await _db.markSynced(syncedIds);
        }

        // Update failed records
        for (final error in errors) {
          final id = error['idempotency_key'] as String;
          await _db.incrementSyncAttempt(id, error['error'] as String);
        }

        dev.log('Attendance sync: $synced synced, ${errors.length} errors');
      }
    } catch (e) {
      dev.log('Attendance sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Send device heartbeat for monitoring.
  Future<void> sendHeartbeat({double? temperature, int? queueDepth}) async {
    try {
      if (!await _hasConnectivity()) return;

      final depth = queueDepth ?? await _db.getQueueDepth();
      await _dio.post(ApiConstants.syncHeartbeat, data: {
        'device_id': _deviceId,
        'status': 'online',
        'temperature_celsius': temperature,
        'queue_depth': depth,
        'app_version': AppConstants.appVersion,
      });
    } catch (e) {
      dev.log('Heartbeat failed: $e');
    }
  }

  Future<bool> _hasConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      _isOnline = results.any((r) => r != ConnectivityResult.none);
      return _isOnline;
    } catch (_) {
      return false;
    }
  }

  Future<void> _checkConnectivity() async {
    await _hasConnectivity();
    onConnectivityChanged?.call(_isOnline);
  }
}
