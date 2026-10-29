import 'package:flutter/material.dart';

import '../../data/levels.dart';
import '../../data/progress_storage.dart';
import '../../models/level_data.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  int _unlocked = 1;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final unlocked = await ProgressStorage.getHighestUnlocked();
    if (mounted) {
      setState(() {
        _unlocked = unlocked;
        _loading = false;
      });
    }
  }

  void _open(int id) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => GameScreen(levelId: id)))
        .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameBackdrop(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppColors.ink,
                    ),
                    Expanded(
                      child: Text(
                        'Select Level',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Text(
                      '$_unlocked / $totalLevels',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.cyan,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                child: Text(
                  'Beat a level to unlock the next one.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              if (_loading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    children: [
                      _Section(
                        title: 'Easy · 4×4',
                        levels: allLevels.where((l) => l.id <= 5).toList(),
                        unlocked: _unlocked,
                        onOpen: _open,
                      ),
                      const SizedBox(height: 18),
                      _Section(
                        title: 'Medium · 5×5',
                        levels:
                            allLevels.where((l) => l.id >= 6 && l.id <= 15).toList(),
                        unlocked: _unlocked,
                        onOpen: _open,
                      ),
                      const SizedBox(height: 18),
                      _Section(
                        title: 'Hard · 6×6',
                        levels: allLevels.where((l) => l.id >= 16).toList(),
                        unlocked: _unlocked,
                        onOpen: _open,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.levels,
    required this.unlocked,
    required this.onOpen,
  });

  final String title;
  final List<LevelData> levels;
  final int unlocked;
  final void Function(int id) onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.navy,
              ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.95,
          ),
          itemCount: levels.length,
          itemBuilder: (context, index) {
            final level = levels[index];
            final isUnlocked = level.id <= unlocked;
            return _LevelCard(
              id: level.id,
              name: level.name,
              unlocked: isUnlocked,
              onTap: isUnlocked ? () => onOpen(level.id) : null,
            );
          },
        ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.id,
    required this.name,
    required this.unlocked,
    this.onTap,
  });

  final int id;
  final String name;
  final bool unlocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: unlocked
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.cyan, AppColors.cyanDim],
                  )
                : null,
            color: unlocked ? null : AppColors.surfaceElevated,
            border: Border.all(
              color: unlocked
                  ? Colors.white.withValues(alpha: 0.2)
                  : AppColors.cellLine,
            ),
            boxShadow: unlocked
                ? [
                    BoxShadow(
                      color: AppColors.cyan.withValues(alpha: 0.28),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (unlocked)
                Text(
                  '$id',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                )
              else
                Icon(
                  Icons.lock_rounded,
                  color: AppColors.muted.withValues(alpha: 0.7),
                  size: 26,
                ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: unlocked
                        ? Colors.white.withValues(alpha: 0.9)
                        : AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
