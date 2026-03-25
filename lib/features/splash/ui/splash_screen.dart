import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
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
  late AnimationController _rollController;
  late AnimationController _smokeController;
  late AnimationController _fadeOutController;

  late Animation<double> _horizontalSlide;
  late Animation<double> _rotation;
  late Animation<double> _fadeOut;

  late List<_FireParticle> _fireParticles;
  final _random = Random();

  bool _showText = false;
  bool _wheelDone = false;

  static const double _wheelSize = 160.0;

  @override
  void initState() {
    super.initState();

    // Rolling animation: controls both horizontal movement and rotation
    _rollController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    // Horizontal slide: starts off-screen left, rolls to center
    _horizontalSlide = Tween<double>(begin: -1.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _rollController,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    // Rotation: multiple full spins while rolling, then stops
    _rotation = Tween<double>(begin: 0.0, end: 6 * pi).animate(
      CurvedAnimation(
        parent: _rollController,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    // Fire/burning smoke particles underneath the wheel
    _smokeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _fireParticles = List.generate(60, (_) => _FireParticle(_random));

    // Fade out for transition to home
    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeIn),
    );

    _startSequence();
  }

  void _startSequence() async {
    // Start rolling from left to center
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _rollController.forward();

    // Wait for the wheel to reach its final position
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;
    setState(() {
      _wheelDone = true;
      _showText = true;
    });

    // Let the typewriter animation play
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    // Fade out and navigate to home
    await _fadeOutController.forward();
    if (!mounted) return;

    // Stop all animations before navigating to prevent disposed view render
    _rollController.stop();
    _smokeController.stop();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _rollController.dispose();
    _smokeController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth < 600 ? 130.0 : _wheelSize;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeOut,
        child: Stack(
          children: [
            // Fire/burning smoke particles (positioned below wheel center)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: Listenable.merge([_smokeController, _rollController]),
                builder: (context, _) {
                  // Calculate where the wheel currently is
                  final wheelCenterX = screenWidth / 2 +
                      (_horizontalSlide.value * screenWidth * 0.4);
                  final wheelBottomY =
                      MediaQuery.of(context).size.height / 2 + imageSize / 2;

                  return CustomPaint(
                    painter: _FireSmokePainter(
                      particles: _fireParticles,
                      progress: _smokeController.value,
                      emitterX: wheelCenterX,
                      emitterY: wheelBottomY,
                      intensity: _wheelDone ? 0.3 : 1.0,
                    ),
                  );
                },
              ),
            ),

            // Rolling wheel + text
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // The rolling wheel
                  AnimatedBuilder(
                    animation: _rollController,
                    builder: (context, child) {
                      final dx = _horizontalSlide.value * screenWidth * 0.4;
                      return Transform.translate(
                        offset: Offset(dx, 0),
                        child: Transform.rotate(
                          angle: _rotation.value,
                          child: child,
                        ),
                      );
                    },
                    child: _buildWheel(imageSize),
                  ),

                  const SizedBox(height: 40),

                  // Typewriter name + role
                  if (_showText) ...[
                    SizedBox(
                      height: 50,
                      child: DefaultTextStyle(
                        style: GoogleFonts.outfit(
                          fontSize: screenWidth < 600 ? 26 : 34,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'Mahmoud Murad',
                              speed: const Duration(milliseconds: 70),
                            ),
                          ],
                          isRepeatingAnimation: false,
                          displayFullTextOnTap: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, value, child) {
                        return Opacity(opacity: value, child: child);
                      },
                      child: ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.accentGradient.createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                        child: Text(
                          'Flutter Developer',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ] else
                    const SizedBox(height: 88),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWheel(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accentPrimary, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPrimary.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: const Color(0xFFFF6B00).withValues(alpha: 0.3),
            blurRadius: 40,
            spreadRadius: 8,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/myimage.jpeg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// ─── Fire / Burning Smoke Particle ──────────────────────────────────────

class _FireParticle {
  late double offsetX;
  late double offsetY;
  late double size;
  late double speed;
  late double maxOpacity;
  late double drift;
  late Color color;
  final Random _random;

  _FireParticle(this._random) {
    reset();
  }

  void reset() {
    offsetX = (_random.nextDouble() - 0.5) * 80;
    offsetY = _random.nextDouble() * 20;
    size = _random.nextDouble() * 18 + 4;
    speed = _random.nextDouble() * 0.25 + 0.1;
    maxOpacity = _random.nextDouble() * 0.5 + 0.2;
    drift = (_random.nextDouble() - 0.5) * 40;

    // Mix of fire colors: orange, red-orange, yellow-orange
    final colorIndex = _random.nextInt(4);
    switch (colorIndex) {
      case 0:
        color = const Color(0xFFFF6B00); // deep orange
        break;
      case 1:
        color = const Color(0xFFFF9500); // orange
        break;
      case 2:
        color = const Color(0xFFFFCC00); // yellow-orange
        break;
      default:
        color = const Color(0xFFFF4500); // red-orange
    }
  }
}

class _FireSmokePainter extends CustomPainter {
  final List<_FireParticle> particles;
  final double progress;
  final double emitterX;
  final double emitterY;
  final double intensity;

  _FireSmokePainter({
    required this.particles,
    required this.progress,
    required this.emitterX,
    required this.emitterY,
    this.intensity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final age = (progress + p.speed) % 1.0;
      final life = 1.0 - age;
      final currentOpacity = (p.maxOpacity * life * intensity).clamp(0.0, 1.0);

      if (currentOpacity <= 0.01) continue;

      // Particles rise upward from the emitter and drift sideways
      final dx = emitterX + p.offsetX + p.drift * age;
      final dy = emitterY + p.offsetY - age * 120;
      final currentSize = p.size * (0.5 + age * 1.5);

      final paint = Paint()
        ..color = p.color.withValues(alpha: currentOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, currentSize * 0.6);

      canvas.drawCircle(Offset(dx, dy), currentSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FireSmokePainter oldDelegate) => true;
}
