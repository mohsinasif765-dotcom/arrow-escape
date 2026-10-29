import 'package:flutter/material.dart';

import '../../game/game_controller.dart';
import '../theme/app_theme.dart';

/// Lives as gradient up-arrows (reference style).
class MistakeIndicator extends StatelessWidget {
  const MistakeIndicator({
    super.key,
    required this.mistakes,
    this.maxMistakes = GameController.maxMistakes,
  });

  final int mistakes;
  final int maxMistakes;

  static const _alive = [
    Color(0xFFE53935),
    Color(0xFFFF8A3D),
    Color(0xFFFFC107),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(maxMistakes, (index) {
          final lost = index < mistakes;
          final color = lost
              ? AppColors.muted.withValues(alpha: 0.35)
              : _alive[index.clamp(0, _alive.length - 1)];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: AnimatedOpacity(
              opacity: lost ? 0.35 : 1,
              duration: const Duration(milliseconds: 180),
              child: Icon(
                Icons.arrow_upward_rounded,
                color: color,
                size: 22,
              ),
            ),
          );
        }),
      ),
    );
  }
}
