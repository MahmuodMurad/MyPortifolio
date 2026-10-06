import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/data/cv_data_provider.dart';
import '../../../core/utils/responsive.dart';

class AboutSection extends StatefulWidget {
  const AboutSection({super.key});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _motionController;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
  }

  @override
  void dispose() {
    _introController.dispose();
    _motionController.dispose();
    super.dispose();
  }

  Future<void> _launch(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = CvDataProvider.personalInfo;
    final links = (info['links'] as Map<String, dynamic>?) ?? {};
    final stats = (info['stats'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final isDesktop = Responsive.isDesktop(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        Responsive.isDesktop(context) ? 80 : 20,
        Responsive.isDesktop(context) ? 72 : 36,
        Responsive.isDesktop(context) ? 80 : 20,
        44,
      ),
      constraints: BoxConstraints(
        maxWidth: Responsive.getContentWidth(context),
      ),
      child: AnimatedBuilder(
        animation: _introController,
        builder: (context, child) {
          final value = Curves.easeOutCubic.transform(_introController.value);
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 34 * (1 - value)),
              child: child,
            ),
          );
        },
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: _buildCopy(info, links)),
                  const SizedBox(width: 52),
                  SizedBox(width: 430, child: _buildPortrait(stats)),
                ],
              )
            : Responsive.isMobile(context)
                ? _buildMobileHero(info, links, stats)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCopy(info, links),
                      const SizedBox(height: 34),
                      _buildPortrait(stats),
                    ],
                  ),
      ),
    );
  }

  Widget _buildMobileHero(
    Map<String, dynamic> info,
    Map<String, dynamic> links,
    List<Map<String, dynamic>> stats,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildStatusPill(),
        const SizedBox(height: 24),
        AnimatedBuilder(
          animation: _motionController,
          builder: (context, _) {
            return Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Transform.rotate(
                  angle: _motionController.value * pi * 2,
                  child: Container(
                    width: 146,
                    height: 146,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: AppColors.accentGradient,
                    ),
                  ),
                ),
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(29),
                    color: AppColors.background,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: SizedBox(
                    width: 132,
                    height: 132,
                    child: Image.asset(
                      'assets/images/myimage.jpeg',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.accentSecondary.withValues(alpha: 0.6),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentSecondary.withValues(
                            alpha: 0.25,
                          ),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accentSecondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Flutter Specialist',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        Text(
          info['name'] ?? 'Mahmoud E. Murad',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: AppColors.accentGradient.createShader,
          child: Text(
            info['role'] ?? 'Flutter and Backend Developer',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          info['tagline'] ?? '',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            height: 1.5,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            _HeroAction(
              label: 'GitHub',
              icon: FontAwesomeIcons.github,
              filled: true,
              onTap: () => _launch(links['github'] as String?),
            ),
            _HeroAction(
              label: 'LinkedIn',
              icon: FontAwesomeIcons.linkedinIn,
              onTap: () => _launch(links['linkedin'] as String?),
            ),
            _HeroAction(
              label: 'WhatsApp',
              icon: FontAwesomeIcons.whatsapp,
              onTap: () => _launch(links['whatsapp'] as String?),
            ),
          ],
        ),
        const SizedBox(height: 26),
        _buildMobileStatsGrid(stats),
        const SizedBox(height: 20),
        if ((info['summary'] as String? ?? '').isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accentPrimary.withValues(alpha: 0.12),
              ),
            ),
            child: Text(
              info['summary'] ?? '',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.65,
                color: AppColors.textMuted,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMobileStatsGrid(List<Map<String, dynamic>> stats) {
    final visibleStats = stats.isEmpty
        ? [
            {'label': 'Experience', 'value': '5+ Yrs'},
            {'label': 'Live Apps', 'value': '10+'},
            {'label': 'Architecture', 'value': 'Clean / BLoC'},
            {'label': 'Education', 'value': 'B.Sc. CS'},
          ]
        : stats;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visibleStats.length.clamp(0, 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        final stat = visibleStats[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.accentPrimary.withValues(alpha: 0.16),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat['value'] ?? '',
                style: GoogleFonts.outfit(
                  color: AppColors.accentSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                stat['label'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCopy(Map<String, dynamic> info, Map<String, dynamic> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusPill(),
        const SizedBox(height: 22),
        Text(
          info['name'] ?? 'Mahmoud E. Murad',
          style: GoogleFonts.outfit(
            fontSize: Responsive.isMobile(context) ? 44 : 72,
            height: 0.94,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 14),
        ShaderMask(
          shaderCallback: AppColors.accentGradient.createShader,
          child: Text(
            info['role'] ?? 'Flutter and Backend Developer',
            style: GoogleFonts.outfit(
              fontSize: Responsive.isMobile(context) ? 25 : 38,
              height: 1.1,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          info['tagline'] ?? '',
          style: GoogleFonts.poppins(
            fontSize: Responsive.isMobile(context) ? 16 : 19,
            height: 1.55,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          info['summary'] ?? '',
          style: GoogleFonts.poppins(
            fontSize: 14.5,
            height: 1.8,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _HeroAction(
              label: 'View GitHub',
              icon: FontAwesomeIcons.github,
              filled: true,
              onTap: () => _launch(links['github'] as String?),
            ),
            _HeroAction(
              label: 'LinkedIn',
              icon: FontAwesomeIcons.linkedinIn,
              onTap: () => _launch(links['linkedin'] as String?),
            ),
            _HeroAction(
              label: 'WhatsApp',
              icon: FontAwesomeIcons.whatsapp,
              onTap: () => _launch(links['whatsapp'] as String?),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusPill() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.accentPrimary.withValues(alpha: 0.28),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt_rounded, size: 17),
              const SizedBox(width: 8),
              Text(
                'Available for high-polish Flutter products',
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortrait(List<Map<String, dynamic>> stats) {
    return AnimatedBuilder(
      animation: _motionController,
      builder: (context, _) {
        final wave = sin(_motionController.value * pi * 2);
        return Transform.translate(
          offset: Offset(0, wave * 10),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Transform.rotate(
                  angle: -0.08 + wave * 0.012,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.accentSecondary.withValues(
                          alpha: 0.42,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.76),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AspectRatio(
                        aspectRatio: 0.92,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/images/myimage.jpeg',
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                              ),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      AppColors.background.withValues(
                                        alpha: 0.75,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                right: 16,
                                bottom: 16,
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: const [
                                    _MiniBadge(label: 'Flutter'),
                                    _MiniBadge(label: 'Node.js'),
                                    _MiniBadge(label: 'Supabase'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildStats(stats),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStats(List<Map<String, dynamic>> stats) {
    final visibleStats = stats.isEmpty
        ? [
            {'label': 'Years Experience', 'value': '3+'},
            {'label': 'Active Users', 'value': '50K+'},
            {'label': 'Production Apps', 'value': '14+'},
          ]
        : stats;

    return Row(
      children: visibleStats.take(3).map((stat) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.ink.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.accentPrimary.withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              children: [
                Text(
                  stat['value'] ?? '',
                  style: GoogleFonts.outfit(
                    color: AppColors.accentSecondary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat['label'] ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: GoogleFonts.poppins(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _HeroAction extends StatefulWidget {
  final String label;
  final dynamic icon;
  final bool filled;
  final VoidCallback onTap;

  const _HeroAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  State<_HeroAction> createState() => _HeroActionState();
}

class _HeroActionState extends State<_HeroAction> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: widget.filled ? AppColors.accentGradient : null,
            color: widget.filled
                ? null
                : AppColors.surface.withValues(alpha: 0.68),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.filled
                  ? Colors.white.withValues(alpha: 0.16)
                  : AppColors.accentPrimary.withValues(alpha: 0.24),
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.accentPrimary.withValues(alpha: 0.18),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.icon is FaIconData
                  ? FaIcon(
                      widget.icon as FaIconData,
                      color: widget.filled
                          ? AppColors.ink
                          : AppColors.accentPrimary,
                      size: 16,
                    )
                  : Icon(
                      widget.icon as IconData,
                      color: widget.filled
                          ? AppColors.ink
                          : AppColors.accentPrimary,
                      size: 16,
                    ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: GoogleFonts.outfit(
                  color: widget.filled ? AppColors.ink : AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;

  const _MiniBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.accentSecondary.withValues(alpha: 0.28),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
