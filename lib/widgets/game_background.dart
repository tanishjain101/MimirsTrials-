import 'package:flutter/material.dart';
import '../utils/colors.dart';

class GameBackground extends StatelessWidget {
  const GameBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.backgroundAlt,
                AppColors.background,
              ],
            ),
          ),
        ),
        Positioned(
          top: -120,
          left: -80,
          child: _GlowOrb(
            color: AppColors.secondary.withValues(alpha: 0.35),
            size: 220,
          ),
        ),
        Positioned(
          top: 120,
          right: -90,
          child: _GlowOrb(
            color: AppColors.primary.withValues(alpha: 0.25),
            size: 260,
          ),
        ),
        Positioned(
          bottom: -140,
          left: -40,
          child: _GlowOrb(
            color: AppColors.pink.withValues(alpha: 0.2),
            size: 240,
          ),
        ),
        const Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: StarfieldPainter(),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 120,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}

class StarfieldPainter extends CustomPainter {
  const StarfieldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final star in _stars) {
      paint.color = AppColors.text.withValues(alpha: star.opacity);
      canvas.drawCircle(
        Offset(size.width * star.x, size.height * star.y),
        star.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Star {
  final double x;
  final double y;
  final double radius;
  final double opacity;

  const _Star(this.x, this.y, this.radius, this.opacity);
}

const List<_Star> _stars = [
  _Star(0.12, 0.15, 1.5, 0.6),
  _Star(0.22, 0.32, 1.2, 0.5),
  _Star(0.18, 0.7, 1.0, 0.4),
  _Star(0.35, 0.2, 1.6, 0.6),
  _Star(0.4, 0.58, 1.2, 0.5),
  _Star(0.52, 0.12, 1.4, 0.5),
  _Star(0.62, 0.3, 1.8, 0.6),
  _Star(0.7, 0.6, 1.1, 0.4),
  _Star(0.82, 0.22, 1.3, 0.5),
  _Star(0.9, 0.42, 1.6, 0.6),
  _Star(0.1, 0.5, 1.1, 0.45),
  _Star(0.27, 0.86, 1.5, 0.55),
  _Star(0.46, 0.78, 1.0, 0.4),
  _Star(0.58, 0.9, 1.3, 0.5),
  _Star(0.76, 0.78, 1.2, 0.5),
  _Star(0.88, 0.9, 1.7, 0.6),
];
