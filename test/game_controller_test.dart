import 'package:flutter_test/flutter_test.dart';

import 'package:arrow_puzzle/data/levels.dart';
import 'package:arrow_puzzle/game/game_controller.dart';
import 'package:arrow_puzzle/models/arrow_piece.dart';
import 'package:arrow_puzzle/models/direction.dart';
import 'package:arrow_puzzle/models/game_status.dart';
import 'package:arrow_puzzle/models/grid_pos.dart';
import 'package:arrow_puzzle/models/level_data.dart';

void main() {
  LevelData clearLevel() => LevelData(
        id: 99,
        name: 'Clear',
        rows: 3,
        cols: 3,
        arrows: [
          ArrowPiece(
            id: 'a',
            cells: const [GridPos(1, 0)],
            direction: Direction.right,
          ),
        ],
      );

  LevelData blockedLevel() => LevelData(
        id: 98,
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
            direction: Direction.down,
          ),
        ],
      );

  LevelData bentLevel() => LevelData(
        id: 97,
        name: 'Bent',
        rows: 4,
        cols: 4,
        arrows: [
          ArrowPiece(
            id: 'snake',
            cells: const [
              GridPos(0, 0),
              GridPos(0, 1),
              GridPos(1, 1),
            ],
            direction: Direction.down,
          ),
        ],
      );

  test('clear path allows escape and completes level', () {
    final c = GameController(clearLevel());
    expect(c.canEscape(c.arrows.first), isTrue);
    expect(c.tryTap('a'), TapResult.escaped);
    c.commitEscape('a');
    expect(c.status, GameStatus.won);
    expect(c.arrows, isEmpty);
  });

  test('blocked path counts as a mistake', () {
    final c = GameController(blockedLevel());
    expect(c.canEscape(c.arrows.firstWhere((a) => a.id == 'a')), isFalse);
    expect(c.tryTap('a'), TapResult.mistake);
    expect(c.mistakes, 1);
    expect(c.status, GameStatus.playing);
    expect(c.arrows.length, 2);
  });

  test('three mistakes trigger game over', () {
    final c = GameController(blockedLevel());
    expect(c.tryTap('a'), TapResult.mistake);
    expect(c.tryTap('a'), TapResult.mistake);
    expect(c.tryTap('a'), TapResult.mistake);
    expect(c.mistakes, 3);
    expect(c.status, GameStatus.lost);
  });

  test('fourth tap after lose is ignored and mistakes stay at 3', () {
    final c = GameController(blockedLevel());
    c.tryTap('a');
    c.tryTap('a');
    c.tryTap('a');
    expect(c.tryTap('a'), TapResult.ignored);
    expect(c.mistakes, 3);
    expect(c.status, GameStatus.lost);
  });

  test('mistakes persist after a successful escape', () {
    final c = GameController(blockedLevel());
    expect(c.tryTap('a'), TapResult.mistake);
    expect(c.mistakes, 1);
    expect(c.tryTap('b'), TapResult.escaped);
    c.commitEscape('b');
    expect(c.mistakes, 1);
    expect(c.status, GameStatus.playing);
  });

  test('escaping blocker then blocked arrow completes level', () {
    final c = GameController(blockedLevel());
    expect(c.tryTap('b'), TapResult.escaped);
    c.commitEscape('b');
    expect(c.tryTap('a'), TapResult.escaped);
    c.commitEscape('a');
    expect(c.status, GameStatus.won);
  });

  test('bent polyline arrow escapes from tip', () {
    final c = GameController(bentLevel());
    expect(c.arrows.first.cells.length, 3);
    expect(c.canEscape(c.arrows.first), isTrue);
    expect(c.tryTap('snake'), TapResult.escaped);
    c.commitEscape('snake');
    expect(c.status, GameStatus.won);
  });

  test('sample of catalog levels solvable via GameController', () {
    for (final level in [allLevels.first, allLevels[14], allLevels.last]) {
      final c = GameController(level);
      var guard = 0;
      while (c.status == GameStatus.playing && guard < 200) {
        final ids = c.escapableIds;
        expect(
          ids,
          isNotEmpty,
          reason: 'Level ${level.id} stuck with ${c.arrows.length} left',
        );
        final id = ids.first;
        expect(c.tryTap(id), TapResult.escaped);
        c.commitEscape(id);
        guard++;
      }
      expect(c.status, GameStatus.won, reason: 'Level ${level.id}');
      expect(c.mistakes, 0);
    }
  });
}
