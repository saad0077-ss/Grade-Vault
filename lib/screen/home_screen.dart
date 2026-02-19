import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_color.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_text_styles.dart';
import '../providers/grade_provider.dart';
import '../widgets/gpa_display_widget.dart';
import '../widgets/subject_card.dart';
import 'add_subject_screen.dart';
import 'result_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<GradeProvider>(
          builder: (_, provider, __) {
            // Show loading spinner while Hive data is being read
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              );
            }

            return Column(
              children: [
                _buildHeader(context, provider),
                const GpaDisplayWidget(),
                _buildSectionHeader(provider),
                _buildSubjectList(provider),
                _buildBottomActions(context, provider),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  Widget _buildHeader(BuildContext context, GradeProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingLG,
        AppConstants.paddingMD,
        AppConstants.paddingLG,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _showRenameSemesterDialog(context, provider),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GradeVault', style: AppTextStyles.headline),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(provider.currentSemesterName, style: AppTextStyles.caption),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit_outlined,
                        size: 12, color: AppColors.textHint),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ResultScreen()),
            ),
            icon: const Icon(Icons.history_rounded, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showRenameSemesterDialog(BuildContext context, GradeProvider provider) {
    final controller =
    TextEditingController(text: provider.currentSemesterName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        ),
        title: Text('Rename Semester', style: AppTextStyles.title),
        content: TextField(
          controller: controller,
          style: AppTextStyles.body,
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            hintText: 'e.g. Fall 2025',
            hintStyle:
            AppTextStyles.body.copyWith(color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(AppConstants.radiusMD),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.setSemesterName(controller.text.trim());
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(AppConstants.radiusSM),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(GradeProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingLG,
        AppConstants.paddingMD,
        AppConstants.paddingLG,
        AppConstants.paddingSM,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('SUBJECTS', style: AppTextStyles.label),
          Text('${provider.totalCredits} credits', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildSubjectList(GradeProvider provider) {
    if (provider.subjects.isEmpty) {
      return Expanded(child: _buildEmptyState());
    }
    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLG,
          vertical: AppConstants.paddingSM,
        ),
        itemCount: provider.subjects.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: AppConstants.paddingSM),
        itemBuilder: (_, i) => SubjectCard(
          subject: provider.subjects[i],
          onDelete: () =>
              provider.removeSubject(provider.subjects[i].id),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.school_outlined,
              size: 64, color: AppColors.textHint),
          const SizedBox(height: AppConstants.paddingMD),
          Text('No subjects yet',
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppConstants.paddingSM),
          Text('Tap + to add your first subject',
              style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildBottomActions(
      BuildContext context, GradeProvider provider) {
    if (provider.subjects.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMD),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: provider.clearSubjects,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.surfaceLight),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(AppConstants.radiusMD),
                ),
              ),
              child: const Text('Clear All'),
            ),
          ),
          const SizedBox(width: AppConstants.paddingSM),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: provider.addSemester,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(AppConstants.radiusMD),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Save Semester',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddSubjectScreen()),
      ),
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.background,
      elevation: 8,
      child: const Icon(Icons.add_rounded, size: 28),
    );
  }
}