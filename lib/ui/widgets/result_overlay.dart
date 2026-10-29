import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ResultOverlay extends StatefulWidget {
  const ResultOverlay({
    super.key,
    required this.won,
    required this.levelName,
    required this.onRestart,
    required this.onHome,
    this.onNext,
    this.onLevels,
  });

  final bool won;
  final String levelName;
  final VoidCallback onRestart;
  final VoidCallback onHome;
  final VoidCallback? onNext;
  final VoidCallback? onLevels;

  @override
  State<ResultOverlay> createState() => _ResultOverlayState();
}

class _ResultOverlayState extends State<ResultOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.86, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final won = widget.won;
    return FadeTransition(
      opacity: _fade,
      child: Material(
        color: Colors.black.withValues(alpha: 0.62),
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 360,
                maxHeight: MediaQuery.sizeOf(context).height * 0.9,
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: (won ? AppColors.cyan : AppColors.danger)
                        .withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (won ? AppColors.cyan : AppColors.danger)
                          .withValues(alpha: 0.2),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (won ? AppColors.cyan : AppColors.danger)
                              .withValues(alpha: 0.14),
                        ),
                        child: Icon(
                          won
                              ? Icons.emoji_events_rounded
                              : Icons.heart_broken_rounded,
                          size: 40,
                          color: won ? AppColors.cyan : AppColors.danger,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        won ? 'Level Complete!' : 'Game Over',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        won
                            ? 'Nice clear on ${widget.levelName}.'
                            : 'Out of lives on ${widget.levelName}.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (won && widget.onNext != null) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: widget.onNext,
                            child: const Text('Next Level'),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.onRestart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                won ? AppColors.cyanDim : AppColors.cyan,
                          ),
                          child: Text(won ? 'Replay' : 'Restart'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (widget.onLevels != null)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: widget.onLevels,
                                child: const Text('Levels'),
                              ),
                            ),
                          if (widget.onLevels != null)
                            const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: widget.onHome,
                              child: const Text('Home'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
