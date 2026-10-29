import 'package:flutter/foundation.dart';

import '../models/arrow_piece.dart';
import '../models/game_status.dart';
import '../models/level_data.dart';
import 'path_rules.dart';

/// Pure puzzle rules — no widgets.
class GameController extends ChangeNotifier {
  GameController(this._level) : _initialArrowCount = _level.arrows.length {
    restart();
  }

  LevelData _level;
  final List<ArrowPiece> _arrows = [];
  int _mistakes = 0;
  GameStatus _status = GameStatus.playing;
  String? _hintId;
  int _initialArrowCount;
  int _hintsRemaining = maxHintsPerLevel;

  static const int maxMistakes = 3;
  static const int maxHintsPerLevel = 3;

  LevelData get level => _level;
  List<ArrowPiece> get arrows => List.unmodifiable(_arrows);
  int get mistakes => _mistakes;
  GameStatus get status => _status;
  String? get hintId => _hintId;
  int get hintsRemaining => _hintsRemaining;
  bool get isPlaying => _status == GameStatus.playing;
  int get initialArrowCount => _initialArrowCount;
  int get remainingArrows => _arrows.length;
  double get clearProgress {
    if (_initialArrowCount == 0) return 1;
    return (_initialArrowCount - _arrows.length) / _initialArrowCount;
  }

  void loadLevel(LevelData level) {
    _level = level;
    restart();
  }

  void restart() {
    _arrows
      ..clear()
      ..addAll(_level.arrows.map((a) => a.copyWith()));
    _initialArrowCount = _level.arrows.length;
    _mistakes = 0;
    _status = GameStatus.playing;
    _hintId = null;
    _hintsRemaining = maxHintsPerLevel;
    notifyListeners();
  }

  /// Highlights one currently escapable arrow. Consumes a hint only on success.
  /// Returns the highlighted id, or null if none free / not playing / no hints left.
  String? showHint() {
    if (!isPlaying) return null;
    if (_hintsRemaining <= 0) {
      notifyListeners();
      return null;
    }

    final ids = escapableIds;
    if (ids.isEmpty) {
      _hintId = null;
      notifyListeners();
      return null;
    }

    _hintsRemaining--;
    _hintId = ids.first;
    notifyListeners();
    return _hintId;
  }

  void clearHint() {
    if (_hintId == null) return;
    _hintId = null;
    notifyListeners();
  }

  bool canEscape(ArrowPiece arrow) {
    return PathRules.canEscape(
      arrow: arrow,
      arrows: _arrows,
      rows: _level.rows,
      cols: _level.cols,
    );
  }

  List<String> get escapableIds => PathRules.escapable(
        arrows: _arrows,
        rows: _level.rows,
        cols: _level.cols,
      ).map((a) => a.id).toList();

  ArrowPiece? arrowAt(int row, int col) {
    for (final arrow in _arrows) {
      if (arrow.occupies(row, col)) return arrow;
    }
    return null;
  }

  /// On [TapResult.escaped], UI animates then calls [commitEscape].
  TapResult tryTap(String arrowId) {
    if (!isPlaying) return TapResult.ignored;

    final index = _arrows.indexWhere((a) => a.id == arrowId);
    if (index < 0) return TapResult.ignored;

    final arrow = _arrows[index];
    _hintId = null;
    if (canEscape(arrow)) {
      notifyListeners();
      return TapResult.escaped;
    }

    _mistakes++;
    if (_mistakes >= maxMistakes) {
      _status = GameStatus.lost;
    }
    notifyListeners();
    return TapResult.mistake;
  }

  void commitEscape(String arrowId) {
    if (_status == GameStatus.lost) return;
    final before = _arrows.length;
    _arrows.removeWhere((a) => a.id == arrowId);
    if (_arrows.length == before) return;
    _hintId = null;
    if (_arrows.isEmpty) {
      _status = GameStatus.won;
    }
    notifyListeners();
  }
}
