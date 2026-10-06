import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/section_title.dart';
import '../cubit/projects_cubit.dart';
import '../models/project_model.dart';
import 'mobile_projects_view.dart';
import 'project_card.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProjectsCubit(),
      child: Container(
        padding: Responsive.getSectionPadding(context),
        constraints: BoxConstraints(
          maxWidth: Responsive.getContentWidth(context),
        ),
        child: Column(
          children: [
            const SectionTitle(
              title: 'Selected Work',
              subtitle:
                  'Mobile products with real users, stores, dashboards, and APIs',
            ),
            BlocBuilder<ProjectsCubit, List<ProjectModel>>(
              builder: (context, projects) {
                if (Responsive.isMobile(context)) {
                  return MobileProjectsView(projects: projects);
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final isDesktop = width >= 980;
                    final cardWidth = isDesktop ? (width - 22) / 2 : width;

                    return Column(
                      children: [
                        _ProjectCommandStrip(projects: projects),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 22,
                          runSpacing: 22,
                          children: projects.asMap().entries.map((entry) {
                            return SizedBox(
                              width: cardWidth,
                              child: ProjectCard(
                                project: entry.value,
                                index: entry.key,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectCommandStrip extends StatelessWidget {
  final List<ProjectModel> projects;

  const _ProjectCommandStrip({required this.projects});

  @override
  Widget build(BuildContext context) {
    final categories = projects
        .map((project) => project.category)
        .toSet()
        .length;
    final storeLinks = projects.fold<int>(
      0,
      (count, project) =>
          count + project.links.values.where(_isLaunchable).length,
    );
    final isMobile = Responsive.isMobile(context);

    if (isMobile) {
      final metrics = [
        ('Projects', '${projects.length}'),
        ('Domains', '$categories'),
        ('Live links', '$storeLinks'),
        ('Focus', 'Flutter + APIs'),
      ];

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accentPrimary.withValues(alpha: 0.16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _Metric(label: metrics[0].$1, value: metrics[0].$2),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Metric(label: metrics[1].$1, value: metrics[1].$2),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _Metric(label: metrics[2].$1, value: metrics[2].$2),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Metric(label: metrics[3].$1, value: metrics[3].$2),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.accentPrimary.withValues(alpha: 0.16),
            ),
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _Metric(label: 'Projects', value: '${projects.length}'),
              _Metric(label: 'Domains', value: '$categories'),
              _Metric(label: 'Live links', value: '$storeLinks'),
              const _Metric(label: 'Focus', value: 'Flutter + APIs'),
            ],
          ),
        ),
      ),
    );
  }

  static bool _isLaunchable(String value) {
    return value.startsWith('http://') ||
        value.startsWith('https://') ||
        value.startsWith('mailto:');
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      constraints: BoxConstraints(minWidth: isMobile ? 0 : 142),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 14,
        vertical: isMobile ? 9 : 11,
      ),
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              color: AppColors.accentSecondary,
              fontSize: isMobile ? 17 : 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.textMuted,
              fontSize: isMobile ? 10.5 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
