import 'package:flutter/services.dart';

import 'app_settings.dart';

class HapticService {
  HapticService(this._settings);

  final AppSettings _settings;

  Future<void> lightSuccess() async {
    if (!_settings.hapticsEnabled) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {
      // Platform may not support haptics.
    }
  }

  Future<void> heavyMistake() async {
    if (!_settings.hapticsEnabled) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }
}
