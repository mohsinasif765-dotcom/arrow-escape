import 'package:flutter/material.dart';

/// Light casual puzzle palette (GOGO-style reference).
class AppColors {
  static const Color bgDeep = Color(0xFF1E3A5F);
  static const Color bg = Color(0xFFF2F5F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF7FAFD);
  static const Color board = Color(0xFFFFFFFF);
  static const Color cell = Color(0xFFE8EEF6);
  static const Color cellEmpty = Color(0xFFEEF3F9);
  static const Color cellLine = Color(0xFFD5DEEA);
  static const Color ink = Color(0xFF2A3550);
  static const Color muted = Color(0xFF7A879C);
  static const Color cyan = Color(0xFF3B82F6);
  static const Color cyanBright = Color(0xFF60A5FA);
  static const Color cyanDim = Color(0xFF2563EB);
  static const Color navy = Color(0xFF1E3A5F);
  static const Color orange = Color(0xFFFF8A3D);
  static const Color orangeDeep = Color(0xFFF97316);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerSoft = Color(0xFFFCA5A5);
  static const Color success = Color(0xFF22C55E);
  static const Color accent = cyan;
}

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.cyan,
      brightness: Brightness.light,
      primary: AppColors.cyan,
      surface: AppColors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: 'Segoe UI',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontWeight: FontWeight.w900,
          color: AppColors.navy,
          fontSize: 48,
          letterSpacing: -1.4,
          height: 1.0,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
          fontSize: 26,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
          fontSize: 20,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          fontSize: 16,
        ),
        bodyLarge: TextStyle(
          color: AppColors.muted,
          fontSize: 16,
          height: 1.45,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          color: AppColors.muted,
          fontSize: 14,
          height: 1.4,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyan,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.cyan.withValues(alpha: 0.35),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.cellLine, width: 1.5),
          elevation: 2,
          shadowColor: Colors.black12,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  /// Kept for any legacy references; same as [light].
  static ThemeData get dark => light;
}

class GameBackdrop extends StatelessWidget {
  const GameBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF5F7FB),
            Color(0xFFEEF2F8),
            Color(0xFFE8EDF5),
          ],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          Positioned(
            top: -60,
            right: -40,
            child: _GlowBlob(
              size: 200,
              color: AppColors.cyan.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -50,
            child: _GlowBlob(
              size: 220,
              color: AppColors.orange.withValues(alpha: 0.07),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD5DEEA).withValues(alpha: 0.45)
      ..strokeWidth = 1;
    const step = 28.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
