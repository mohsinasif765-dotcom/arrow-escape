import 'package:flutter_test/flutter_test.dart';

import 'package:arrow_puzzle/data/levels.dart';
import 'package:arrow_puzzle/game/level_generator.dart';
import 'package:arrow_puzzle/game/level_solver.dart';
import 'package:arrow_puzzle/game/path_rules.dart';

void main() {
  test('catalog has exactly 30 levels', () {
    expect(allLevels.length, LevelGenerator.catalogSize);
    expect(totalLevels, 30);
  });

  test('grid sizes match difficulty bands', () {
    for (final level in allLevels) {
      if (level.id <= 5) {
        expect(level.rows, 4, reason: 'Level ${level.id}');
        expect(level.cols, 4, reason: 'Level ${level.id}');
      } else if (level.id <= 15) {
        expect(level.rows, 5, reason: 'Level ${level.id}');
        expect(level.cols, 5, reason: 'Level ${level.id}');
      } else {
        expect(level.rows, 6, reason: 'Level ${level.id}');
        expect(level.cols, 6, reason: 'Level ${level.id}');
      }
    }
  });

  test('every level is solvable via LevelSolver', () {
    for (final level in allLevels) {
      final order = LevelSolver.solve(level);
      expect(
        order,
        isNotNull,
        reason: 'Level ${level.id} (${level.name}) has no solution',
      );
      expect(order!.length, level.arrows.length);
    }
  });

  test('no duplicate level fingerprints', () {
    final seen = <String>{};
    for (final level in allLevels) {
      final fp = PathRules.fingerprint(level.arrows);
      expect(
        seen.contains(fp),
        isFalse,
        reason: 'Duplicate layout at level ${level.id}',
      );
      seen.add(fp);
    }
  });

  test('ids are 1 through 30 contiguous', () {
    expect(allLevels.map((l) => l.id).toList(), [
      for (var i = 1; i <= 30; i++) i,
    ]);
  });

  test('regenerating with same seed matches catalog', () {
    final again = LevelGenerator.generateCatalog();
    expect(again.length, allLevels.length);
    for (var i = 0; i < again.length; i++) {
      expect(
        PathRules.fingerprint(again[i].arrows),
        PathRules.fingerprint(allLevels[i].arrows),
      );
    }
  });
}
