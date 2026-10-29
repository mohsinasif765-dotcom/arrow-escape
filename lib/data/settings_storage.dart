import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage {
  SettingsStorage._();

  static const _soundKey = 'sound_enabled';
  static const _hapticsKey = 'haptics_enabled';
  static const _nameKey = 'player_name';
  static const _avatarKey = 'avatar_index';
  static const _localeKey = 'locale_code';

  static Future<bool> getSoundEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_soundKey) ?? true;
    } catch (e) {
      debugPrint('SettingsStorage.getSoundEnabled failed: $e');
      return true;
    }
  }

  static Future<bool> getHapticsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_hapticsKey) ?? true;
    } catch (e) {
      debugPrint('SettingsStorage.getHapticsEnabled failed: $e');
      return true;
    }
  }

  static Future<String> getPlayerName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_nameKey) ?? 'Player';
    } catch (e) {
      debugPrint('SettingsStorage.getPlayerName failed: $e');
      return 'Player';
    }
  }

  static Future<int> getAvatarIndex() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_avatarKey) ?? 0;
    } catch (e) {
      debugPrint('SettingsStorage.getAvatarIndex failed: $e');
      return 0;
    }
  }

  static Future<String> getLocaleCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_localeKey) ?? 'en';
    } catch (e) {
      debugPrint('SettingsStorage.getLocaleCode failed: $e');
      return 'en';
    }
  }

  static Future<void> setSoundEnabled(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_soundKey, value);
    } catch (e) {
      debugPrint('SettingsStorage.setSoundEnabled failed: $e');
    }
  }

  static Future<void> setHapticsEnabled(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hapticsKey, value);
    } catch (e) {
      debugPrint('SettingsStorage.setHapticsEnabled failed: $e');
    }
  }

  static Future<void> setPlayerName(String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_nameKey, value);
    } catch (e) {
      debugPrint('SettingsStorage.setPlayerName failed: $e');
    }
  }

  static Future<void> setAvatarIndex(int value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_avatarKey, value);
    } catch (e) {
      debugPrint('SettingsStorage.setAvatarIndex failed: $e');
    }
  }

  static Future<void> setLocaleCode(String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, value);
    } catch (e) {
      debugPrint('SettingsStorage.setLocaleCode failed: $e');
    }
  }
}
