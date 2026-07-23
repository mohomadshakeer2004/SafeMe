import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Plays bundled emergency alarm (works offline; no Firebase Storage).
class EmergencyAudioService {
  EmergencyAudioService._();

  static final EmergencyAudioService instance = EmergencyAudioService._();

  static const String _assetPath = 'sound/emergency.mp3';
  static const Duration defaultRingDuration = Duration(seconds: 5);

  final AudioPlayer _player = AudioPlayer();
  bool _configured = false;
  bool _playing = false;
  Timer? _stopTimer;

  bool get isPlaying => _playing;

  Future<void> init() async {
    if (_configured) return;
    await _player.setReleaseMode(ReleaseMode.release);
    await _player.setPlayerMode(PlayerMode.mediaPlayer);
    await _player.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.alarm,
          audioFocus: AndroidAudioFocus.gain,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );
    _player.onPlayerComplete.listen((_) {
      _playing = false;
      _stopTimer?.cancel();
      _stopTimer = null;
    });
    _configured = true;
  }

  /// Rings loudly for [duration] (default 5s), then stops. Does not loop forever.
  Future<void> playAlarm({
    bool loop = false,
    Duration duration = defaultRingDuration,
  }) async {
    try {
      await init();
      _stopTimer?.cancel();
      await _player.stop();
      await _player.setVolume(1.0);
      await _player.setReleaseMode(
        loop ? ReleaseMode.loop : ReleaseMode.release,
      );
      await _player.play(AssetSource(_assetPath), volume: 1.0);
      _playing = true;

      // Cap ring length so it never runs nonstop.
      _stopTimer = Timer(duration, () {
        unawaited(stop());
      });
    } catch (e) {
      _playing = false;
      debugPrint('Emergency alarm unavailable: $e');
    }
  }

  Future<void> stop() async {
    _stopTimer?.cancel();
    _stopTimer = null;
    try {
      await _player.setVolume(0);
      await _player.stop();
    } catch (_) {}
    _playing = false;
  }

  /// Fully mute + stop + settle so the mic does not pick up the siren.
  Future<void> stopForMicCapture({
    Duration settle = const Duration(milliseconds: 1200),
  }) async {
    try {
      await stop();
      await _player.setReleaseMode(ReleaseMode.release);
      // Extra silence so speaker hardware / room echo dies down.
      await Future<void>.delayed(settle);
    } catch (e) {
      debugPrint('Emergency alarm stopForMicCapture failed: $e');
    } finally {
      _playing = false;
    }
  }

  void dispose() {
    _stopTimer?.cancel();
    _player.dispose();
  }
}
