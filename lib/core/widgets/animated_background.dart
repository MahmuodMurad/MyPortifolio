import 'dart:math';
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _particles = List.generate(50, (_) => _Particle());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(color: AppColors.background),
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _ParticlePainter(_particles, _controller.value),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Particle {
  late double x;
  late double y;
  late double radius;
  late double speed;
  late double opacity;
  final Random _random = Random();

  _Particle() {
    _reset();
  }

  void _reset() {
    x = _random.nextDouble();
    y = _random.nextDouble();
    radius = _random.nextDouble() * 3 + 1;
    speed = _random.nextDouble() * 0.3 + 0.1;
    opacity = _random.nextDouble() * 0.4 + 0.1;
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final dx = p.x * size.width;
      final dy = ((p.y + progress * p.speed) % 1.0) * size.height;

      final paint = Paint()
        ..color = AppColors.accentPrimary.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dx, dy), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
