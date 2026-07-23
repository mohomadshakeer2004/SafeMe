import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:safe_me/service/emergency_audio_service.dart';

/// Single app-wide shake listener (sensors_plus only — no stale [ShakeDetector] after hot reload).
class HomeShakeService {
  HomeShakeService._();

  static final HomeShakeService instance = HomeShakeService._();

  /// Detectable shake on a phone held in hand / pocket.
  static const double _shakeThresholdGravity = 2.1;
  static const int _shakeSlopMs = 350;
  static const int _shakeCountResetMs = 3500;
  static const int _shakesRequired = 3;
  static const int _cooldownMs = 4000;

  StreamSubscription<AccelerometerEvent>? _subscription;
  int _listenGeneration = 0;
  int _shakeTimestamp = 0;
  int _shakeCount = 0;
  int _lastTriggerMs = 0;

  VoidCallback? onTripleShake;

  bool get isListening => _subscription != null;

  void start() {
    stop();
    _listenGeneration++;
    final generation = _listenGeneration;
    _shakeCount = 0;
    _shakeTimestamp = DateTime.now().millisecondsSinceEpoch;

    _subscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.uiInterval,
    ).listen((event) {
      if (generation != _listenGeneration) return;
      _handleAccelerometer(event);
    }, onError: (Object e) {
      debugPrint('Shake accelerometer error: $e');
    });
    debugPrint('HomeShakeService: listening');
  }

  /// Stops accelerometer only — keeps [onTripleShake] so home tab can resume listening.
  void stop() {
    _listenGeneration++;
    _subscription?.cancel();
    _subscription = null;
    _shakeCount = 0;
  }

  void clearHandler() {
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
    debugPrint('********$_shakeCount (g=$gForce)');

    if (_shakeCount < _shakesRequired) return;

    _shakeCount = 0;
    if (now - _lastTriggerMs < _cooldownMs) {
      debugPrint('Shake trigger cooldown — skip');
      return;
    }
    _lastTriggerMs = now;
    _triggerEmergency();
  }

  void _triggerEmergency() {
    debugPrint('HomeShakeService: TRIPLE SHAKE — firing');
    unawaited(
      EmergencyAudioService.instance.playAlarm(
        duration: const Duration(seconds: 5),
      ),
    );
    final handler = onTripleShake;
    if (handler == null) {
      debugPrint('HomeShakeService: onTripleShake is NULL — rebind home handler');
      return;
    }
    handler();
  }
}
