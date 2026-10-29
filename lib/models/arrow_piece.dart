import 'direction.dart';
import 'grid_pos.dart';

/// Polyline arrow: [cells] run tail → tip; [direction] is how the tip faces.
class ArrowPiece {
  const ArrowPiece({
    required this.id,
    required this.cells,
    required this.direction,
  }) : assert(cells.length > 0);

  final String id;
  final List<GridPos> cells;
  final Direction direction;

  GridPos get tip => cells.last;
  GridPos get tail => cells.first;
  int get row => tip.row;
  int get col => tip.col;

  bool occupies(int r, int c) {
    for (final p in cells) {
      if (p.row == r && p.col == c) return true;
    }
    return false;
  }

  ArrowPiece copyWith({
    String? id,
    List<GridPos>? cells,
    Direction? direction,
  }) {
    return ArrowPiece(
      id: id ?? this.id,
      cells: cells ?? List<GridPos>.from(this.cells),
      direction: direction ?? this.direction,
    );
  }
}
