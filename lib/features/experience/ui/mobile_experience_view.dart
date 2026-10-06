import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../models/experience_model.dart';

class MobileExperienceView extends StatefulWidget {
  final List<ExperienceModel> experiences;

  const MobileExperienceView({
    super.key,
    required this.experiences,
  });

  @override
  State<MobileExperienceView> createState() => _MobileExperienceViewState();
}

class _MobileExperienceViewState extends State<MobileExperienceView>
    with SingleTickerProviderStateMixin {
  int _selectedFilterIndex = 0; // 0: All, 1: Engineering, 2: Mentorship
  final Set<int> _expandedCardIndices = {0}; // Expand first by default
  late final AnimationController _pulseController;

  final List<String> _filters = [
    'All Milestones',
    'Engineering & Lead',
    'Community & Mentorship',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  List<ExperienceModel> get _filteredExperiences {
    if (_selectedFilterIndex == 1) {
      return widget.experiences
          .where((e) =>
              e.role.toLowerCase().contains('developer') ||
              e.role.toLowerCase().contains('lead'))
          .toList();
    } else if (_selectedFilterIndex == 2) {
      return widget.experiences
          .where((e) =>
              e.role.toLowerCase().contains('instructor') ||
              e.role.toLowerCase().contains('head') ||
              e.role.toLowerCase().contains('volunteer'))
          .toList();
    }
    return widget.experiences;
  }

  void _toggleExpanded(int index) {
    setState(() {
      if (_expandedCardIndices.contains(index)) {
        _expandedCardIndices.remove(index);
      } else {
        _expandedCardIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Career Stats Row
        _buildCareerStatsRow(),
        const SizedBox(height: 18),

        // Filter chips bar
        _buildFilterBar(),
        const SizedBox(height: 20),

        // Timeline Feed
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredExperiences.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final exp = _filteredExperiences[index];
            final isExpanded = _expandedCardIndices.contains(index);
            final isCurrent = exp.period.toLowerCase().contains('present');

            return _MobileExperienceCard(
              experience: exp,
              index: index,
              isExpanded: isExpanded,
              isCurrent: isCurrent,
              pulseAnimation: _pulseController,
              onToggle: () => _toggleExpanded(index),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCareerStatsRow() {
    final stats = [
      ('3+ Yrs', 'Experience', Icons.timeline_rounded),
      ('Lead Dev', 'Current Role', Icons.verified_user_rounded),
      ('7', 'Milestones', Icons.emoji_events_rounded),
      ('14+', 'Live Apps', Icons.rocket_launch_rounded),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.accentPrimary.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: stats.map((stat) {
              return Expanded(
                child: Column(
                  children: [
                    Icon(
                      stat.$3,
                      size: 16,
                      color: AppColors.accentPrimary,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stat.$1,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stat.$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = index == _selectedFilterIndex;
          return Padding(
            padding: EdgeInsets.only(
              right: index < _filters.length - 1 ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilterIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.accentGradient : null,
                  color: isSelected
                      ? null
                      : AppColors.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : AppColors.accentPrimary.withValues(alpha: 0.15),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.accentPrimary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  _filters[index],
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.ink : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MobileExperienceCard extends StatelessWidget {
  final ExperienceModel experience;
  final int index;
  final bool isExpanded;
  final bool isCurrent;
  final Animation<double> pulseAnimation;
  final VoidCallback onToggle;

  const _MobileExperienceCard({
    required this.experience,
    required this.index,
    required this.isExpanded,
    required this.isCurrent,
    required this.pulseAnimation,
    required this.onToggle,
  });

  String _getCompanyMonogram(String company) {
    final clean = company.split('-').first.trim();
    final words = clean.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'EXP';
  }

  String _getCompanyLocation(String company) {
    if (company.contains('-')) {
      final parts = company.split('-');
      return parts.length > 1 ? parts.sublist(1).join('-').trim() : '';
    }
    return '';
  }

  String _getCompanyNameOnly(String company) {
    return company.split('-').first.trim();
  }

  List<String> _extractKeyHighlights(String description) {
    final sentences = description
        .split(RegExp(r'\.|\band\b'))
        .map((s) => s.trim())
        .where((s) => s.length > 10)
        .toList();
    if (sentences.isEmpty) return [description];
    return sentences;
  }

  List<String> _getRoleTags(String role, String description) {
    final lower = '$role $description'.toLowerCase();
    final tags = <String>[];

    if (lower.contains('node') || lower.contains('api')) tags.add('Node.js API');
    if (lower.contains('supabase')) tags.add('Supabase');
    if (lower.contains('bloc')) tags.add('Bloc / Cubit');
    if (lower.contains('firebase') || lower.contains('fcm')) tags.add('Firebase');
    if (lower.contains('clean')) tags.add('Clean Arch');
    if (lower.contains('ios') || lower.contains('android')) tags.add('iOS & Android');
    if (lower.contains('lead') || lower.contains('requirements')) tags.add('Architecture');
    if (lower.contains('curriculum') || lower.contains('training')) tags.add('Mentorship');
    if (lower.contains('getx') || lower.contains('mvvm')) tags.add('MVVM');

    if (tags.isEmpty) tags.add('Flutter');
    return tags.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final monogram = _getCompanyMonogram(experience.company);
    final companyName = _getCompanyNameOnly(experience.company);
    final location = _getCompanyLocation(experience.company);
    final tags = _getRoleTags(experience.role, experience.description);
    final highlights = _extractKeyHighlights(experience.description);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isCurrent
                  ? AppColors.accentPrimary.withValues(alpha: 0.45)
                  : AppColors.accentPrimary.withValues(alpha: 0.14),
              width: isCurrent ? 1.5 : 1.0,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppColors.accentPrimary.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Top Accent Bar (Gradient glow for current job)
              if (isCurrent)
                Container(
                  height: 3,
                  decoration: const BoxDecoration(
                    gradient: AppColors.accentGradient,
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row: Monogram Avatar, Company, Status Beacon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Squircle Company Avatar
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: isCurrent
                                ? AppColors.accentGradient
                                : LinearGradient(
                                    colors: [
                                      AppColors.accentPrimary
                                          .withValues(alpha: 0.2),
                                      AppColors.surfaceLight,
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.accentPrimary
                                  .withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            monogram,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isCurrent
                                  ? AppColors.ink
                                  : AppColors.accentPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Company & Role Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                experience.role,
                                style: GoogleFonts.outfit(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                companyName,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accentPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Active Pulsing Badge if current
                        if (isCurrent)
                          AnimatedBuilder(
                            animation: pulseAnimation,
                            builder: (context, _) {
                              final alpha =
                                  0.4 + (0.5 * pulseAnimation.value);
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accentPrimary
                                      .withValues(alpha: alpha * 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.accentPrimary
                                        .withValues(alpha: alpha),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: AppColors.accentPrimary,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.accentPrimary
                                                .withValues(alpha: alpha),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'ACTIVE',
                                      style: GoogleFonts.outfit(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.accentPrimary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Meta Row: Period & Location
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.ink.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 10,
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: 4.5),
                              Text(
                                experience.period,
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (location.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.ink.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 11,
                                  color: AppColors.textSecondary
                                      .withValues(alpha: 0.8),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  location,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Quick Tech Pills
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags.map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentPrimary
                                .withValues(alpha: 0.09),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.accentPrimary
                                  .withValues(alpha: 0.22),
                            ),
                          ),
                          child: Text(
                            t,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 12),

                    // Primary Summary Text
                    Text(
                      experience.description,
                      maxLines: isExpanded ? null : 2,
                      overflow: isExpanded ? null : TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        height: 1.55,
                      ),
                    ),

                    // Animated Expandable Deliverables Drawer
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 1,
                              color: AppColors.accentPrimary
                                  .withValues(alpha: 0.12),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'CORE DELIVERABLES & IMPACT',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accentSecondary,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...highlights.map((h) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 3.5, right: 8),
                                      child: Icon(
                                        Icons.check_circle_rounded,
                                        size: 13,
                                        color: AppColors.accentPrimary,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        h.trim(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppColors.textPrimary
                                              .withValues(alpha: 0.9),
                                          height: 1.45,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      crossFadeState: isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 260),
                    ),

                    const SizedBox(height: 10),

                    // Accordion Toggle Tap Button
                    GestureDetector(
                      onTap: onToggle,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.ink.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isExpanded
                                ? AppColors.accentPrimary
                                    .withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isExpanded ? 'Show Less' : 'Full Role Breakdown',
                              style: GoogleFonts.outfit(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: isExpanded
                                    ? AppColors.accentPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 250),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: isExpanded
                                    ? AppColors.accentPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
