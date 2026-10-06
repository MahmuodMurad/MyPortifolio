import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../models/project_model.dart';

class ProjectCard extends StatefulWidget {
  final ProjectModel project;
  final int index;

  const ProjectCard({super.key, required this.project, required this.index});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _loopController;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    _loopController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 5600 + widget.index * 180),
    )..repeat();

    Future.delayed(Duration(milliseconds: 90 * widget.index), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _loopController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    if (!_isLaunchable(url)) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final curve = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curve),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 260),
            scale: _hovered ? 1.015 : 1,
            curve: Curves.easeOutCubic,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isMobile ? 12 : 8),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(
                      alpha: _hovered ? 0.82 : 0.64,
                    ),
                    borderRadius: BorderRadius.circular(isMobile ? 12 : 8),
                    border: Border.all(
                      color: _hovered
                          ? AppColors.accentSecondary.withValues(alpha: 0.42)
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      if (_hovered)
                        BoxShadow(
                          color: AppColors.accentPrimary.withValues(
                            alpha: 0.16,
                          ),
                          blurRadius: 32,
                          offset: const Offset(0, 18),
                        ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProjectVisual(
                        project: widget.project,
                        controller: _loopController,
                        index: widget.index,
                      ),
                      SizedBox(height: isMobile ? 14 : 18),
                      _buildHeader(isMobile),
                      const SizedBox(height: 10),
                      Text(
                        widget.project.description,
                        maxLines: isMobile ? 3 : 4,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 12.5 : 13.5,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTechStack(),
                      SizedBox(height: isMobile ? 14 : 16),
                      _buildLinks(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.project.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: AppColors.accentPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                widget.project.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontSize: isMobile ? 21 : 26,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 10,
            vertical: isMobile ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.ink.withValues(alpha: 0.68),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.accentTertiary.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            widget.project.impact,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: isMobile ? 9.5 : 10.5,
              height: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTechStack() {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: widget.project.technologies.take(6).map((tech) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.ink.withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.accentPrimary.withValues(alpha: 0.16),
            ),
          ),
          child: Text(
            tech,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLinks() {
    final entries = widget.project.links.entries.toList();
    if (entries.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: entries.map((entry) {
        final launchable = _isLaunchable(entry.value);
        return InkWell(
          onTap: launchable ? () => _launchUrl(entry.value) : null,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: launchable
                  ? AppColors.accentPrimary.withValues(alpha: 0.12)
                  : AppColors.ink.withValues(alpha: 0.52),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: launchable
                    ? AppColors.accentPrimary.withValues(alpha: 0.34)
                    : Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _iconFor(entry.key),
                  size: 15,
                  color: launchable
                      ? AppColors.accentPrimary
                      : AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  _labelFor(entry.key, entry.value),
                  style: GoogleFonts.outfit(
                    color: launchable
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  static bool _isLaunchable(String value) {
    return value.startsWith('http://') ||
        value.startsWith('https://') ||
        value.startsWith('mailto:');
  }

  static IconData _iconFor(String key) {
    if (key.contains('app_store')) return Icons.phone_iphone_rounded;
    if (key.contains('play')) return Icons.play_arrow_rounded;
    if (key.contains('dashboard')) return Icons.dashboard_customize_rounded;
    if (key.contains('themes')) return Icons.palette_rounded;
    if (key.contains('apk')) return Icons.android_rounded;
    return Icons.open_in_new_rounded;
  }

  static String _labelFor(String key, String value) {
    if (!_isLaunchable(value)) return value;
    switch (key) {
      case 'play_store':
        return 'Play Store';
      case 'app_store':
        return 'App Store';
      case 'admin_play':
        return 'Admin Play';
      case 'admin_app_store':
        return 'Admin iOS';
      case 'store_play':
        return 'Store App';
      case 'dashboard':
        return 'Dashboard';
      case 'themes':
        return 'Themes';
      default:
        return 'Open';
    }
  }
}

class _ProjectVisual extends StatelessWidget {
  final ProjectModel project;
  final Animation<double> controller;
  final int index;

  const _ProjectVisual({
    required this.project,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.64,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final pulse = sin(controller.value * pi * 2);
            return Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: _ProjectStagePainter(
                    progress: controller.value,
                    index: index,
                  ),
                ),
                if (project.images.isEmpty)
                  _GeneratedProjectPoster(
                    project: project,
                    progress: controller.value,
                  )
                else
                  _ScreenshotDeck(
                    images: project.images,
                    progress: controller.value,
                    pulse: pulse,
                  ),
                Positioned(
                  left: 14,
                  top: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.ink.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          project.images.isEmpty
                              ? Icons.auto_awesome_rounded
                              : Icons.phone_iphone_rounded,
                          size: 14,
                          color: AppColors.accentSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          project.images.isEmpty
                              ? 'Concept preview'
                              : 'Live screens',
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
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
      ),
    );
  }
}

class _ScreenshotDeck extends StatelessWidget {
  final List<String> images;
  final double progress;
  final double pulse;

  const _ScreenshotDeck({
    required this.images,
    required this.progress,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    final visible = images.take(5).toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final phoneWidth = min(width * 0.24, 118.0);
        final phoneHeight = min(height * 0.88, phoneWidth * 2.12);
        final center = width / 2;

        return Stack(
          children: visible.asMap().entries.map((entry) {
            final itemIndex = entry.key;
            final image = entry.value;
            final spread = itemIndex - (visible.length - 1) / 2;
            final bob = sin((progress * pi * 2) + itemIndex) * 8;
            final dx = center - phoneWidth / 2 + spread * phoneWidth * 0.62;
            final dy =
                (height - phoneHeight) / 2 + bob + (itemIndex.isEven ? 4 : -4);
            final rotation = spread * 0.08 + pulse * 0.012;

            return Positioned(
              left: dx,
              top: dy,
              width: phoneWidth,
              height: phoneHeight,
              child: Transform.rotate(
                angle: rotation,
                child: _PhoneFrame(image: image, highlighted: itemIndex == 0),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _PhoneFrame extends StatelessWidget {
  final String image;
  final bool highlighted;

  const _PhoneFrame({required this.image, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlighted
              ? AppColors.accentSecondary.withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.12),
          width: highlighted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            image,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
      ),
    );
  }
}

class _GeneratedProjectPoster extends StatelessWidget {
  final ProjectModel project;
  final double progress;

  const _GeneratedProjectPoster({
    required this.project,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final angle = sin(progress * pi * 2) * 0.05;
    return Center(
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: 190,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.ink.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.accentSecondary.withValues(alpha: 0.42),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                project.name == 'Aupos'
                    ? Icons.point_of_sale_rounded
                    : Icons.qr_code_2_rounded,
                color: AppColors.accentSecondary,
                size: 46,
              ),
              const SizedBox(height: 12),
              Text(
                project.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                project.category,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectStagePainter extends CustomPainter {
  final double progress;
  final int index;

  const _ProjectStagePainter({required this.progress, required this.index});

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.ink,
          [
            AppColors.surfaceLight,
            AppColors.accentBlue,
            AppColors.accentTertiary,
          ][index % 3].withValues(alpha: 0.24),
          AppColors.background,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = Colors.white.withValues(alpha: 0.08);

    for (var i = 0; i < 7; i++) {
      final y = size.height * (0.18 + i * 0.11);
      final xShift = sin(progress * pi * 2 + i) * 18;
      canvas.drawLine(
        Offset(-30 + xShift, y),
        Offset(size.width + 30 + xShift, y - 46),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProjectStagePainter oldDelegate) => true;
}
