import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/device_metrics.dart';
import '../data/api_client.dart';

/// Periodically sends heartbeat data to the backend.
class HeartbeatService {
  final ApiClient _apiClient;
  final String kioskId;
  Timer? _timer;

  HeartbeatService({
    required ApiClient apiClient,
    required this.kioskId,
  }) : _apiClient = apiClient;

  void start() {
    _sendHeartbeat(); // Send immediately
    _timer = Timer.periodic(
      const Duration(seconds: AppConstants.heartbeatIntervalSeconds),
      (_) => _sendHeartbeat(),
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _sendHeartbeat() async {
    try {
      final metrics = await DeviceMetricsHelper.getMetrics();
      
      await _apiClient.sendHeartbeat(
        kioskId: kioskId,
        batteryLevel: metrics.batteryLevel,
        cpuUsage: metrics.cpuUsage,
        memoryUsage: metrics.memoryUsage,
        temperature: metrics.temperature,
        storageTotal: metrics.storageTotal,
        storageAvailable: metrics.storageAvailable,
        networkStrength: 4, // Network strength usually requires native implementation
        deviceModel: metrics.deviceModel,
        appVersion: AppConstants.appVersion,
      );
      debugPrint('[Heartbeat] Sent successfully with real metrics');
    } catch (e) {
      debugPrint('[Heartbeat] Failed: $e');
    }
  }
}
