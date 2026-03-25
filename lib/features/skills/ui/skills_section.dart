import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/data/cv_data_provider.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/section_title.dart';
import '../cubit/skills_cubit.dart';
import '../models/skill_model.dart';
import 'skill_bar.dart';

class SkillsSection extends StatefulWidget {
  const SkillsSection({super.key});

  @override
  State<SkillsSection> createState() => _SkillsSectionState();
}

class _SkillsSectionState extends State<SkillsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
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
    return BlocProvider(
      create: (_) => SkillsCubit(),
      child: Container(
        padding: Responsive.getSectionPadding(context),
        constraints:
            BoxConstraints(maxWidth: Responsive.getContentWidth(context)),
        child: Column(
          children: [
            const SectionTitle(
              title: 'Skills',
              subtitle: 'Technologies I work with',
            ),
            BlocBuilder<SkillsCubit, SkillsState>(
              builder: (context, state) {
                final isDesktop = Responsive.isDesktop(context);
                final categories = [
                  _buildCategory(
                    'Flutter Framework',
                    Icons.flutter_dash,
                    state.flutterSkills,
                    0,
                  ),
                  _buildCategory(
                    'General Concepts',
                    Icons.code,
                    state.generalSkills,
                    state.flutterSkills.length,
                  ),
                  _buildCategory(
                    'Languages',
                    Icons.language,
                    state.languages,
                    state.flutterSkills.length + state.generalSkills.length,
                  ),
                ];

                return Column(
                  children: [
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: categories[0]),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              children: [
                                categories[1],
                                const SizedBox(height: 24),
                                categories[2],
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      ...categories.expand((cat) => [cat, const SizedBox(height: 24)]),
                    
                    const SizedBox(height: 60),
                    _buildTechCloud(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(
    String title,
    IconData icon,
    List<SkillModel> skills,
    int baseDelay,
  ) {
    final start = (baseDelay / 20) * 0.5;
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, 1.0, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.accentPrimary.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: AppColors.accentPrimary, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...skills.asMap().entries.map((entry) {
                  return SkillBar(
                    name: entry.value.name,
                    level: entry.value.level,
                    delay: (baseDelay + entry.key) * 100,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTechCloud() {
    final allTech = CvDataProvider.experience
        .fold<Set<String>>({}, (prev, curr) => prev..addAll((curr['technologies'] as List? ?? []).cast<String>()))
        .union(CvDataProvider.projects
            .fold<Set<String>>({}, (prev, curr) => prev..addAll((curr['technologies'] as List? ?? []).cast<String>())))
        .toList();

    return Column(
      children: [
        Text(
          'Tech Stack Cloud',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: allTech.map((tech) => _TechChip(tech: tech)).toList(),
        ),
      ],
    );
  }
}

class _TechChip extends StatefulWidget {
  final String tech;
  const _TechChip({required this.tech});

  @override
  State<_TechChip> createState() => _TechChipState();
}

class _TechChipState extends State<_TechChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: _isHovered
              ? AppColors.accentPrimary.withValues(alpha: 0.15)
              : AppColors.surface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: _isHovered
                ? AppColors.accentPrimary
                : AppColors.accentPrimary.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: AppColors.accentPrimary.withValues(alpha: 0.2),
                    blurRadius: 10,
                  )
                ]
              : [],
        ),
        child: Text(
          widget.tech,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w400,
            color: _isHovered ? AppColors.accentPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
