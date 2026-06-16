/// Thermal monitor — tracks device temperature and adjusts FPS.
/// Prevents overheating, thermal throttling, and battery damage.
library;

import 'dart:async';
import 'dart:developer' as dev;
import '../core/constants.dart';
import '../face/face_engine_service.dart';

enum ThermalState { normal, warm, hot, critical }

class ThermalMonitor {
  final FaceEngineService _engine;
  Timer? _timer;
  ThermalState _state = ThermalState.normal;
  double _temperature = 0.0;

  void Function(ThermalState state)? onStateChanged;

  ThermalMonitor({required FaceEngineService engine}) : _engine = engine;

  ThermalState get state => _state;
  double get temperature => _temperature;

  /// Get recommended detection interval based on thermal state.
  int get recommendedIntervalMs {
    switch (_state) {
      case ThermalState.normal:
        return AppConstants.detectionIntervalMs; // 2s
      case ThermalState.warm:
        return AppConstants.detectionIntervalMs * 2; // 4s
      case ThermalState.hot:
        return AppConstants.thermalCooldownMs; // 5s
      case ThermalState.critical:
        return 10000; // 10s — minimal operation
    }
  }

  void start() {
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _check());
    _check();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _check() async {
    _temperature = await _engine.getTemperature();
    if (_temperature < 0) return; // Temperature not available

    final oldState = _state;

    if (_temperature >= AppConstants.thermalCriticalCelsius) {
      _state = ThermalState.critical;
    } else if (_temperature >= AppConstants.thermalWarningCelsius) {
      _state = ThermalState.hot;
    } else if (_temperature >= AppConstants.thermalWarningCelsius - 5) {
      _state = ThermalState.warm;
    } else {
      _state = ThermalState.normal;
    }

    if (_state != oldState) {
      dev.log('Thermal state: $_state (${_temperature.toStringAsFixed(1)}°C)');
      onStateChanged?.call(_state);
    }
  }
}
