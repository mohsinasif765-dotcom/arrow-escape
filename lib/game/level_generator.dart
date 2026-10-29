import 'dart:math';

import '../models/arrow_piece.dart';
import '../models/direction.dart';
import '../models/grid_pos.dart';
import '../models/level_data.dart';
import 'level_solver.dart';
import 'path_rules.dart';

/// Seeded catalog builder for 30 validated Arrow Escape levels.
class LevelGenerator {
  LevelGenerator._();

  static const int catalogSize = 30;

  static List<LevelData> generateCatalog({int seed = 20261029}) {
    final rng = Random(seed);
    final levels = <LevelData>[];
    final seen = <String>{};

    for (var id = 1; id <= catalogSize; id++) {
      final level = _generateOne(id: id, rng: rng, seen: seen);
      levels.add(level);
      seen.add(PathRules.fingerprint(level.arrows));
    }

    if (levels.length != catalogSize) {
      throw StateError('Expected $catalogSize levels, got ${levels.length}');
    }
    return levels;
  }

  static LevelData _generateOne({
    required int id,
    required Random rng,
    required Set<String> seen,
  }) {
    final spec = _specFor(id);

    for (var attempt = 0; attempt < 1200; attempt++) {
      final arrowCount = spec.minArrows +
          (spec.maxArrows > spec.minArrows
              ? rng.nextInt(spec.maxArrows - spec.minArrows + 1)
              : 0);

      final arrows = _placeArrows(
        id: id,
        rows: spec.rows,
        cols: spec.cols,
        count: arrowCount,
        minLen: spec.minLen,
        maxLen: spec.maxLen,
        rng: rng,
      );
      if (arrows == null) continue;

      final level = LevelData(
        id: id,
        name: _nameFor(id),
        rows: spec.rows,
        cols: spec.cols,
        arrows: arrows,
      );

      if (!LevelSolver.isSolvable(level)) continue;

      final blocked = LevelSolver.initiallyBlockedCount(level);
      if (blocked < spec.minBlocked) continue;

      if (spec.requirePartialChallenge) {
        final free = arrows.length - blocked;
        if (free < 1) continue;
        if (blocked == 0) continue;
      }

      final fp = PathRules.fingerprint(arrows);
      if (seen.contains(fp)) continue;

      return level;
    }

    throw StateError('Failed to generate solvable unique level $id');
  }

  static List<ArrowPiece>? _placeArrows({
    required int id,
    required int rows,
    required int cols,
    required int count,
    required int minLen,
    required int maxLen,
    required Random rng,
  }) {
    final occupied = <String>{};
    final arrows = <ArrowPiece>[];

    for (var i = 0; i < count; i++) {
      ArrowPiece? piece;
      for (var attempt = 0; attempt < 80; attempt++) {
        final len = minLen +
            (maxLen > minLen ? rng.nextInt(maxLen - minLen + 1) : 0);
        piece = _growSnake(
          rows: rows,
          cols: cols,
          length: len,
          occupied: occupied,
          rng: rng,
          id: '${id}_${i + 1}',
        );
        if (piece != null) break;
      }
      if (piece == null) return null;
      for (final p in piece.cells) {
        occupied.add('${p.row},${p.col}');
      }
      arrows.add(piece);
    }
    return arrows;
  }

  /// Orthogonal snake of [length] cells; tip faces last step direction.
  static ArrowPiece? _growSnake({
    required int rows,
    required int cols,
    required int length,
    required Set<String> occupied,
    required Random rng,
    required String id,
  }) {
    final startRow = rng.nextInt(rows);
    final startCol = rng.nextInt(cols);
    if (occupied.contains('$startRow,$startCol')) return null;

    final cells = <GridPos>[GridPos(startRow, startCol)];
    final local = <String>{'$startRow,$startCol'};
    var facing = Direction.values[rng.nextInt(4)];

    for (var step = 1; step < length; step++) {
      final cur = cells.last;
      final dirs = List<Direction>.from(Direction.values)..shuffle(rng);
      GridPos? next;
      Direction? nextDir;
      for (final d in dirs) {
        final r = cur.row + d.rowDelta;
        final c = cur.col + d.colDelta;
        if (r < 0 || r >= rows || c < 0 || c >= cols) continue;
        final key = '$r,$c';
        if (occupied.contains(key) || local.contains(key)) continue;
        next = GridPos(r, c);
        nextDir = d;
        break;
      }
      if (next == null || nextDir == null) {
        if (cells.length == 1) return null;
        break;
      }
      cells.add(next);
      local.add('${next.row},${next.col}');
      facing = nextDir;
    }

    if (cells.isEmpty) return null;
    return ArrowPiece(id: id, cells: cells, direction: facing);
  }

  static _BandSpec _specFor(int id) {
    if (id <= 5) {
      return const _BandSpec(
        rows: 4,
        cols: 4,
        minArrows: 3,
        maxArrows: 5,
        minLen: 1,
        maxLen: 3,
        minBlocked: 1,
        requirePartialChallenge: true,
      );
    }
    if (id <= 15) {
      return const _BandSpec(
        rows: 5,
        cols: 5,
        minArrows: 5,
        maxArrows: 8,
        minLen: 2,
        maxLen: 4,
        minBlocked: 2,
        requirePartialChallenge: true,
      );
    }
    return const _BandSpec(
      rows: 6,
      cols: 6,
      minArrows: 6,
      maxArrows: 10,
      minLen: 2,
      maxLen: 5,
      minBlocked: 3,
      requirePartialChallenge: true,
    );
  }

  static String _nameFor(int id) {
    if (id <= 5) return 'Starter $id';
    if (id <= 15) return 'Pulse $id';
    return 'Gauntlet $id';
  }
}

class _BandSpec {
  const _BandSpec({
    required this.rows,
    required this.cols,
    required this.minArrows,
    required this.maxArrows,
    required this.minLen,
    required this.maxLen,
    required this.minBlocked,
    required this.requirePartialChallenge,
  });

  final int rows;
  final int cols;
  final int minArrows;
  final int maxArrows;
  final int minLen;
  final int maxLen;
  final int minBlocked;
  final bool requirePartialChallenge;
}
