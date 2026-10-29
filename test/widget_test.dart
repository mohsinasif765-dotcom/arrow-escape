import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arrow_puzzle/main.dart';
import 'package:arrow_puzzle/services/app_settings.dart';
import 'package:arrow_puzzle/services/haptic_service.dart';
import 'package:arrow_puzzle/services/sound_service.dart';

void main() {
  testWidgets('Home shows brand, Level play and Levels', (tester) async {
    final settings = AppSettings();
    final sound = SoundService(settings);
    final haptics = HapticService(settings);

    await tester.pumpWidget(
      ArrowEscapeApp(settings: settings, sound: sound, haptics: haptics),
    );
    expect(find.text('ARR'), findsOneWidget);
    expect(find.text('W'), findsOneWidget);
    expect(find.text('ESCAPE'), findsOneWidget);
    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text('Levels'), findsOneWidget);
    expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
  });
}
