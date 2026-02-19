import 'package:flutter/material.dart';
import 'package:grade_vault/screen/profile_screen.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_color.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/student_type.dart';
import '../providers/grade_provider.dart';
import '../widgets/animated_list_items.dart';
import '../widgets/gpa_display_widget.dart';
import '../widgets/percentage_display_widget.dart';
import '../widgets/subject_card.dart';
import 'add_subject_screen.dart';
import 'history_screen.dart';
import 'analytics_screen.dart';
import 'target_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabController;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  final List<_NavItem> _navItems = const [
    _NavItem(Icons.home_rounded, 'Home'),
    _NavItem(Icons.bar_chart_rounded, 'Analytics'),
    _NavItem(Icons.history_rounded, 'History'),
    _NavItem(Icons.track_changes_rounded, 'Target'),
  ];

  Widget _buildPage(int index, GradeProvider provider) {
    switch (index) {
      case 0: return _buildHomeContent(provider);
      case 1: return const AnalyticsScreen();
      case 2: return const HistoryScreen();
      case 3: return const TargetScreen();
      default: return _buildHomeContent(provider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<GradeProvider>(
        builder: (_, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }
          return _buildPage(_currentTab, provider);
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _currentTab == 0 ? _buildFab() : null,
    );
  }

  Widget _buildHomeContent(GradeProvider provider) {
    return Column(
      children: [
        _buildHeader(provider),
        provider.usesGpa
            ? const GpaDisplayWidget()
            : const PercentageDisplayWidget(),
        _buildSectionHeader(provider),
        _buildSubjectList(provider),
        if (provider.subjects.isNotEmpty) _buildBottomActions(provider),
      ],
    );
  }

  Widget _buildHeader(GradeProvider provider) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingLG, AppConstants.paddingMD,
            AppConstants.paddingLG, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => _showRenameDialog(provider),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text('GradeVault', style: AppTextStyles.headline),
                    const SizedBox(width: 6),
                    Text(provider.studentType?.emoji ?? '🎓',
                        style: const TextStyle(fontSize: 20)),
                  ]),
                  Row(children: [
                    Text(provider.currentSemesterName,
                        style: AppTextStyles.caption),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit_outlined,
                        size: 11, color: AppColors.textHint),
                  ]),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _HeaderBtn(Icons.notifications_none_rounded, onTap: () {}),
                _HeaderBtn(Icons.person_outline_rounded, onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()));
                }),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(GradeProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppConstants.paddingLG,
          AppConstants.paddingMD, AppConstants.paddingLG, AppConstants.paddingSM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('SUBJECTS', style: AppTextStyles.label),
          Text(
            provider.usesGpa
                ? '${provider.totalCredits} credits'
                : '${provider.subjects.length} subjects',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectList(GradeProvider provider) {
    if (provider.subjects.isEmpty) return Expanded(child: _buildEmpty());
    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLG,
            vertical: AppConstants.paddingSM),
        itemCount: provider.subjects.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: AppConstants.paddingSM),
        itemBuilder: (_, i) => AnimatedListItem(
          index: i,
          child: SubjectCard(
            subject: provider.subjects[i],
            usesGpa: provider.usesGpa,
            onDelete: () => provider.removeSubject(provider.subjects[i].id),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Icon(Icons.add_chart_rounded,
                size: 44, color: AppColors.textHint),
          ),
          const SizedBox(height: AppConstants.paddingLG),
          Text('No subjects yet',
              style: AppTextStyles.title.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text('Tap + to add your first subject', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildBottomActions(GradeProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppConstants.paddingLG, 0,
          AppConstants.paddingLG, AppConstants.paddingMD),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: provider.clearSubjects,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.cardBorder),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD)),
              ),
              child: const Text('Clear All'),
            ),
          ),
          const SizedBox(width: AppConstants.paddingSM),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: provider.saveSemester,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD)),
                elevation: 0,
              ),
              child: const Text('Save Semester',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (i) {
              final item = _navItems[i];
              final active = _currentTab == i;
              return GestureDetector(
                onTap: () => setState(() => _currentTab = i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? AppColors.accentGlow : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(item.icon,
                        color: active ? AppColors.accent : AppColors.textHint,
                        size: 22),
                    const SizedBox(height: 4),
                    Text(item.label,
                        style: AppTextStyles.caption.copyWith(
                          color: active ? AppColors.accent : AppColors.textHint,
                          fontSize: 10,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                        )),
                  ]),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AddSubjectScreen())),
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.background,
      elevation: 8,
      child: const Icon(Icons.add_rounded, size: 28),
    );
  }

  void _showRenameDialog(GradeProvider provider) {
    final ctrl = TextEditingController(text: provider.currentSemesterName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLG)),
        title: Text('Rename Semester', style: AppTextStyles.title),
        content: TextField(
          controller: ctrl,
          style: AppTextStyles.body,
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            hintText: 'e.g. Fall 2025',
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                provider.setSemesterName(ctrl.text.trim());
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSM)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

class _HeaderBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderBtn(this.icon, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.textSecondary, size: 20),
      visualDensity: VisualDensity.compact,
    );
  }
}