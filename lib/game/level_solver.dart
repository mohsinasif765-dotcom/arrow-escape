import '../models/level_data.dart';
import 'path_rules.dart';

/// Greedy escape solver for single-cell Arrow Escape boards.
class LevelSolver {
  LevelSolver._();

  /// Returns escape order of arrow ids, or null if unsolvable.
  static List<String>? solve(LevelData level) {
    final remaining = level.arrows.map((a) => a.copyWith()).toList();
    final order = <String>[];

    while (remaining.isNotEmpty) {
      final free = PathRules.escapable(
        arrows: remaining,
        rows: level.rows,
        cols: level.cols,
      );
      if (free.isEmpty) return null;
      free.sort((a, b) => a.id.compareTo(b.id));
      final pick = free.first;
      order.add(pick.id);
      remaining.removeWhere((a) => a.id == pick.id);
    }
    return order;
  }

  static bool isSolvable(LevelData level) => solve(level) != null;

  /// How many arrows are blocked in the initial layout.
  static int initiallyBlockedCount(LevelData level) {
    var blocked = 0;
    for (final arrow in level.arrows) {
      if (!PathRules.canEscape(
        arrow: arrow,
        arrows: level.arrows,
        rows: level.rows,
        cols: level.cols,
      )) {
        blocked++;
      }
    }
    return blocked;
  }
}
