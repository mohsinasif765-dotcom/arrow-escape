import 'package:flutter/material.dart';

import '../../data/levels.dart';
import '../../data/progress_storage.dart';
import '../../services/app_settings.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/settings_popup.dart';
import 'game_screen.dart';
import 'level_select_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  int _unlocked = 1;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _load();
  }

  Future<void> _load() async {
    final unlocked = await ProgressStorage.getHighestUnlocked();
    if (mounted) setState(() => _unlocked = unlocked);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _play() {
    final id = _unlocked.clamp(1, totalLevels);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => GameScreen(levelId: id)))
        .then((_) => _load());
  }

  void _levels() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const LevelSelectScreen()))
        .then((_) => _load());
  }

  void _settings() => SettingsPopup.show(context);

  void _comingSoon(String feature) {
    final s = AppStrings(AppSettingsScope.of(context));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — ${s.comingSoon}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width < 360 ? 14.0 : 20.0;
    final playLevel = _unlocked.clamp(1, totalLevels);
    final settings = AppSettingsScope.of(context);
    final strings = AppStrings(settings);

    return Scaffold(
      body: GameBackdrop(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontal),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _CrownChip(count: _unlocked),
                            const Spacer(),
                            _SettingsChip(onTap: _settings),
                          ],
                        ),
                        const Spacer(flex: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _SideQuests(
                              label: strings.quests,
                              onTap: () => _comingSoon(strings.quests),
                            ),
                            Expanded(
                              child: AnimatedBuilder(
                                animation: _pulse,
                                builder: (context, child) {
                                  final s = 1 + _pulse.value * 0.02;
                                  return Transform.scale(
                                    scale: s,
                                    child: child,
                                  );
                                },
                                child: const _BrandLogo(),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _SideDaily(
                                  onTap: () => _comingSoon('Daily'),
                                ),
                                const SizedBox(height: 18),
                                _SideRank(
                                  rank: _unlocked.clamp(1, 99),
                                  onTap: () => _comingSoon('Leaderboard'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(flex: 3),
                        _PrimaryPlayButton(
                          label: '${strings.level} $playLevel',
                          onPressed: _play,
                        ),
                        const SizedBox(height: 14),
                        _SecondaryLevelsButton(
                          label: strings.levels,
                          onPressed: _levels,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$_unlocked / $totalLevels ${strings.unlocked}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CrownChip extends StatelessWidget {
  const _CrownChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.workspace_premium_rounded, color: Colors.amber.shade600, size: 28),
        const SizedBox(width: 4),
        Text(
          'x$count',
          style: TextStyle(
            color: Colors.orange.shade700,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

class _SettingsChip extends StatelessWidget {
  const _SettingsChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFE8F4FF),
            border: Border.all(color: AppColors.cellLine),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.settings_rounded,
            color: AppColors.cyan,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _SideQuests extends StatelessWidget {
  const _SideQuests({required this.onTap, required this.label});

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return _SideTap(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFB347), Color(0xFFFF8A3D)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(color: Colors.white, width: 2.5),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.description_rounded, color: Colors.white, size: 34),
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.amber.shade200,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _SideDaily extends StatelessWidget {
  const _SideDaily({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SideTap(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFFE53935),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Column(
              children: [
                const SizedBox(height: 5),
                Container(
                  width: 40,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: Color(0xFFFFB300),
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '12:31:47',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _SideRank extends StatelessWidget {
  const _SideRank({required this.rank, required this.onTap});

  final int rank;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SideTap(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 64,
            height: 48,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  left: 4,
                  bottom: 0,
                  child: _PodiumBar(height: 22, color: const Color(0xFFFFC107), label: '2'),
                ),
                Positioned(
                  right: 4,
                  bottom: 0,
                  child: _PodiumBar(height: 18, color: const Color(0xFF42A5F5), label: '3'),
                ),
                Positioned(
                  bottom: 0,
                  child: _PodiumBar(height: 30, color: const Color(0xFFEF5350), label: '1'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '# $rank',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFD6EBFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '22:24:32',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 10,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumBar extends StatelessWidget {
  const _PodiumBar({
    required this.height,
    required this.color,
    required this.label,
  });

  final double height;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _SideTap extends StatelessWidget {
  const _SideTap({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: child,
        ),
      ),
    );
  }
}

/// GOGO-style wordmark: ARROW with arrow badge in the O, then ESCAPE.
class _BrandLogo extends StatelessWidget {
  const _BrandLogo();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = width < 360 ? 34.0 : 42.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'ARR',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navy,
                  letterSpacing: -1.5,
                  height: 1,
                ),
              ),
              _ArrowOBadge(size: titleSize * 0.92),
              Text(
                'W',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navy,
                  letterSpacing: -1.5,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'ESCAPE',
          style: TextStyle(
            fontSize: width < 360 ? 15 : 18,
            fontWeight: FontWeight.w800,
            color: AppColors.cyan,
            letterSpacing: 5,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _ArrowOBadge extends StatelessWidget {
  const _ArrowOBadge({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cyanBright, AppColors.cyanDim],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyan.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Icon(
        Icons.arrow_upward_rounded,
        color: Colors.white,
        size: size * 0.52,
      ),
    );
  }
}

class _PrimaryPlayButton extends StatelessWidget {
  const _PrimaryPlayButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Ink(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.cyanBright, AppColors.cyanDim],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cyan.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryLevelsButton extends StatelessWidget {
  const _SecondaryLevelsButton({
    required this.onPressed,
    required this.label,
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Ink(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.orange, AppColors.orangeDeep],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
