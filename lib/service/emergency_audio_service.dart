import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Plays bundled emergency alarm (works offline; no Firebase Storage).
class EmergencyAudioService {
  EmergencyAudioService._();

  static final EmergencyAudioService instance = EmergencyAudioService._();

  static const String _assetPath = 'sound/emergency.mp3';

  final AudioPlayer _player = AudioPlayer();
  bool _configured = false;

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
    _configured = true;
  }

  Future<void> playAlarm() async {
    try {
      await init();
      await _player.stop();
      await _player.play(AssetSource(_assetPath), volume: 1.0);
    } catch (e) {
      debugPrint('Emergency alarm unavailable: $e');
    }
  }

  Future<void> stop() => _player.stop();

  void dispose() {
    _player.dispose();
  }
}
