import 'dart:math';

import 'package:flutter/widgets.dart';

import '../data/settings_storage.dart';

/// App-wide preferences: sound, haptics, profile, language.
class AppSettings extends ChangeNotifier {
  AppSettings();

  static const avatarChoices = <String>[
    '🦊',
    '🐱',
    '🐼',
    '🐯',
    '🐸',
    '🐧',
    '🦄',
    '🐲',
  ];

  static const randomNames = <String>[
    'Arrow',
    'Blink',
    'Nova',
    'Pixel',
    'Zig',
    'Dash',
    'Echo',
    'Mira',
    'Rex',
    'Luna',
    'Kai',
    'Sky',
  ];

  bool _soundEnabled = true;
  bool _hapticsEnabled = true;
  String _playerName = 'Player';
  int _avatarIndex = 0;
  String _localeCode = 'en';
  bool _loaded = false;

  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;
  String get playerName => _playerName;
  int get avatarIndex => _avatarIndex;
  String get localeCode => _localeCode;
  Locale get locale => Locale(_localeCode);
  String get avatarEmoji =>
      avatarChoices[_avatarIndex.clamp(0, avatarChoices.length - 1)];
  bool get isLoaded => _loaded;
  bool get isUrdu => _localeCode == 'ur';

  Future<void> load() async {
    _soundEnabled = await SettingsStorage.getSoundEnabled();
    _hapticsEnabled = await SettingsStorage.getHapticsEnabled();
    _playerName = await SettingsStorage.getPlayerName();
    _avatarIndex = await SettingsStorage.getAvatarIndex();
    _localeCode = await SettingsStorage.getLocaleCode();
    if (_localeCode != 'en' && _localeCode != 'ur') _localeCode = 'en';
    _loaded = true;
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    if (_soundEnabled == value) return;
    _soundEnabled = value;
    notifyListeners();
    await SettingsStorage.setSoundEnabled(value);
  }

  Future<void> setHapticsEnabled(bool value) async {
    if (_hapticsEnabled == value) return;
    _hapticsEnabled = value;
    notifyListeners();
    await SettingsStorage.setHapticsEnabled(value);
  }

  Future<void> setPlayerName(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == _playerName) return;
    _playerName = trimmed.length > 16 ? trimmed.substring(0, 16) : trimmed;
    notifyListeners();
    await SettingsStorage.setPlayerName(_playerName);
  }

  Future<void> setAvatarIndex(int value) async {
    final next = value % avatarChoices.length;
    if (next == _avatarIndex) return;
    _avatarIndex = next;
    notifyListeners();
    await SettingsStorage.setAvatarIndex(_avatarIndex);
  }

  Future<void> randomizeName() async {
    final pick = randomNames[Random().nextInt(randomNames.length)];
    await setPlayerName(pick);
  }

  Future<void> setLocaleCode(String code) async {
    if (code != 'en' && code != 'ur') return;
    if (code == _localeCode) return;
    _localeCode = code;
    notifyListeners();
    await SettingsStorage.setLocaleCode(code);
  }
}

/// Inherited access to [AppSettings].
class AppSettingsScope extends InheritedNotifier<AppSettings> {
  const AppSettingsScope({
    super.key,
    required AppSettings settings,
    required super.child,
  }) : super(notifier: settings);

  static AppSettings of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppSettingsScope>();
    assert(scope != null, 'AppSettingsScope not found');
    return scope!.notifier!;
  }

  static AppSettings read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppSettingsScope>();
    assert(scope != null, 'AppSettingsScope not found');
    return scope!.notifier!;
  }
}
