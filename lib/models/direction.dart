import 'dart:math' as math;

enum Direction {
  up,
  right,
  down,
  left;

  int get rowDelta => switch (this) {
        Direction.up => -1,
        Direction.down => 1,
        Direction.left || Direction.right => 0,
      };

  int get colDelta => switch (this) {
        Direction.left => -1,
        Direction.right => 1,
        Direction.up || Direction.down => 0,
      };

  /// Rotation for [Icons.arrow_upward] (points up at angle 0).
  double get iconRotationRadians => switch (this) {
        Direction.up => 0,
        Direction.right => math.pi / 2,
        Direction.down => math.pi,
        Direction.left => -math.pi / 2,
      };
}
