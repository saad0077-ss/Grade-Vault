import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_color.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/gpa_calculator.dart';
import '../providers/grade_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('History & Results', style: AppTextStyles.title),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textSecondary),
        ),
      ),
      body: Consumer<GradeProvider>(
        builder: (_, provider, __) {
          return Column(
            children: [
              _buildCumulativeCard(provider),
              const SizedBox(height: AppConstants.paddingMD),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLG),
                child: Row(
                  children: [
                    Text('SEMESTER HISTORY', style: AppTextStyles.label),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingSM),
              Expanded(
                child: provider.semesters.isEmpty
                    ? _buildEmpty()
                    : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLG,
                    vertical: AppConstants.paddingSM,
                  ),
                  itemCount: provider.semesters.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: AppConstants.paddingSM),
                  itemBuilder: (_, i) {
                    final sem = provider.semesters[i];
                    final gpa = GpaCalculator.calculate(sem.subjects);
                    return _buildSemesterCard(context, sem.name, gpa,
                        sem.subjects.length, provider, sem.id);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCumulativeCard(GradeProvider provider) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingLG),
      padding: const EdgeInsets.all(AppConstants.paddingLG),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1E2E), Color(0xFF232840)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CUMULATIVE GPA', style: AppTextStyles.label),
              const SizedBox(height: 4),
              Text(
                provider.cumulativeGpa.toStringAsFixed(2),
                style: AppTextStyles.gpaDisplay.copyWith(fontSize: 48),
              ),
              Text(
                GpaCalculator.classify(provider.cumulativeGpa),
                style: AppTextStyles.caption.copyWith(color: AppColors.accent),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${provider.semesters.length}', style: AppTextStyles.headline),
              Text('semesters', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterCard(
      BuildContext context,
      String name,
      double gpa,
      int subjectCount,
      GradeProvider provider,
      String id,
      ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            ),
            child: Center(
              child: Text(
                gpa.toStringAsFixed(1),
                style: AppTextStyles.title.copyWith(color: AppColors.accent),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.paddingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.body),
                Text('$subjectCount subjects', style: AppTextStyles.caption),
              ],
            ),
          ),
          IconButton(
            onPressed: () => provider.deleteSemester(id),
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.textHint, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timeline_rounded, size: 56, color: AppColors.textHint),
          const SizedBox(height: AppConstants.paddingMD),
          Text('No saved semesters', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text('Save a semester from home to see history', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}