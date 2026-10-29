import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressStorage {
  ProgressStorage._();

  static const _key = 'highest_unlocked_level';

  static Future<int> getHighestUnlocked() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_key) ?? 1;
    } catch (e) {
      debugPrint('ProgressStorage.getHighestUnlocked failed: $e');
      return 1;
    }
  }

  static Future<void> onLevelCompleted(int completedId, int total) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_key) ?? 1;
      final unlockTo = (completedId + 1).clamp(1, total);
      if (unlockTo > current) {
        await prefs.setInt(_key, unlockTo);
      }
    } catch (e) {
      debugPrint('ProgressStorage.onLevelCompleted failed: $e');
    }
  }
}
