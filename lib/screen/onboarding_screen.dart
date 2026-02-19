import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_color.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/student_type.dart';
import '../providers/grade_provider.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  StudentType? _selected;
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeIn  = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideUp = Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final List<_TypeCard> _cards = [
    _TypeCard(StudentType.seniorSecondary,
        color: AppColors.mint, icon: Icons.menu_book_rounded),
    _TypeCard(StudentType.higherSecondary,
        color: AppColors.teal, icon: Icons.auto_stories_rounded),
    _TypeCard(StudentType.undergraduate,
        color: AppColors.accent, icon: Icons.school_rounded),
    _TypeCard(StudentType.postgraduate,
        color: AppColors.violet, icon: Icons.local_library_rounded),
  ];

  void _proceed() async {
    if (_selected == null) return;
    await context.read<GradeProvider>().setStudentType(_selected!);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(
            position: _slideUp,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppConstants.paddingXL),
                  _buildHeader(),
                  const SizedBox(height: AppConstants.paddingXXL),
                  Text('CHOOSE YOUR LEVEL', style: AppTextStyles.label),
                  const SizedBox(height: AppConstants.paddingMD),
                  Expanded(child: _buildGrid()),
                  const SizedBox(height: AppConstants.paddingMD),
                  _buildProceedButton(),
                  const SizedBox(height: AppConstants.paddingMD),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.accentDark]),
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            boxShadow: [BoxShadow(color: AppColors.accentGlow, blurRadius: 20)],
          ),
          child: const Icon(Icons.waving_hand_rounded,
              color: AppColors.background, size: 28),
        ),
        const SizedBox(height: AppConstants.paddingMD),
        Text('Welcome to\nGradeVault', style: AppTextStyles.display),
        const SizedBox(height: AppConstants.paddingSM),
        Text(
          'Tell us who you are so we can tailor\nyour grade tracking experience.',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: AppConstants.paddingMD,
      crossAxisSpacing: AppConstants.paddingMD,
      childAspectRatio: 1.0,
      children: _cards.map((c) => _buildTypeCard(c)).toList(),
    );
  }

  Widget _buildTypeCard(_TypeCard card) {
    final isSelected = _selected == card.type;
    return GestureDetector(
      onTap: () => setState(() => _selected = card.type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected
              ? card.color.withOpacity(0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          border: Border.all(
            color: isSelected ? card.color : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: card.color.withOpacity(0.2), blurRadius: 20)]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: card.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                    ),
                    child: Icon(card.icon, color: card.color, size: 22),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle_rounded, color: card.color, size: 20),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(card.type.emoji,
                      style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text(card.type.label,
                      style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? card.color : AppColors.textPrimary)),
                  Text(card.type.subtitle, style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProceedButton() {
    return AnimatedOpacity(
      opacity: _selected != null ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 300),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _selected != null ? _proceed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.background,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLG),
            ),
            elevation: 0,
          ),
          child: const Text('Get Started',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        ),
      ),
    );
  }
}

class _TypeCard {
  final StudentType type;
  final Color color;
  final IconData icon;
  const _TypeCard(this.type, {required this.color, required this.icon});
}