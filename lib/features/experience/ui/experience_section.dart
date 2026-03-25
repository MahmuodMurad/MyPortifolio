import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/data/cv_data_provider.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/section_title.dart';
import '../models/experience_model.dart';

class ExperienceSection extends StatefulWidget {
  const ExperienceSection({super.key});

  @override
  State<ExperienceSection> createState() => _ExperienceSectionState();
}

class _ExperienceSectionState extends State<ExperienceSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ExperienceModel> _experiences;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _experiences = CvDataProvider.experience
        .map((e) => ExperienceModel.fromJson(e as Map<String, dynamic>))
        .toList();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Responsive.getSectionPadding(context),
      constraints: BoxConstraints(maxWidth: Responsive.getContentWidth(context)),
      child: Column(
        children: [
          const SectionTitle(
            title: 'Experience',
            subtitle: 'My professional journey',
          ),
          ..._experiences.asMap().entries.map((entry) {
            final i = entry.key;
            final exp = entry.value;
            final isLast = i == _experiences.length - 1;
            
            // Staggered interval for entrance
            final start = (i / _experiences.length) * 0.5;
            final end = start + 0.5;
            final animation = CurvedAnimation(
              parent: _controller,
              curve: Interval(start, end, curve: Curves.easeOutCubic),
            );

            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 40 * (1 - animation.value)),
                  child: Opacity(
                    opacity: animation.value,
                    child: child,
                  ),
                );
              },
              child: _ExperienceCardWrapper(exp: exp, isLast: isLast),
            );
          }),
        ],
      ),
    );
  }
}

class _ExperienceCardWrapper extends StatefulWidget {
  final ExperienceModel exp;
  final bool isLast;

  const _ExperienceCardWrapper({required this.exp, required this.isLast});

  @override
  State<_ExperienceCardWrapper> createState() => _ExperienceCardWrapperState();
}

class _ExperienceCardWrapperState extends State<_ExperienceCardWrapper> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          SizedBox(
            width: 30,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isHovered ? 18 : 14,
                  height: _isHovered ? 18 : 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.accentGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentPrimary.withValues(
                          alpha: _isHovered ? 0.6 : 0.4,
                        ),
                        blurRadius: _isHovered ? 12 : 8,
                        spreadRadius: _isHovered ? 2 : 0,
                      ),
                    ],
                  ),
                ),
                if (!widget.isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.accentPrimary.withValues(alpha: 0.5),
                            AppColors.accentSecondary.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Interactive Card
          Expanded(
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.only(bottom: 32),
                transform: Matrix4.translationValues(
                  _isHovered ? 12.0 : 0.0,
                  0.0,
                  0.0,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(
                          alpha: _isHovered ? 0.7 : 0.5,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.accentPrimary.withValues(
                            alpha: _isHovered ? 0.4 : 0.15,
                          ),
                          width: _isHovered ? 1.5 : 1.0,
                        ),
                        boxShadow: _isHovered
                            ? [
                                BoxShadow(
                                  color: AppColors.accentPrimary.withValues(alpha: 0.1),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ]
                            : [],
                      ),
                      child: Stack(
                        children: [
                          // Side glowing bar on hover
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            left: 0,
                            top: _isHovered ? 0 : 20,
                            bottom: _isHovered ? 0 : 20,
                            width: 3,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: _isHovered ? 1.0 : 0.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: AppColors.accentGradient,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.exp.role,
                                  style: GoogleFonts.outfit(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.exp.company,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accentPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 12,
                                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      widget.exp.period,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  widget.exp.description,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
