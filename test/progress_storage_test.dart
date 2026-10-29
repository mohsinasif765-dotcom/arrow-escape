import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_puzzle/data/progress_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to level 1 unlocked', () async {
    expect(await ProgressStorage.getHighestUnlocked(), 1);
  });

  test('completing a level unlocks the next', () async {
    await ProgressStorage.onLevelCompleted(1, 30);
    expect(await ProgressStorage.getHighestUnlocked(), 2);
    await ProgressStorage.onLevelCompleted(2, 30);
    expect(await ProgressStorage.getHighestUnlocked(), 3);
  });

  test('does not decrease unlock and clamps at total', () async {
    await ProgressStorage.onLevelCompleted(5, 30);
    expect(await ProgressStorage.getHighestUnlocked(), 6);
    await ProgressStorage.onLevelCompleted(3, 30);
    expect(await ProgressStorage.getHighestUnlocked(), 6);
    await ProgressStorage.onLevelCompleted(30, 30);
    expect(await ProgressStorage.getHighestUnlocked(), 30);
  });
}
