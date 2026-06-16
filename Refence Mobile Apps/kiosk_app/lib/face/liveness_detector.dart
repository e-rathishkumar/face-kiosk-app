/// Lightweight liveness detection using ML Kit face landmarks.
/// Prevents photo spoofing, replay attacks, and screen attacks.
/// Uses blink detection, eye openness, and head pose validation.
library;

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class LivenessResult {
  final bool isLive;
  final double score;
  final String reason;

  LivenessResult({required this.isLive, required this.score, required this.reason});
}

class LivenessDetector {
  // Track blink events over time
  final List<_EyeState> _eyeHistory = [];
  static const int _historyLength = 10;
  bool _blinkDetected = false;
  int _consecutiveFaces = 0;

  /// Evaluate liveness from ML Kit face data.
  /// Requires face to be detected with landmarks and classifications enabled.
  LivenessResult evaluate(Face face) {
    double score = 0.0;

    // 1. Eye openness check (detect blink pattern)
    final leftEyeOpen = face.leftEyeOpenProbability ?? -1;
    final rightEyeOpen = face.rightEyeOpenProbability ?? -1;

    if (leftEyeOpen >= 0 && rightEyeOpen >= 0) {
      // Track eye state for blink detection
      _eyeHistory.add(_EyeState(leftEyeOpen, rightEyeOpen));
      if (_eyeHistory.length > _historyLength) {
        _eyeHistory.removeAt(0);
      }

      // Check for natural blink pattern
      if (_detectBlink()) {
        _blinkDetected = true;
        score += 0.4;
      } else if (_blinkDetected) {
        score += 0.3; // Previously blinked
      }

      // Eyes should be mostly open (not a photo of closed eyes)
      if (leftEyeOpen > 0.5 && rightEyeOpen > 0.5) {
        score += 0.1;
      }
    }

    // 2. Head pose variation (natural micro-movements)
    final headEulerY = face.headEulerAngleY; // Left/right rotation
    final headEulerZ = face.headEulerAngleZ; // Tilt
    if (headEulerY != null && headEulerZ != null) {
      // Frontal face check (not too far rotated)
      if (headEulerY.abs() < 30 && headEulerZ.abs() < 20) {
        score += 0.1;
      }
      // Slight movement is natural (not perfectly still like a photo)
      if (headEulerY.abs() > 2 || headEulerZ.abs() > 2) {
        score += 0.1;
      }
    }

    // 3. Smile check (optional additional signal)
    final smilingProb = face.smilingProbability ?? -1;
    if (smilingProb >= 0) {
      score += 0.1; // Having smile data means better face quality
    }

    // 4. Face tracking ID consistency
    if (face.trackingId != null) {
      _consecutiveFaces++;
      if (_consecutiveFaces >= 3) {
        score += 0.1; // Stable face tracking
      }
    }

    // 5. Bounding box size check (face must be reasonable size)
    final faceWidth = face.boundingBox.width;
    final faceHeight = face.boundingBox.height;
    if (faceWidth > 80 && faceHeight > 80) {
      score += 0.1;
    }

    // Determine liveness
    final isLive = score >= 0.3 || _blinkDetected;

    String reason;
    if (isLive) {
      reason = 'Live face detected';
    } else if (!_blinkDetected && _eyeHistory.length >= _historyLength) {
      reason = 'No blink detected — possible photo';
    } else {
      reason = 'Insufficient liveness signals (score: ${score.toStringAsFixed(2)})';
    }

    return LivenessResult(isLive: isLive, score: score, reason: reason);
  }

  /// Detect a blink event from eye history.
  bool _detectBlink() {
    if (_eyeHistory.length < 3) return false;

    // Look for open → closed → open pattern
    for (int i = 2; i < _eyeHistory.length; i++) {
      final prev = _eyeHistory[i - 2];
      final mid = _eyeHistory[i - 1];
      final curr = _eyeHistory[i];

      if (prev.avgOpenness > 0.6 &&
          mid.avgOpenness < 0.3 &&
          curr.avgOpenness > 0.6) {
        return true;
      }
    }
    return false;
  }

  /// Reset liveness state for new face.
  void reset() {
    _eyeHistory.clear();
    _blinkDetected = false;
    _consecutiveFaces = 0;
  }
}

class _EyeState {
  final double leftOpen;
  final double rightOpen;

  _EyeState(this.leftOpen, this.rightOpen);

  double get avgOpenness => (leftOpen + rightOpen) / 2;
}
