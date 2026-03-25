import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/data/cv_data_provider.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/section_title.dart';

class AboutSection extends StatefulWidget {
  const AboutSection({super.key});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;
  late Animation<Offset> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Pulse & Float Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 15.0, end: 35.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.05),
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    // Auto-trigger after small delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = CvDataProvider.personalInfo;
    final isDesktop = Responsive.isDesktop(context);
    final isMobile = Responsive.isMobile(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: Responsive.getSectionPadding(context),
          constraints: BoxConstraints(maxWidth: Responsive.getContentWidth(context)),
          child: Column(
            children: [
              const SectionTitle(title: 'About Me', subtitle: 'Get to know me'),
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildImage(160)),
                    const SizedBox(width: 60),
                    Expanded(flex: 3, child: _buildInfo(info)),
                  ],
                )
              else
                Column(
                  children: [
                    _buildImage(isMobile ? 130 : 150),
                    const SizedBox(height: 30),
                    _buildInfo(info),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(double size) {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return SlideTransition(
            position: _floatAnimation,
            child: Transform.rotate(
              angle: _pulseController.value * 0.05, // Subtle backward rotation
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accentPrimary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentPrimary.withValues(alpha: 0.3),
                      blurRadius: _glowAnimation.value,
                      spreadRadius: _glowAnimation.value / 4,
                    ),
                    BoxShadow(
                      color: AppColors.accentSecondary.withValues(alpha: 0.2),
                      blurRadius: _glowAnimation.value * 1.5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/myimage.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfo(Map<String, dynamic> info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          info['name'] ?? 'Mahmoud Murad',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.accentGradient.createShader(bounds),
          child: Text(
            info['role'] ?? 'Flutter Developer',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          info['summary'] ?? '',
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 24),
        _buildStatRow(),
      ],
    );
  }

  Widget _buildStatRow() {
    final stats = [
      {'label': 'Years Exp', 'value': '2+'},
      {'label': 'Projects', 'value': '10+'},
      {'label': 'Students', 'value': '100+'},
    ];
    return Row(
      children: stats.asMap().entries.map((entry) {
        final index = entry.key;
        final stat = entry.value;
        return Expanded(
          child: _AnimatedStat(
            label: stat['label']!,
            value: stat['value']!,
            index: index,
          ),
        );
      }).toList(),
    );
  }
}

class _AnimatedStat extends StatefulWidget {
  final String label;
  final String value;
  final int index;

  const _AnimatedStat({
    required this.label,
    required this.value,
    required this.index,
  });

  @override
  State<_AnimatedStat> createState() => _AnimatedStatState();
}

class _AnimatedStatState extends State<_AnimatedStat>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    final isUp = widget.index % 2 == 0;
    _floatAnimation = Tween<Offset>(
      begin: isUp ? const Offset(0, 0.05) : const Offset(0, -0.05),
      end: isUp ? const Offset(0, -0.05) : const Offset(0, 0.05),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _floatAnimation,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.accentPrimary.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.value,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accentPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
