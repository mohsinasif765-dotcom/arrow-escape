import '../models/arrow_piece.dart';

/// Shared escape-path checks used by gameplay and the solver.
class PathRules {
  PathRules._();

  static bool occupied(List<ArrowPiece> arrows, int row, int col) {
    for (final arrow in arrows) {
      if (arrow.occupies(row, col)) return true;
    }
    return false;
  }

  /// Ray from tip in [arrow.direction] must be clear of other arrows.
  static bool canEscape({
    required ArrowPiece arrow,
    required List<ArrowPiece> arrows,
    required int rows,
    required int cols,
  }) {
    final others = [for (final a in arrows) if (a.id != arrow.id) a];
    var row = arrow.tip.row + arrow.direction.rowDelta;
    var col = arrow.tip.col + arrow.direction.colDelta;

    while (row >= 0 && row < rows && col >= 0 && col < cols) {
      if (occupied(others, row, col)) return false;
      row += arrow.direction.rowDelta;
      col += arrow.direction.colDelta;
    }
    return true;
  }

  static List<ArrowPiece> escapable({
    required List<ArrowPiece> arrows,
    required int rows,
    required int cols,
  }) {
    return [
      for (final arrow in arrows)
        if (canEscape(arrow: arrow, arrows: arrows, rows: rows, cols: cols))
          arrow,
    ];
  }

  static String fingerprint(List<ArrowPiece> arrows) {
    final parts = <String>[];
    for (final a in arrows) {
      final cells = a.cells.map((p) => '${p.row},${p.col}').join(';');
      parts.add('$cells>${a.direction.name}');
    }
    parts.sort();
    return parts.join('|');
  }
}
