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
  late final AnimationController _controller;
  late final List<_Track> _tracks;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    final random = Random(12);
    _tracks = List.generate(18, (_) => _Track(random));
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
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.background,
                  AppColors.ink,
                  AppColors.backgroundAlt,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _CircuitBackgroundPainter(
                  progress: _controller.value,
                  tracks: _tracks,
                ),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Track {
  final double y;
  final double width;
  final double speed;
  final Color color;

  _Track(Random random)
    : y = random.nextDouble(),
      width = random.nextDouble() * 160 + 80,
      speed = random.nextDouble() * 0.28 + 0.12,
      color = [
        AppColors.accentPrimary,
        AppColors.accentSecondary,
        AppColors.accentTertiary,
        AppColors.accentBlue,
      ][random.nextInt(4)];
}

class _CircuitBackgroundPainter extends CustomPainter {
  final double progress;
  final List<_Track> tracks;

  const _CircuitBackgroundPainter({
    required this.progress,
    required this.tracks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _paintGrid(canvas, size);
    _paintMovingTracks(canvas, size);
    _paintDiagonalPanels(canvas, size);
  }

  void _paintGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1;
    const step = 54.0;

    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _paintMovingTracks(Canvas canvas, Size size) {
    for (final track in tracks) {
      final y = track.y * size.height;
      final travel = size.width + track.width * 2;
      final x = ((progress * track.speed * travel) % travel) - track.width;

      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            track.color.withValues(alpha: 0),
            track.color.withValues(alpha: 0.24),
            track.color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(x, y, track.width, 2))
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(x, y), Offset(x + track.width, y), paint);
    }
  }

  void _paintDiagonalPanels(Canvas canvas, Size size) {
    final panelPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.accentSecondary.withValues(alpha: 0.08);

    final shift = sin(progress * pi * 2) * 28;
    final path = Path()
      ..moveTo(size.width * 0.08 + shift, size.height * 0.18)
      ..lineTo(size.width * 0.42 + shift, size.height * 0.1)
      ..lineTo(size.width * 0.58 + shift, size.height * 0.34)
      ..lineTo(size.width * 0.24 + shift, size.height * 0.44)
      ..close();
    canvas.drawPath(path, panelPaint);

    final secondPath = Path()
      ..moveTo(size.width * 0.64 - shift, size.height * 0.72)
      ..lineTo(size.width * 0.92 - shift, size.height * 0.62)
      ..lineTo(size.width - shift, size.height * 0.92)
      ..lineTo(size.width * 0.72 - shift, size.height)
      ..close();
    canvas.drawPath(secondPath, panelPaint);
  }

  @override
  bool shouldRepaint(covariant _CircuitBackgroundPainter oldDelegate) => true;
}
