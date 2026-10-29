import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'app_settings.dart';

class SoundService {
  SoundService(this._settings);

  final AppSettings _settings;
  final AudioPlayer _player = AudioPlayer();
  bool _ready = false;

  static const _escape = 'sounds/escape.wav';
  static const _invalid = 'sounds/invalid.wav';
  static const _victory = 'sounds/victory.wav';

  Future<void> init() async {
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      _ready = true;
    } catch (e, st) {
      _ready = false;
      debugPrint('SoundService init failed: $e\n$st');
    }
  }

  Future<void> playEscape() => _play(_escape);

  Future<void> playInvalid() => _play(_invalid);

  Future<void> playVictory() => _play(_victory);

  Future<void> _play(String asset) async {
    if (!_settings.soundEnabled || !_ready) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(asset));
    } catch (e) {
      debugPrint('SoundService play failed ($asset): $e');
    }
  }

  Future<void> dispose() async {
    try {
      await _player.dispose();
    } catch (_) {}
  }
}
