import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/data/cv_data_provider.dart';
import '../models/skill_model.dart';

class MobileSkillsView extends StatefulWidget {
  final List<SkillModel> flutterSkills;
  final List<SkillModel> generalSkills;
  final List<SkillModel> languages;

  const MobileSkillsView({
    super.key,
    required this.flutterSkills,
    required this.generalSkills,
    required this.languages,
  });

  @override
  State<MobileSkillsView> createState() => _MobileSkillsViewState();
}

class _MobileSkillsViewState extends State<MobileSkillsView>
    with SingleTickerProviderStateMixin {
  int _activeCategoryIndex = 0; // 0: Flutter, 1: Backend/Arch, 2: Languages
  bool _isGaugeMode = true; // true: Gauges Grid, false: Deep Dive List
  late final AnimationController _gaugeAnimController;

  final List<(String, IconData, String)> _categories = [
    ('Flutter & UI', Icons.flutter_dash_rounded, '8 Skills'),
    ('Architecture & APIs', Icons.architecture_rounded, '8 Skills'),
    ('Languages & Tools', Icons.translate_rounded, '4 Skills'),
  ];

  @override
  void initState() {
    super.initState();
    _gaugeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _gaugeAnimController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(int index) {
    if (_activeCategoryIndex == index) return;
    setState(() => _activeCategoryIndex = index);
    _gaugeAnimController.reset();
    _gaugeAnimController.forward();
  }

  List<SkillModel> get _currentSkills {
    switch (_activeCategoryIndex) {
      case 0:
        return widget.flutterSkills;
      case 1:
        return widget.generalSkills;
      case 2:
      default:
        return widget.languages;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Domain Strengths Ribbon
        _buildStrengthsRibbon(),
        const SizedBox(height: 18),

        // Native Segmented Pill Bar
        _buildSegmentedTabBar(),
        const SizedBox(height: 16),

        // View Mode Switcher (Gauges Grid vs Detailed Feed)
        _buildViewModeToggle(),
        const SizedBox(height: 18),

        // Skills Content (Animated Switcher between Grid & Feed)
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: KeyedSubtree(
            key: ValueKey('$_activeCategoryIndex-$_isGaugeMode'),
            child: _isGaugeMode
                ? _buildSkillsGrid(_currentSkills)
                : _buildSkillsDetailFeed(_currentSkills),
          ),
        ),

        const SizedBox(height: 36),

        // Interactive Tech Cloud
        _buildInteractiveTechCloud(),
      ],
    );
  }

  Widget _buildStrengthsRibbon() {
    final pillars = [
      ('Mobile First', 'Flutter & iOS/Android', Icons.smartphone_rounded),
      ('Full Stack', 'Node.js & Supabase', Icons.cloud_done_rounded),
      ('Clean Arch', 'Bloc, MVVM, SOLID', Icons.layers_rounded),
    ];

    return Row(
      children: pillars.map((p) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.accentPrimary.withValues(alpha: 0.16),
              ),
            ),
            child: Column(
              children: [
                Icon(p.$3, size: 18, color: AppColors.accentPrimary),
                const SizedBox(height: 6),
                Text(
                  p.$1,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  p.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSegmentedTabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentPrimary.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        children: List.generate(_categories.length, (index) {
          final isSelected = index == _activeCategoryIndex;
          final cat = _categories[index];

          return Expanded(
            child: GestureDetector(
              onTap: () => _onCategoryChanged(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.accentGradient : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color:
                                AppColors.accentPrimary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat.$2,
                      size: 16,
                      color: isSelected
                          ? AppColors.ink
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      cat.$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? AppColors.ink
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildViewModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'PROFICIENCY MATRIX',
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.accentSecondary,
            letterSpacing: 0.8,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildViewIcon(
                icon: Icons.grid_view_rounded,
                label: 'Dial Grid',
                isSelected: _isGaugeMode,
                onTap: () => setState(() => _isGaugeMode = true),
              ),
              const SizedBox(width: 4),
              _buildViewIcon(
                icon: Icons.view_headline_rounded,
                label: 'Deep Dive',
                isSelected: !_isGaugeMode,
                onTap: () => setState(() => _isGaugeMode = false),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewIcon({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentPrimary.withValues(alpha: 0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: isSelected
              ? Border.all(
                  color: AppColors.accentPrimary.withValues(alpha: 0.4),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected
                  ? AppColors.accentPrimary
                  : AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.accentPrimary
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsGrid(List<SkillModel> skills) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: skills.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final skill = skills[index];
        return _SkillDialCard(
          skill: skill,
          index: index,
          animation: _gaugeAnimController,
        );
      },
    );
  }

  Widget _buildSkillsDetailFeed(List<SkillModel> skills) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: skills.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final skill = skills[index];
        final pct = (skill.level * 100).toInt();

        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.accentPrimary.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        skill.name,
                        style: GoogleFonts.outfit(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentPrimary
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.accentPrimary
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '$pct%',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accentPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Animated Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: AnimatedBuilder(
                      animation: _gaugeAnimController,
                      builder: (context, _) {
                        final val = skill.level * _gaugeAnimController.value;
                        return LinearProgressIndicator(
                          value: val,
                          minHeight: 6,
                          backgroundColor:
                              AppColors.ink.withValues(alpha: 0.7),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.accentPrimary,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getSkillTagline(skill.name),
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static String _getSkillTagline(String skill) {
    switch (skill) {
      case 'Flutter':
        return 'Multi-platform apps, responsive layouts, 60fps animations';
      case 'Dart':
        return 'OOP, Async streams, generics, extension methods';
      case 'Bloc / Cubit':
        return 'Enterprise state separation, predictable reactive architecture';
      case 'Provider':
        return 'Scoped dependency injection, lightweight reactivity';
      case 'GetX':
        return 'Fast prototyping, routing & reactive state controller';
      case 'Riverpod':
        return 'Compile-safe, modular state management pattern';
      case 'Firebase':
        return 'Auth, Firestore, Cloud Messaging (FCM), Crashlytics';
      case 'Animations':
        return 'Physics springs, Staggered tweens, Hero & CustomPainter';
      case 'Node.js / Express':
        return 'RESTful APIs, JWT authentication, middleware & routing';
      case 'Prisma / PostgreSQL':
        return 'Relational schema modeling, migration pipelines & queries';
      case 'Supabase':
        return 'PostgreSQL backend, Row-Level Security, real-time sync';
      case 'REST API Design':
        return 'Structured endpoints, pagination, status codes & error formats';
      case 'Clean Architecture':
        return 'Domain/Data/Presentation layer decoupling, repository pattern';
      case 'Kotlin':
        return 'Android native services, platform channels & intent handling';
      case 'GitHub Actions':
        return 'CI/CD mobile builds, automated testing & deployment';
      case 'Product Ownership':
        return 'End-to-end delivery from requirements to app store release';
      case 'Arabic':
        return 'Native proficiency (mother tongue)';
      case 'English':
        return 'Full professional proficiency (technical docs & teams)';
      default:
        return 'Production level implementation';
    }
  }

  Widget _buildInteractiveTechCloud() {
    final allTech = CvDataProvider.experience
        .fold<Set<String>>(
          {},
          (prev, curr) => prev
            ..addAll((curr['technologies'] as List? ?? []).cast<String>()),
        )
        .union(
          CvDataProvider.projects.fold<Set<String>>(
            {},
            (prev, curr) => prev
              ..addAll((curr['technologies'] as List? ?? []).cast<String>()),
          ),
        )
        .toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hub_rounded, size: 16, color: AppColors.accentPrimary),
            const SizedBox(width: 8),
            Text(
              'ECOSYSTEM & TOOLS CLOUD',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Every library, API, and technology used in shipping production apps',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          alignment: WrapAlignment.center,
          children: allTech.map((tech) => _MobileTechChip(tech: tech)).toList(),
        ),
      ],
    );
  }
}

class _SkillDialCard extends StatelessWidget {
  final SkillModel skill;
  final int index;
  final Animation<double> animation;

  const _SkillDialCard({
    required this.skill,
    required this.index,
    required this.animation,
  });

  String _getTierLabel(double level) {
    if (level >= 0.95) return 'Mastery';
    if (level >= 0.90) return 'Lead';
    if (level >= 0.85) return 'Advanced';
    return 'Proficient';
  }

  @override
  Widget build(BuildContext context) {
    final pct = (skill.level * 100).toInt();
    final tier = _getTierLabel(skill.level);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.accentPrimary.withValues(alpha: 0.16),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Radial Arc Gauge
              SizedBox(
                width: 68,
                height: 68,
                child: AnimatedBuilder(
                  animation: animation,
                  builder: (context, _) {
                    final progress = skill.level * animation.value;
                    return CustomPaint(
                      painter: _RadialDialPainter(
                        progress: progress,
                        trackColor: AppColors.ink.withValues(alpha: 0.8),
                        strokeColor: AppColors.accentPrimary,
                        glowColor: AppColors.accentSecondary,
                      ),
                      child: Center(
                        child: Text(
                          '$pct%',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Skill Title
              Text(
                skill.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),

              // Level Tier Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.accentPrimary.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  tier,
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadialDialPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color strokeColor;
  final Color glowColor;

  _RadialDialPainter({
    required this.progress,
    required this.trackColor,
    required this.strokeColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress Arc with Gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepAngle = 2 * math.pi * progress;

    final arcPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: 2 * math.pi,
        colors: [
          strokeColor,
          glowColor,
          strokeColor,
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-math.pi / 2);
    canvas.translate(-center.dx, -center.dy);

    canvas.drawArc(
      rect,
      0,
      sweepAngle,
      false,
      arcPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RadialDialPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _MobileTechChip extends StatefulWidget {
  final String tech;

  const _MobileTechChip({required this.tech});

  @override
  State<_MobileTechChip> createState() => _MobileTechChipState();
}

class _MobileTechChipState extends State<_MobileTechChip> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) => setState(() => _isTapped = false),
      onTapCancel: () => setState(() => _isTapped = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _isTapped
              ? AppColors.accentPrimary.withValues(alpha: 0.25)
              : AppColors.surface.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isTapped
                ? AppColors.accentPrimary
                : AppColors.accentPrimary.withValues(alpha: 0.18),
            width: 1,
          ),
          boxShadow: _isTapped
              ? [
                  BoxShadow(
                    color: AppColors.accentPrimary.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ]
              : [],
        ),
        child: Text(
          widget.tech,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10.5,
            fontWeight: _isTapped ? FontWeight.w700 : FontWeight.w500,
            color: _isTapped
                ? AppColors.accentPrimary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
