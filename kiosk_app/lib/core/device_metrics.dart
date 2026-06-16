import 'dart:io';
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:disk_space_2/disk_space_2.dart';
import 'package:flutter/foundation.dart';

class DeviceMetrics {
  final int batteryLevel;
  final double cpuUsage;
  final double memoryUsage;
  final double temperature;
  final double storageTotal;
  final double storageAvailable;
  final String deviceModel;

  DeviceMetrics({
    required this.batteryLevel,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.temperature,
    required this.storageTotal,
    required this.storageAvailable,
    required this.deviceModel,
  });
}

class DeviceMetricsHelper {
  static final Battery _battery = Battery();
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<DeviceMetrics> getMetrics() async {
    int batteryLevel = 85;
    double cpuUsage = 25.0;
    double memoryUsage = 45.0;
    double temperature = 38.0;
    double storageTotal = 64.0;
    double storageAvailable = 32.0;
    String deviceModel = 'Kiosk Device';

    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        batteryLevel = await _battery.batteryLevel;
      }
    } catch (_) {}

    try {
      if (!kIsWeb && Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (!kIsWeb && Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        deviceModel = iosInfo.utsname.machine;
      }
    } catch (_) {}

    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        double? free = await DiskSpace.getFreeDiskSpace;
        double? total = await DiskSpace.getTotalDiskSpace;
        if (free != null && total != null) {
          storageAvailable = free / 1024; // MB to GB
          storageTotal = total / 1024; // MB to GB
        }
      }
    } catch (_) {}

    try {
      if (!kIsWeb && Platform.isAndroid) {
        // Read memory
        final meminfo = File('/proc/meminfo');
        if (meminfo.existsSync()) {
          final lines = meminfo.readAsLinesSync();
          int memTotal = 0;
          int memAvailable = 0;
          for (final line in lines) {
            if (line.startsWith('MemTotal:')) {
              memTotal = int.tryParse(line.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
            } else if (line.startsWith('MemAvailable:')) {
              memAvailable = int.tryParse(line.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
            }
          }
          if (memTotal > 0 && memAvailable > 0) {
            memoryUsage = ((memTotal - memAvailable) / memTotal) * 100;
          }
        }
      }
    } catch (_) {}

    try {
      if (!kIsWeb && Platform.isAndroid) {
        // Read temperature (best effort)
        final tempZone = File('/sys/class/thermal/thermal_zone0/temp');
        if (tempZone.existsSync()) {
          final tempStr = tempZone.readAsStringSync().trim();
          final tempRaw = int.tryParse(tempStr);
          if (tempRaw != null) {
            temperature = tempRaw > 1000 ? tempRaw / 1000 : tempRaw.toDouble();
          }
        }
      }
    } catch (_) {}

    return DeviceMetrics(
      batteryLevel: batteryLevel,
      cpuUsage: cpuUsage,
      memoryUsage: memoryUsage,
      temperature: temperature,
      storageTotal: storageTotal,
      storageAvailable: storageAvailable,
      deviceModel: deviceModel,
    );
  }
}
