import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'services/app_settings.dart';
import 'services/haptic_service.dart';
import 'services/sound_service.dart';
import 'ui/screens/home_screen.dart';
import 'ui/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.bg,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final settings = AppSettings();
  try {
    await settings.load();
  } catch (e) {
    debugPrint('AppSettings.load failed: $e');
  }
  final sound = SoundService(settings);
  await sound.init();
  final haptics = HapticService(settings);

  runApp(
    ArrowEscapeApp(
      settings: settings,
      sound: sound,
      haptics: haptics,
    ),
  );
}

class ArrowEscapeApp extends StatelessWidget {
  const ArrowEscapeApp({
    super.key,
    required this.settings,
    required this.sound,
    required this.haptics,
  });

  final AppSettings settings;
  final SoundService sound;
  final HapticService haptics;

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      settings: settings,
      child: _ServiceScope(
        sound: sound,
        haptics: haptics,
        child: ListenableBuilder(
          listenable: settings,
          builder: (context, _) {
            return MaterialApp(
              title: 'Arrow Escape',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              locale: settings.locale,
              supportedLocales: const [Locale('en'), Locale('ur')],
              home: const HomeScreen(),
            );
          },
        ),
      ),
    );
  }
}

class _ServiceScope extends InheritedWidget {
  const _ServiceScope({
    required this.sound,
    required this.haptics,
    required super.child,
  });

  final SoundService sound;
  final HapticService haptics;

  static _ServiceScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_ServiceScope>();
    assert(scope != null, 'ServiceScope not found');
    return scope!;
  }

  static SoundService soundOf(BuildContext context) => of(context).sound;

  static HapticService hapticsOf(BuildContext context) => of(context).haptics;

  @override
  bool updateShouldNotify(covariant _ServiceScope oldWidget) =>
      sound != oldWidget.sound || haptics != oldWidget.haptics;
}

/// Public accessors for services without exposing private class.
class AppServices {
  static SoundService sound(BuildContext context) =>
      _ServiceScope.soundOf(context);

  static HapticService haptics(BuildContext context) =>
      _ServiceScope.hapticsOf(context);
}
