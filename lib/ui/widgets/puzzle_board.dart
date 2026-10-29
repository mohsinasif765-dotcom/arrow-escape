import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../game/game_controller.dart';
import '../../models/arrow_piece.dart';
import '../../models/direction.dart';
import '../../models/game_status.dart';
import '../../models/grid_pos.dart';
import '../../services/haptic_service.dart';
import '../../services/sound_service.dart';
import '../theme/app_theme.dart';

class PuzzleBoard extends StatefulWidget {
  const PuzzleBoard({
    super.key,
    required this.controller,
    required this.sound,
    required this.haptics,
    this.showGrid = true,
    this.onStatusChanged,
  });

  final GameController controller;
  final SoundService sound;
  final HapticService haptics;
  final bool showGrid;
  final VoidCallback? onStatusChanged;

  @override
  State<PuzzleBoard> createState() => _PuzzleBoardState();
}

class _PuzzleBoardState extends State<PuzzleBoard>
    with TickerProviderStateMixin {
  bool _busy = false;
  String? _exitingId;
  String? _pressedId;
  double _exitTravel = 0;
  late final AnimationController _exitAnim;
  late final AnimationController _shakeAnim;

  GameController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _exitAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _shakeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _c.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant PuzzleBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChanged);
      widget.controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    _c.removeListener(_onChanged);
    _exitAnim.dispose();
    _shakeAnim.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _onTap(ArrowPiece arrow, double cell) async {
    if (_busy || !_c.isPlaying) return;
    setState(() {
      _busy = true;
      _pressedId = arrow.id;
    });
    await Future<void>.delayed(const Duration(milliseconds: 70));
    if (!mounted) return;
    setState(() => _pressedId = null);

    final result = _c.tryTap(arrow.id);
    if (result == TapResult.ignored) {
      setState(() => _busy = false);
      return;
    }

    if (result == TapResult.mistake) {
      await Future.wait([
        widget.haptics.heavyMistake(),
        widget.sound.playInvalid(),
      ]);
      if (!mounted) return;
      await _shakeAnim.forward(from: 0);
      if (!mounted) return;
      _shakeAnim.reset();
      widget.onStatusChanged?.call();
      setState(() => _busy = false);
      return;
    }

    await Future.wait([
      widget.haptics.lightSuccess(),
      widget.sound.playEscape(),
    ]);
    if (!mounted) return;
    setState(() {
      _exitingId = arrow.id;
      _exitTravel = _travel(arrow, cell);
    });
    await _exitAnim.forward(from: 0);
    if (!mounted) return;
    _c.commitEscape(arrow.id);
    _exitAnim.reset();
    setState(() {
      _exitingId = null;
      _exitTravel = 0;
      _busy = false;
    });
    widget.onStatusChanged?.call();
  }

  double _travel(ArrowPiece arrow, double cell) {
    // Pull far enough that the whole straightened thread clears the board.
    final body = math.max(1, arrow.cells.length) * cell;
    switch (arrow.direction) {
      case Direction.up:
        return (arrow.tip.row + 1.5) * cell + body;
      case Direction.down:
        return (_c.level.rows - arrow.tip.row + 0.5) * cell + body;
      case Direction.left:
        return (arrow.tip.col + 1.5) * cell + body;
      case Direction.right:
        return (_c.level.cols - arrow.tip.col + 0.5) * cell + body;
    }
  }

  void _handleTapDown(TapUpDetails details, double cell, double pad) {
    final local = details.localPosition;
    final col = ((local.dx - pad) / cell).floor();
    final row = ((local.dy - pad) / cell).floor();
    if (row < 0 ||
        col < 0 ||
        row >= _c.level.rows ||
        col >= _c.level.cols) {
      return;
    }
    final arrow = _c.arrowAt(row, col);
    if (arrow != null) _onTap(arrow, cell);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rows = _c.level.rows;
        final cols = _c.level.cols;
        final maxSide = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final boardSize = maxSide.clamp(0.0, 440.0);
        final pad = 10.0;
        final inner = boardSize - pad * 2;
        final cell = inner / (rows > cols ? rows : cols);
        final width = cell * cols + pad * 2;
        final height = cell * rows + pad * 2;

        final shake = TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0, end: -7), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -7, end: 7), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 7, end: -5), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -5, end: 0), weight: 1),
        ]).animate(CurvedAnimation(parent: _shakeAnim, curve: Curves.easeOut));

        return AnimatedBuilder(
          animation: Listenable.merge([_exitAnim, shake]),
          builder: (context, _) {
            final t = Curves.easeInCubic.transform(_exitAnim.value);
            return Transform.translate(
              offset: Offset(shake.value, 0),
              child: Center(
                child: RepaintBoundary(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (d) => _handleTapDown(d, cell, pad),
                    child: Container(
                      width: width,
                      height: height,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        size: Size(width, height),
                        painter: ArrowBoardPainter(
                          arrows: _c.arrows,
                          rows: rows,
                          cols: cols,
                          cell: cell,
                          pad: pad,
                          showGrid: widget.showGrid,
                          hintId: _c.hintId,
                          pressedId: _pressedId,
                          exitingId: _exitingId,
                          exitProgress: t,
                          exitTravel: _exitTravel,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Draws arrows as polylines; on escape, pulls them out as a straight thread.
class ArrowBoardPainter extends CustomPainter {
  ArrowBoardPainter({
    required this.arrows,
    required this.rows,
    required this.cols,
    required this.cell,
    required this.pad,
    required this.showGrid,
    required this.hintId,
    required this.pressedId,
    required this.exitingId,
    required this.exitProgress,
    required this.exitTravel,
  });

  final List<ArrowPiece> arrows;
  final int rows;
  final int cols;
  final double cell;
  final double pad;
  final bool showGrid;
  final String? hintId;
  final String? pressedId;
  final String? exitingId;
  final double exitProgress;
  final double exitTravel;

  Offset _center(GridPos p) => Offset(
        pad + (p.col + 0.5) * cell,
        pad + (p.row + 0.5) * cell,
      );

  Offset _dir(Direction d) => Offset(
        d.colDelta.toDouble(),
        d.rowDelta.toDouble(),
      );

  /// Resting polyline through cell centers (tail → tip nub).
  List<Offset> _bentPoints(ArrowPiece arrow) {
    final tip = _center(arrow.tip);
    final tipOut = tip + _dir(arrow.direction) * (cell * 0.32);
    if (arrow.cells.length == 1) {
      final tail = tip - _dir(arrow.direction) * (cell * 0.28);
      return [tail, tipOut];
    }
    return [
      for (final p in arrow.cells) _center(p),
      tipOut,
    ];
  }

  double _polyLength(List<Offset> pts) {
    var len = 0.0;
    for (var i = 1; i < pts.length; i++) {
      len += (pts[i] - pts[i - 1]).distance;
    }
    return len;
  }

  /// Track = bent cells path + long straight exit ray (train rails).
  List<Offset> _track(ArrowPiece arrow) {
    final bent = _bentPoints(arrow);
    final tipOut = bent.last;
    final far = tipOut + _dir(arrow.direction) * (exitTravel + _polyLength(bent) + cell);
    return [...bent, far];
  }

  List<double> _cumLen(List<Offset> pts) {
    final cum = <double>[0];
    for (var i = 1; i < pts.length; i++) {
      cum.add(cum.last + (pts[i] - pts[i - 1]).distance);
    }
    return cum;
  }

  Offset _pointAt(List<Offset> pts, List<double> cum, double s) {
    if (s <= 0) return pts.first;
    if (s >= cum.last) return pts.last;
    for (var i = 1; i < cum.length; i++) {
      if (s <= cum[i]) {
        final seg = cum[i] - cum[i - 1];
        final u = seg <= 0 ? 0.0 : (s - cum[i - 1]) / seg;
        return Offset.lerp(pts[i - 1], pts[i], u)!;
      }
    }
    return pts.last;
  }

  /// Slice of the track from [s0] to [s1] (train body on the rails).
  Path _pathOnTrack(List<Offset> pts, List<double> cum, double s0, double s1) {
    final path = Path();
    final a = s0.clamp(0.0, cum.last);
    final b = s1.clamp(0.0, cum.last);
    if (b <= a) {
      final p = _pointAt(pts, cum, a);
      path.moveTo(p.dx, p.dy);
      return path;
    }
    final start = _pointAt(pts, cum, a);
    path.moveTo(start.dx, start.dy);
    for (var i = 1; i < cum.length; i++) {
      if (cum[i] <= a) continue;
      if (cum[i - 1] >= b) break;
      if (cum[i] < b) {
        path.lineTo(pts[i].dx, pts[i].dy);
      } else {
        final end = _pointAt(pts, cum, b);
        path.lineTo(end.dx, end.dy);
        break;
      }
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (showGrid) {
      final grid = Paint()
        ..color = const Color(0xFFE2E8F0)
        ..strokeWidth = 1;
      for (var c = 1; c < cols; c++) {
        final x = pad + c * cell;
        canvas.drawLine(Offset(x, pad), Offset(x, pad + rows * cell), grid);
      }
      for (var r = 1; r < rows; r++) {
        final y = pad + r * cell;
        canvas.drawLine(Offset(pad, y), Offset(pad + cols * cell, y), grid);
      }
    }

    for (final arrow in arrows) {
      final exiting = arrow.id == exitingId;
      final highlighted = arrow.id == hintId || exiting;
      final pressed = arrow.id == pressedId;
      final t = exiting ? exitProgress : 0.0;
      final opacity = exiting ? (1 - t * 0.25).clamp(0.0, 1.0) : 1.0;

      final stroke = Paint()
        ..color = (highlighted
                ? AppColors.cyan
                : pressed
                    ? AppColors.cyanDim
                    : const Color(0xFF2A3550))
            .withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cell * (highlighted ? 0.055 : 0.04)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      late Offset tipOut;
      late Path path;

      if (exiting) {
        // Train on rails: body follows bent boxes then exit ray; rear leaves curves.
        final track = _track(arrow);
        final cum = _cumLen(track);
        final bent = _bentPoints(arrow);
        final bodyLen = _polyLength(bent);
        final tipS = bodyLen; // tip nub end index along track
        final headS = tipS + exitTravel * t;
        final tailS = (headS - bodyLen).clamp(0.0, cum.last);
        path = _pathOnTrack(track, cum, tailS, headS);
        tipOut = _pointAt(track, cum, headS);
      } else {
        final bent = _bentPoints(arrow);
        path = Path()..moveTo(bent.first.dx, bent.first.dy);
        for (var i = 1; i < bent.length; i++) {
          path.lineTo(bent[i].dx, bent[i].dy);
        }
        tipOut = bent.last;
      }

      canvas.drawPath(path, stroke);

      final angle = math.atan2(
        arrow.direction.rowDelta.toDouble(),
        arrow.direction.colDelta.toDouble(),
      );
      final headLen = cell * 0.12;
      final left = Offset(
        tipOut.dx - headLen * math.cos(angle - 0.7),
        tipOut.dy - headLen * math.sin(angle - 0.7),
      );
      final right = Offset(
        tipOut.dx - headLen * math.cos(angle + 0.7),
        tipOut.dy - headLen * math.sin(angle + 0.7),
      );
      canvas.drawPath(
        Path()
          ..moveTo(left.dx, left.dy)
          ..lineTo(tipOut.dx, tipOut.dy)
          ..lineTo(right.dx, right.dy),
        stroke,
      );

      if (highlighted && !exiting) {
        canvas.drawCircle(
          _center(arrow.tip),
          cell * 0.18,
          Paint()
            ..color = AppColors.cyan.withValues(alpha: 0.2)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant ArrowBoardPainter oldDelegate) =>
      oldDelegate.arrows != arrows ||
      oldDelegate.hintId != hintId ||
      oldDelegate.pressedId != pressedId ||
      oldDelegate.exitingId != exitingId ||
      oldDelegate.exitProgress != exitProgress ||
      oldDelegate.exitTravel != exitTravel ||
      oldDelegate.showGrid != showGrid ||
      oldDelegate.cell != cell;
}
