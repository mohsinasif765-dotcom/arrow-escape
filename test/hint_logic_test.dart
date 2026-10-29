import 'package:flutter_test/flutter_test.dart';

import 'package:arrow_puzzle/game/game_controller.dart';
import 'package:arrow_puzzle/models/arrow_piece.dart';
import 'package:arrow_puzzle/models/direction.dart';
import 'package:arrow_puzzle/models/grid_pos.dart';
import 'package:arrow_puzzle/models/level_data.dart';

void main() {
  LevelData openLevel() => LevelData(
        id: 1,
        name: 'Open',
        rows: 3,
        cols: 3,
        arrows: [
          ArrowPiece(
            id: 'a',
            cells: const [GridPos(0, 0)],
            direction: Direction.up,
          ),
          ArrowPiece(
            id: 'b',
            cells: const [GridPos(0, 2)],
            direction: Direction.up,
          ),
          ArrowPiece(
            id: 'c',
            cells: const [GridPos(2, 1)],
            direction: Direction.down,
          ),
        ],
      );

  LevelData blockedOnlyLevel() => LevelData(
        id: 2,
        name: 'Blocked',
        rows: 3,
        cols: 3,
        arrows: [
          ArrowPiece(
            id: 'a',
            cells: const [GridPos(1, 0)],
            direction: Direction.right,
          ),
          ArrowPiece(
            id: 'b',
            cells: const [GridPos(1, 2)],
            direction: Direction.left,
          ),
        ],
      );

  test('hint id is always currently escapable', () {
    final c = GameController(openLevel());
    final id = c.showHint();
    expect(id, isNotNull);
    expect(c.escapableIds, contains(id));
    expect(c.hintId, id);
  });

  test('hint is not consumed when no escapable arrow', () {
    final c = GameController(blockedOnlyLevel());
    expect(c.escapableIds, isEmpty);
    expect(c.hintsRemaining, GameController.maxHintsPerLevel);
    expect(c.showHint(), isNull);
    expect(c.hintsRemaining, GameController.maxHintsPerLevel);
  });

  test('at most 3 successful hints per level', () {
    final c = GameController(openLevel());
    expect(c.showHint(), isNotNull);
    expect(c.hintsRemaining, 2);
    expect(c.showHint(), isNotNull);
    expect(c.hintsRemaining, 1);
    expect(c.showHint(), isNotNull);
    expect(c.hintsRemaining, 0);
    expect(c.showHint(), isNull);
    expect(c.hintsRemaining, 0);
  });

  test('restart restores hint count', () {
    final c = GameController(openLevel());
    c.showHint();
    c.showHint();
    expect(c.hintsRemaining, 1);
    c.restart();
    expect(c.hintsRemaining, GameController.maxHintsPerLevel);
    expect(c.hintId, isNull);
  });
}
