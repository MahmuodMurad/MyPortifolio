import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/data/cv_data_provider.dart';
import '../../../core/widgets/animated_background.dart';
import '../cubit/navigation_cubit.dart';
import '../../about/ui/about_section.dart';
import '../../experience/ui/experience_section.dart';
import '../../projects/ui/projects_section.dart';
import '../../skills/ui/skills_section.dart';
import '../../contact/ui/contact_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = List.generate(5, (_) => GlobalKey());
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await CvDataProvider.loadCvData();
    if (mounted) setState(() => _isLoading = false);
  }

  void _scrollToSection(int index) {
    final key = _sectionKeys[index];
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accentPrimary),
        ),
      );
    }

    return BlocProvider(
      create: (_) => NavigationCubit(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: AnimatedBackground(
          child: Column(
            children: [
              _buildNavBar(),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      AboutSection(key: _sectionKeys[0]),
                      ExperienceSection(key: _sectionKeys[1]),
                      ProjectsSection(key: _sectionKeys[2]),
                      SkillsSection(key: _sectionKeys[3]),
                      ContactSection(key: _sectionKeys[4]),
                      const SizedBox(height: 40),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavBar() {
    return BlocBuilder<NavigationCubit, int>(
      builder: (context, activeIndex) {
        final isMobile = MediaQuery.of(context).size.width < 600;
        if (isMobile) {
          return _buildMobileNavBar(context, activeIndex);
        }
        return _buildDesktopNavBar(context, activeIndex);
      },
    );
  }

  Widget _buildDesktopNavBar(BuildContext context, int activeIndex) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.85),
        border: Border(
          bottom: BorderSide(
            color: AppColors.accentPrimary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.accentGradient.createShader(bounds),
            child: Text(
              'M.Murad',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          ...List.generate(NavigationCubit.sectionNames.length, (i) {
            final isActive = i == activeIndex;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextButton(
                onPressed: () {
                  context.read<NavigationCubit>().updateSection(i);
                  _scrollToSection(i);
                },
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      NavigationCubit.sectionNames[i],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w400,
                        color: isActive
                            ? AppColors.accentPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 2,
                      width: isActive ? 30 : 0,
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMobileNavBar(BuildContext context, int activeIndex) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: AppColors.accentPrimary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.accentGradient.createShader(bounds),
            child: Text(
              'M.Murad',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          PopupMenuButton<int>(
            icon: const Icon(Icons.menu, color: AppColors.accentPrimary),
            color: AppColors.surface,
            onSelected: (i) {
              context.read<NavigationCubit>().updateSection(i);
              _scrollToSection(i);
            },
            itemBuilder: (_) => List.generate(
              NavigationCubit.sectionNames.length,
              (i) => PopupMenuItem(
                value: i,
                child: Text(
                  NavigationCubit.sectionNames[i],
                  style: GoogleFonts.poppins(
                    color: i == activeIndex
                        ? AppColors.accentPrimary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        '© 2026 Mahmoud Murad. Built with Flutter.',
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: AppColors.textSecondary.withValues(alpha: 0.6),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
