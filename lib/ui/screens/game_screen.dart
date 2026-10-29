import 'package:flutter/material.dart';

import '../../data/levels.dart';
import '../../data/progress_storage.dart';
import '../../game/game_controller.dart';
import '../../main.dart';
import '../../models/game_status.dart';
import '../theme/app_theme.dart';
import '../widgets/mistake_indicator.dart';
import '../widgets/puzzle_board.dart';
import '../widgets/result_overlay.dart';
import 'level_select_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.levelId});

  final int levelId;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController _controller;
  late int _levelId;
  bool _savedWin = false;
  bool _playedVictory = false;
  int _boardGeneration = 0;
  bool _showGrid = true;

  @override
  void initState() {
    super.initState();
    _levelId = widget.levelId;
    _controller = GameController(levelById(_levelId)!);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onStatusChanged() async {
    if (!mounted) return;
    if (_controller.status == GameStatus.won && !_savedWin) {
      _savedWin = true;
      if (!_playedVictory) {
        _playedVictory = true;
        try {
          await AppServices.sound(context).playVictory();
        } catch (e) {
          debugPrint('Victory sound failed: $e');
        }
      }
      try {
        await ProgressStorage.onLevelCompleted(_levelId, totalLevels);
      } catch (e) {
        debugPrint('Progress save failed: $e');
      }
    }
  }

  void _restart() {
    _savedWin = false;
    _playedVictory = false;
    _boardGeneration++;
    _controller.restart();
    setState(() {});
  }

  void _hint() {
    if (_controller.hintsRemaining <= 0) {
      _snack('No hints left this level.');
      return;
    }
    final before = _controller.hintsRemaining;
    final id = _controller.showHint();
    if (id == null) {
      if (_controller.hintsRemaining == before) {
        _snack('No free arrow right now — rethink the order.');
      } else {
        _snack('No hints left this level.');
      }
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _nextLevel() {
    final next = _levelId + 1;
    if (next > totalLevels) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _levelId = next;
      _savedWin = false;
      _playedVictory = false;
      _boardGeneration++;
      _controller.loadLevel(levelById(next)!);
    });
  }

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _goLevels() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final pad = width < 360 ? 10.0 : 14.0;
    final sound = AppServices.sound(context);
    final haptics = AppServices.haptics(context);

    return Scaffold(
      body: GameBackdrop(
        child: SafeArea(
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              final level = _controller.level;
              final showOverlay = _controller.status != GameStatus.playing;
              final progress = _controller.clearProgress;
              final pct = (progress * 100).round();

              return Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(pad, 8, pad, 0),
                        child: Row(
                          children: [
                            _CircleTool(
                              icon: Icons.chevron_left_rounded,
                              onTap: () => Navigator.of(context).pop(),
                            ),
                            const SizedBox(width: 8),
                            _HeaderPill(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Level',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                  Text(
                                    '${level.id}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.navy,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            MistakeIndicator(mistakes: _controller.mistakes),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _HeaderPill(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      '$pct%',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.navy,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 8,
                                        backgroundColor:
                                            const Color(0xFFE8EEF5),
                                        color: AppColors.cyanBright,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _CircleTool(
                              icon: Icons.refresh_rounded,
                              onTap: _restart,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: pad),
                          child: PuzzleBoard(
                            key: ValueKey(_boardGeneration),
                            controller: _controller,
                            sound: sound,
                            haptics: haptics,
                            showGrid: _showGrid,
                            onStatusChanged: _onStatusChanged,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(pad + 8, 12, pad + 8, 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _CircleTool(
                              icon: Icons.fit_screen_rounded,
                              onTap: () => _snack('Board fitted'),
                            ),
                            _CircleTool(
                              icon: Icons.grid_on_rounded,
                              active: _showGrid,
                              onTap: () =>
                                  setState(() => _showGrid = !_showGrid),
                            ),
                            _CircleTool(
                              icon: Icons.palette_outlined,
                              onTap: () => _snack('Theme follows app settings'),
                            ),
                            _HintTool(
                              remaining: _controller.hintsRemaining,
                              onTap: _hint,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (showOverlay)
                    ResultOverlay(
                      won: _controller.status == GameStatus.won,
                      levelName: level.name,
                      onRestart: _restart,
                      onHome: _goHome,
                      onLevels: _goLevels,
                      onNext: _levelId < totalLevels ? _nextLevel : null,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.child});

  final Widget child;

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
      child: child,
    );
  }
}

class _CircleTool extends StatelessWidget {
  const _CircleTool({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? const Color(0xFFE8F4FF) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.navy, size: 26),
        ),
      ),
    );
  }
}

class _HintTool extends StatelessWidget {
  const _HintTool({required this.remaining, required this.onTap});

  final int remaining;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _CircleTool(icon: Icons.lightbulb_outline_rounded, onTap: onTap),
        Positioned(
          right: -2,
          top: -2,
          child: Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.navy,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$remaining',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
