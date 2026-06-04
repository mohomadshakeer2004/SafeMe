import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:safe_me/service/emergency_audio_service.dart';

/// Single app-wide shake listener (sensors_plus only — no stale [ShakeDetector] after hot reload).
class HomeShakeService {
  HomeShakeService._();

  static final HomeShakeService instance = HomeShakeService._();

  static const double _shakeThresholdGravity = 2.7;
  static const int _shakeSlopMs = 500;
  static const int _shakeCountResetMs = 3000;
  static const int _shakesRequired = 3;

  StreamSubscription<AccelerometerEvent>? _subscription;
  int _listenGeneration = 0;
  int _shakeTimestamp = 0;
  int _shakeCount = 0;

  VoidCallback? onTripleShake;

  bool get isListening => _subscription != null;

  void start() {
    stop();
    _listenGeneration++;
    final generation = _listenGeneration;
    _shakeCount = 0;
    _shakeTimestamp = DateTime.now().millisecondsSinceEpoch;

    _subscription = accelerometerEventStream().listen((event) {
      if (generation != _listenGeneration) return;
      _handleAccelerometer(event);
    });
  }

  void stop() {
    _listenGeneration++;
    _subscription?.cancel();
    _subscription = null;
    _shakeCount = 0;
    onTripleShake = null;
  }

  void _handleAccelerometer(AccelerometerEvent event) {
    final gX = event.x / 9.80665;
    final gY = event.y / 9.80665;
    final gZ = event.z / 9.80665;
    final gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

    if (gForce <= _shakeThresholdGravity) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (_shakeTimestamp + _shakeSlopMs > now) return;

    if (_shakeTimestamp + _shakeCountResetMs < now) {
      _shakeCount = 0;
    }

    _shakeTimestamp = now;
    _shakeCount++;
    debugPrint('********$_shakeCount');

    if (_shakeCount < _shakesRequired) return;

    _shakeCount = 0;
    _triggerEmergency();
  }

  void _triggerEmergency() {
    EmergencyAudioService.instance.playAlarm();
    onTripleShake?.call();
  }
}
