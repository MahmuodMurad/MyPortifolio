import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/app_colors.dart';
import '../models/project_model.dart';

class MobileProjectsView extends StatefulWidget {
  final List<ProjectModel> projects;

  const MobileProjectsView({super.key, required this.projects});

  @override
  State<MobileProjectsView> createState() => _MobileProjectsViewState();
}

class _MobileProjectsViewState extends State<MobileProjectsView> {
  late final PageController _pageController;
  int _currentPage = 0;
  String _selectedCategory = 'All';
  bool _isDeckMode = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> get _categories {
    final set = {'All'};
    for (final p in widget.projects) {
      if (p.category.toLowerCase().contains('market')) {
        set.add('Marketplace');
      } else if (p.category.toLowerCase().contains('commerce') ||
          p.category.toLowerCase().contains('b2b')) {
        set.add('E-Commerce');
      } else if (p.category.toLowerCase().contains('health') ||
          p.category.toLowerCase().contains('fitness')) {
        set.add('Health & Fitness');
      } else if (p.category.toLowerCase().contains('demand') ||
          p.category.toLowerCase().contains('delivery')) {
        set.add('On-Demand');
      }
    }
    return set.toList();
  }

  List<ProjectModel> get _filteredProjects {
    if (_selectedCategory == 'All') return widget.projects;
    return widget.projects.where((p) {
      final cat = p.category.toLowerCase();
      if (_selectedCategory == 'Marketplace') return cat.contains('market');
      if (_selectedCategory == 'E-Commerce') {
        return cat.contains('commerce') || cat.contains('b2b');
      }
      if (_selectedCategory == 'Health & Fitness') {
        return cat.contains('health') || cat.contains('fitness');
      }
      if (_selectedCategory == 'On-Demand') {
        return cat.contains('demand') || cat.contains('delivery');
      }
      return true;
    }).toList();
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProjects;

    return Column(
      children: [
        // 1. Mobile Filter Chips & View Mode Toggle
        _buildControlsHeader(filtered.length),
        const SizedBox(height: 16),

        // 2. View Mode: Deck Swipe vs List Feed
        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            child: Text(
              'No projects in this category',
              style: GoogleFonts.poppins(color: AppColors.textMuted),
            ),
          )
        else if (_isDeckMode)
          _buildDeckView(filtered)
        else
          _buildListView(filtered),
      ],
    );
  }

  Widget _buildControlsHeader(int count) {
    return Column(
      children: [
        // Mode Switcher row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accentPrimary.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  '$count Products',
                  style: GoogleFonts.outfit(
                    color: AppColors.accentSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              // Toggle Buttons
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.accentPrimary.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    _ModeToggleButton(
                      icon: Icons.view_carousel_rounded,
                      label: 'Deck',
                      isActive: _isDeckMode,
                      onTap: () => setState(() => _isDeckMode = true),
                    ),
                    _ModeToggleButton(
                      icon: Icons.format_list_bulleted_rounded,
                      label: 'Feed',
                      isActive: !_isDeckMode,
                      onTap: () => setState(() => _isDeckMode = false),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Filter Chips Horizontal Scroll
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = _categories[i];
              final isSelected = cat == _selectedCategory;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = cat;
                    _currentPage = 0;
                  });
                  if (_pageController.hasClients) {
                    _pageController.jumpToPage(0);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accentPrimary.withValues(alpha: 0.2)
                        : AppColors.surface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accentPrimary
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    cat,
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.accentPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeckView(List<ProjectModel> projects) {
    return Column(
      children: [
        SizedBox(
          height: 480,
          child: PageView.builder(
            controller: _pageController,
            itemCount: projects.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, i) {
              final project = projects[i];
              final isActive = i == _currentPage;
              return AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: isActive ? 1.0 : 0.94,
                curve: Curves.easeOutCubic,
                child: _MobileProjectDeckCard(
                  project: project,
                  onDetailsTap: () => _showProjectDetailsSheet(context, project),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Deck indicator bar
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
              color: _currentPage > 0
                  ? AppColors.accentPrimary
                  : AppColors.textMuted.withValues(alpha: 0.4),
              onPressed: _currentPage > 0
                  ? () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      )
                  : null,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accentPrimary.withValues(alpha: 0.15),
                ),
              ),
              child: Text(
                '${_currentPage + 1} / ${projects.length}',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentSecondary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              color: _currentPage < projects.length - 1
                  ? AppColors.accentPrimary
                  : AppColors.textMuted.withValues(alpha: 0.4),
              onPressed: _currentPage < projects.length - 1
                  ? () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      )
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListView(List<ProjectModel> projects) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final project = projects[i];
        return _MobileProjectFeedTile(
          project: project,
          onTap: () => _showProjectDetailsSheet(context, project),
        );
      },
    );
  }

  void _showProjectDetailsSheet(BuildContext context, ProjectModel project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ProjectDetailsModalSheet(
          project: project,
          onLaunchUrl: _launchUrl,
        );
      },
    );
  }
}

class _ModeToggleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeToggleButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accentPrimary.withValues(alpha: 0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? AppColors.accentPrimary : AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11.5,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                color:
                    isActive ? AppColors.accentPrimary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileProjectDeckCard extends StatefulWidget {
  final ProjectModel project;
  final VoidCallback onDetailsTap;

  const _MobileProjectDeckCard({
    required this.project,
    required this.onDetailsTap,
  });

  @override
  State<_MobileProjectDeckCard> createState() => _MobileProjectDeckCardState();
}

class _MobileProjectDeckCardState extends State<_MobileProjectDeckCard> {
  int _activeImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final images = project.images;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.accentPrimary.withValues(alpha: 0.24),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top App Store style Header
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Row(
                  children: [
                    // App Icon Squircle
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentPrimary.withValues(alpha: 0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          project.name.isNotEmpty
                              ? project.name.substring(0, 1).toUpperCase()
                              : 'P',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            project.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.accentPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action Pill Button
                    GestureDetector(
                      onTap: widget.onDetailsTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.accentGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'OPEN',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 10,
                              color: AppColors.ink,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Interactive Screenshot Frame
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(color: AppColors.ink),
                        if (images.isNotEmpty)
                          Image.asset(
                            images[_activeImageIndex % images.length],
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(
                                Icons.phone_iphone_rounded,
                                size: 48,
                                color: AppColors.accentPrimary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          )
                        else
                          Center(
                            child: Icon(
                              Icons.phone_iphone_rounded,
                              size: 48,
                              color: AppColors.accentPrimary.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        // Gradient Overlay on bottom
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: 60,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Screenshot dots if multiple
                        if (images.length > 1)
                          Positioned(
                            bottom: 8,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(images.length, (idx) {
                                final isCur = idx == _activeImageIndex;
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _activeImageIndex = idx),
                                  child: Container(
                                    width: isCur ? 16 : 6,
                                    height: 5,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 2.5,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      color: isCur
                                          ? AppColors.accentSecondary
                                          : Colors.white.withValues(alpha: 0.4),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Info Card
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Impact Badge
                    if (project.impact.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.ink.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.accentSecondary.withValues(
                              alpha: 0.35,
                            ),
                          ),
                        ),
                        child: Text(
                          '⚡ ${project.impact}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentSecondary,
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    // Technologies preview
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: project.technologies.take(4).map((tech) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tech,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    // Tap for specs link
                    GestureDetector(
                      onTap: widget.onDetailsTap,
                      child: Row(
                        children: [
                          Text(
                            'View Specs, Architecture & Stores',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.north_east_rounded,
                            size: 13,
                            color: AppColors.accentPrimary,
                          ),
                        ],
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

class _MobileProjectFeedTile extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onTap;

  const _MobileProjectFeedTile({
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.accentPrimary.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              children: [
                // App Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      project.name.isNotEmpty
                          ? project.name.substring(0, 1).toUpperCase()
                          : 'P',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        project.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.accentPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (project.impact.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '⚡ ${project.impact}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.accentSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.accentPrimary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: AppColors.accentPrimary,
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

class _ProjectDetailsModalSheet extends StatelessWidget {
  final ProjectModel project;
  final Function(String) onLaunchUrl;

  const _ProjectDetailsModalSheet({
    required this.project,
    required this.onLaunchUrl,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: AppColors.background.withValues(alpha: 0.95),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header with Icon
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: AppColors.accentGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            project.name.isNotEmpty
                                ? project.name.substring(0, 1).toUpperCase()
                                : 'P',
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              project.category,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.accentPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        color: AppColors.textMuted,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Impact Pill
                  if (project.impact.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.accentSecondary.withValues(
                            alpha: 0.35,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            size: 16,
                            color: AppColors.accentSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              project.impact,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Screenshots Gallery
                  if (project.images.isNotEmpty) ...[
                    Text(
                      'Screenshots Gallery',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: project.images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              project.images[i],
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Description
                  Text(
                    'About Project',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    project.description,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tech Stack
                  Text(
                    'Technologies & Architecture',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: project.technologies.map((tech) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.accentPrimary.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: Text(
                          tech,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Store & Launch Links
                  if (project.links.isNotEmpty) ...[
                    Text(
                      'Live Stores & Links',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...project.links.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () => onLaunchUrl(entry.value),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: AppColors.accentGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentPrimary.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                _buildIconForLink(
                                  entry.key,
                                  AppColors.ink,
                                  18,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _labelForLink(entry.key),
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.open_in_new_rounded,
                                  size: 16,
                                  color: AppColors.ink,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildIconForLink(String key, Color color, double size) {
    if (key.contains('app_store')) {
      return Icon(Icons.phone_iphone_rounded, color: color, size: size);
    }
    if (key.contains('play')) {
      return Icon(Icons.play_arrow_rounded, color: color, size: size);
    }
    if (key.contains('dashboard')) {
      return Icon(Icons.dashboard_rounded, color: color, size: size);
    }
    if (key.contains('github')) {
      return FaIcon(FontAwesomeIcons.github, color: color, size: size);
    }
    return Icon(Icons.launch_rounded, color: color, size: size);
  }

  static String _labelForLink(String key) {
    switch (key) {
      case 'play_store':
        return 'Download on Google Play';
      case 'app_store':
        return 'Download on Apple App Store';
      case 'admin_play':
        return 'Admin App (Google Play)';
      case 'admin_app_store':
        return 'Admin App (App Store)';
      case 'store_play':
        return 'Store Partner App (Play)';
      case 'dashboard':
        return 'Open Web Dashboard';
      case 'themes':
        return 'View Themes & Demos';
      case 'github':
        return 'View GitHub Repository';
      default:
        return 'Open External Link';
    }
  }
}
