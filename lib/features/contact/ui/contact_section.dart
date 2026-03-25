import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/data/cv_data_provider.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/section_title.dart';

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = CvDataProvider.personalInfo;
    final links = (info['links'] as Map<String, dynamic>?) ?? {};

    final contactItems = [
      _ContactItem(
        icon: Icons.email_outlined,
        title: 'Email',
        value: info['email'] ?? '',
        url: 'mailto:${info['email'] ?? ''}',
      ),
      _ContactItem(
        icon: FontAwesomeIcons.whatsapp,
        title: 'WhatsApp',
        value: info['phone'] ?? '',
        url: links['whatsapp'] ?? 'https://wa.me/201150374990',
      ),
      _ContactItem(
        icon: Icons.location_on_outlined,
        title: 'Location',
        value: info['location'] ?? '',
        url: '',
      ),
      _ContactItem(
        icon: FontAwesomeIcons.github,
        title: 'GitHub',
        value: 'MahmuodMurad',
        url: links['github'] ?? '',
      ),
    ];

    return Container(
      padding: Responsive.getSectionPadding(context),
      constraints:
          BoxConstraints(maxWidth: Responsive.getContentWidth(context)),
      child: Column(
        children: [
          const SectionTitle(
            title: 'Contact',
            subtitle: 'Let\'s connect',
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.isMobile(context) ? 1 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: Responsive.isMobile(context) ? 3.5 : 2.8,
            ),
            itemCount: contactItems.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final delay = index / contactItems.length;
                  final progress =
                      ((_controller.value - delay) / (1 - delay))
                          .clamp(0.0, 1.0);
                  return Opacity(
                    opacity: progress,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - progress)),
                      child: child,
                    ),
                  );
                },
                child: _WavingContactCard(
                  item: contactItems[index],
                  onTap: contactItems[index].url.isNotEmpty
                      ? () => _launchUrl(contactItems[index].url)
                      : null,
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          // Download CV Button
          _AnimatedDownloadButton(
            url: links['cv_download'] as String? ?? '',
            onLaunch: _launchUrl,
            controller: _controller,
          ),
        ],
      ),
    );
  }
}

class _ContactItem {
  final IconData icon;
  final String title;
  final String value;
  final String url;

  const _ContactItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.url,
  });
}

class _WavingContactCard extends StatefulWidget {
  final _ContactItem item;
  final VoidCallback? onTap;

  const _WavingContactCard({required this.item, this.onTap});

  @override
  State<_WavingContactCard> createState() => _WavingContactCardState();
}

class _WavingContactCardState extends State<_WavingContactCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            final waveAngle = sin(_waveController.value * 2 * pi) *
                (_isHovered ? 0.04 : 0.02);
            return Transform.rotate(
              angle: waveAngle,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: Matrix4.diagonal3Values(
                _isHovered ? 1.03 : 1.0, _isHovered ? 1.03 : 1.0, 1.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isHovered
                          ? AppColors.accentPrimary.withValues(alpha: 0.4)
                          : AppColors.accentPrimary.withValues(alpha: 0.1),
                    ),
                    boxShadow: _isHovered
                        ? [
                            BoxShadow(
                              color: AppColors.accentPrimary
                                  .withValues(alpha: 0.15),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: AppColors.accentGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          widget.item.icon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.title,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.item.value,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.accentPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (widget.onTap != null)
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color:
                              AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
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
}

class _AnimatedDownloadButton extends StatefulWidget {
  final String url;
  final Function(String) onLaunch;
  final Animation<double> controller;

  const _AnimatedDownloadButton({
    required this.url,
    required this.onLaunch,
    required this.controller,
  });

  @override
  State<_AnimatedDownloadButton> createState() =>
      _AnimatedDownloadButtonState();
}

class _AnimatedDownloadButtonState extends State<_AnimatedDownloadButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverIconController;
  late Animation<double> _iconBounceAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _iconBounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -4).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -4, end: 0).chain(
          CurveTween(curve: Curves.bounceOut),
        ),
        weight: 50,
      ),
    ]).animate(_hoverIconController);
  }

  @override
  void dispose() {
    _hoverIconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        final progress =
            ((widget.controller.value - 0.6) / 0.4).clamp(0.0, 1.0);
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - progress)),
            child: child,
          ),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          setState(() => _isHovered = true);
          _hoverIconController.repeat();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _hoverIconController.stop(canceled: false);
          _hoverIconController.reverse();
        },
        child: GestureDetector(
          onTap: widget.url.isNotEmpty ? () => widget.onLaunch(widget.url) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: Matrix4.diagonal3Values(
                _isHovered ? 1.05 : 1.0, _isHovered ? 1.05 : 1.0, 1.0),
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPrimary.withValues(
                      alpha: _isHovered ? 0.6 : 0.35),
                  blurRadius: _isHovered ? 30 : 20,
                  spreadRadius: _isHovered ? 4 : 2,
                  offset: Offset(0, _isHovered ? 8 : 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _iconBounceAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _iconBounceAnimation.value),
                      child: child,
                    );
                  },
                  child: const Icon(
                    Icons.download_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Download CV',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
