import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/direction.dart';
import '../theme/app_theme.dart';

/// Single-cell arrow drawn with [CustomPainter] (navy stroke + head).
class ArrowWidget extends StatelessWidget {
  const ArrowWidget({
    super.key,
    required this.direction,
    this.size = 44,
    this.highlighted = false,
    this.pressed = false,
  });

  final Direction direction;
  final double size;
  final bool highlighted;
  final bool pressed;

  @override
  Widget build(BuildContext context) {
    final painter = CustomPaint(
      size: Size.square(size),
      painter: ArrowPathPainter(
        direction: direction,
        highlighted: highlighted,
        pressed: pressed,
      ),
    );
    if (!highlighted) return painter;
    return _HintPulse(child: painter);
  }
}

class ArrowPathPainter extends CustomPainter {
  ArrowPathPainter({
    required this.direction,
    required this.highlighted,
    required this.pressed,
  });

  final Direction direction;
  final bool highlighted;
  final bool pressed;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * (highlighted ? 0.22 : 0.18);
    final color = highlighted
        ? AppColors.cyan
        : (pressed ? AppColors.cyanDim : const Color(0xFF2A3550));

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final c = Offset(size.width / 2, size.height / 2);
    final half = size.shortestSide * 0.28;
    final tipReach = size.shortestSide * 0.38;

    late Offset start;
    late Offset tip;
    switch (direction) {
      case Direction.up:
        start = Offset(c.dx, c.dy + half);
        tip = Offset(c.dx, c.dy - tipReach);
      case Direction.down:
        start = Offset(c.dx, c.dy - half);
        tip = Offset(c.dx, c.dy + tipReach);
      case Direction.left:
        start = Offset(c.dx + half, c.dy);
        tip = Offset(c.dx - tipReach, c.dy);
      case Direction.right:
        start = Offset(c.dx - half, c.dy);
        tip = Offset(c.dx + tipReach, c.dy);
    }

    canvas.drawLine(start, tip, paint);

    // Arrow head
    final angle = math.atan2(tip.dy - start.dy, tip.dx - start.dx);
    final headLen = size.shortestSide * 0.22;
    final headAngle = 0.7;
    final left = Offset(
      tip.dx - headLen * math.cos(angle - headAngle),
      tip.dy - headLen * math.sin(angle - headAngle),
    );
    final right = Offset(
      tip.dx - headLen * math.cos(angle + headAngle),
      tip.dy - headLen * math.sin(angle + headAngle),
    );
    final head = Path()
      ..moveTo(left.dx, left.dy)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(right.dx, right.dy);
    canvas.drawPath(head, paint);

    if (highlighted) {
      final fill = Paint()
        ..color = AppColors.cyan.withValues(alpha: 0.18)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(c, size.shortestSide * 0.32, fill);
    }
  }

  @override
  bool shouldRepaint(covariant ArrowPathPainter oldDelegate) =>
      oldDelegate.direction != direction ||
      oldDelegate.highlighted != highlighted ||
      oldDelegate.pressed != pressed;
}

class _HintPulse extends StatefulWidget {
  const _HintPulse({required this.child});

  final Widget child;

  @override
  State<_HintPulse> createState() => _HintPulseState();
}

class _HintPulseState extends State<_HintPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_ctrl.value);
        final scale = 1 + t * 0.05;
        return Transform.scale(scale: scale, child: child);
      },
      child: widget.child,
    );
  }
}
