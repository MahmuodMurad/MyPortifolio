import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../../home/ui/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _loopController;
  late final AnimationController _exitController;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _start();
  }

  Future<void> _start() async {
    await Future.delayed(const Duration(milliseconds: 2450));
    if (!mounted) return;
    await _exitController.forward();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    _loopController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final compact = width < 640;
    final portraitSize = compact ? 132.0 : 164.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _introController,
          _loopController,
          _exitController,
        ]),
        builder: (context, _) {
          final intro = Curves.easeOutCubic.transform(_introController.value);
          final exit = 1 - Curves.easeInCubic.transform(_exitController.value);
          final spin = _loopController.value * pi * 2;

          return Opacity(
            opacity: exit,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SplashPainter(progress: _loopController.value),
                  ),
                ),
                Center(
                  child: Transform.translate(
                    offset: Offset(0, 28 * (1 - intro)),
                    child: Opacity(
                      opacity: intro,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.rotate(
                                angle: spin * 0.18,
                                child: Container(
                                  width: portraitSize + 72,
                                  height: portraitSize + 72,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.accentSecondary
                                          .withValues(alpha: 0.34),
                                    ),
                                  ),
                                ),
                              ),
                              Transform.rotate(
                                angle: -spin * 0.12,
                                child: Container(
                                  width: portraitSize + 38,
                                  height: portraitSize + 38,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.accentPrimary.withValues(
                                        alpha: 0.46,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  'assets/images/myimage.jpeg',
                                  width: portraitSize,
                                  height: portraitSize,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 34),
                          ShaderMask(
                            shaderCallback:
                                AppColors.accentGradient.createShader,
                            child: Text(
                              'Mahmoud E. Murad',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: compact ? 34 : 48,
                                fontWeight: FontWeight.w900,
                                height: 1,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Flutter + Backend Developer',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                              fontSize: compact ? 14 : 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: compact ? 220 : 280,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: (0.18 + _loopController.value * 0.82)
                                    .clamp(0.0, 1.0),
                                minHeight: 7,
                                backgroundColor: AppColors.surfaceLight
                                    .withValues(alpha: 0.5),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.accentPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SplashPainter extends CustomPainter {
  final double progress;

  const _SplashPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.background, AppColors.ink, AppColors.backgroundAlt],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.045)
      ..strokeWidth = 1;
    const step = 44.0;
    final drift = progress * step;
    for (double x = -step + drift; x < size.width + step; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = -step + drift; y < size.height + step; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final accent = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.accentPrimary.withValues(alpha: 0.18);
    final scanY = (progress * (size.height + 160)) - 80;
    canvas.drawLine(Offset(0, scanY), Offset(size.width, scanY - 80), accent);

    final warm = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppColors.accentSecondary.withValues(alpha: 0.12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.5, size.height * 0.5),
          width: min(size.width * 0.72, 620),
          height: min(size.height * 0.62, 520),
        ),
        const Radius.circular(8),
      ),
      warm,
    );
  }

  @override
  bool shouldRepaint(covariant _SplashPainter oldDelegate) => true;
}
