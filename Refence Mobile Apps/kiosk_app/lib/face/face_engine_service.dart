/// Face recognition engine — Flutter ↔ Native ONNX Runtime bridge.
/// Handles embedding generation via platform channel and
/// cosine similarity matching against RAM-cached embeddings.
library;

import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../core/constants.dart';
import '../data/database/edge_database.dart';

class FaceEngineService {
  static const _channel = MethodChannel('com.siddhan.kiosk/face_engine');

  bool _initialized = false;
  Map<String, EmployeeEmbeddings> _embeddingCache = {};
  double _lastTemperature = 0.0;

  bool get isInitialized => _initialized;
  int get cachedEmployeeCount => _embeddingCache.length;
  double get lastTemperature => _lastTemperature;

  /// Initialize ONNX model on native side.
  Future<void> initialize({String? modelPath}) async {
    try {
      await _channel.invokeMethod('initModel', {'modelPath': modelPath});
      _initialized = true;
    } catch (e) {
      _initialized = false;
      rethrow;
    }
  }

  /// Load embeddings from SQLite into RAM cache.
  Future<int> loadEmbeddingsIntoCache() async {
    final db = EdgeDatabase.instance;
    _embeddingCache = await db.loadAllEmbeddings();
    return _embeddingCache.length;
  }

  /// Generate 512-d embedding from a face crop image.
  /// [imageBytes] should be a JPEG/PNG encoded face crop.
  Future<List<double>> generateEmbedding(Uint8List imageBytes, int width, int height) async {
    if (!_initialized) throw StateError('Face engine not initialized');

    final result = await _channel.invokeMethod<List>('generateEmbedding', {
      'imageBytes': imageBytes,
      'width': width,
      'height': height,
    });

    return result!.map((e) => (e as num).toDouble()).toList();
  }

  /// Match an embedding against the RAM cache.
  /// Returns the best match above threshold, or null.
  MatchResult? matchEmbedding(List<double> embedding) {
    if (_embeddingCache.isEmpty) return null;

    String? bestId;
    double bestSimilarity = 0.0;
    EmployeeEmbeddings? bestEmployee;

    for (final entry in _embeddingCache.entries) {
      final employee = entry.value;

      // Find best match across all embeddings for this employee
      double maxSim = 0.0;
      for (final stored in employee.embeddings) {
        final sim = _cosineSimilarity(embedding, stored);
        if (sim > maxSim) maxSim = sim;
      }

      if (maxSim > bestSimilarity) {
        bestSimilarity = maxSim;
        bestId = entry.key;
        bestEmployee = employee;
      }
    }

    if (bestSimilarity >= AppConstants.faceMatchThreshold && bestId != null && bestEmployee != null) {
      return MatchResult(
        employeeId: bestId,
        employeeCode: bestEmployee.employeeCode,
        name: bestEmployee.name,
        confidence: bestSimilarity,
        gender: bestEmployee.gender,
        photoUrl: bestEmployee.photoUrl,
        department: bestEmployee.department,
        designation: bestEmployee.designation,
        shiftName: bestEmployee.shiftName,
        shiftStartHour: bestEmployee.shiftStartHour,
        shiftStartMinute: bestEmployee.shiftStartMinute,
      );
    }

    return null;
  }

  /// Get device temperature for thermal monitoring.
  Future<double> getTemperature() async {
    try {
      _lastTemperature = await _channel.invokeMethod<double>('getTemperature') ?? -1.0;
    } catch (_) {
      _lastTemperature = -1.0;
    }
    return _lastTemperature;
  }

  /// Cosine similarity between two L2-normalized vectors.
  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0.0;
    double dot = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    final denominator = sqrt(normA) * sqrt(normB);
    if (denominator < 1e-10) return 0.0;
    return dot / denominator;
  }

  /// Dispose native resources.
  Future<void> dispose() async {
    try {
      await _channel.invokeMethod('dispose');
    } catch (_) {}
    _initialized = false;
    _embeddingCache.clear();
  }
}

class MatchResult {
  final String employeeId;
  final String employeeCode;
  final String name;
  final double confidence;
  final String? gender;
  final String? photoUrl;
  final String? department;
  final String? designation;
  final String shiftName;
  final int shiftStartHour;
  final int shiftStartMinute;

  MatchResult({
    required this.employeeId,
    required this.employeeCode,
    required this.name,
    required this.confidence,
    this.gender,
    this.photoUrl,
    this.department,
    this.designation,
    this.shiftName = 'Morning Shift',
    this.shiftStartHour = 9,
    this.shiftStartMinute = 0,
  });
}
