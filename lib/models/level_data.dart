import 'arrow_piece.dart';

class LevelData {
  const LevelData({
    required this.id,
    required this.name,
    required this.rows,
    required this.cols,
    required this.arrows,
  });

  final int id;
  final String name;
  final int rows;
  final int cols;
  final List<ArrowPiece> arrows;
}
