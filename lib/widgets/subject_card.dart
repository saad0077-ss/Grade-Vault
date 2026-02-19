import 'package:flutter/material.dart';
import '../core/constants/app_color.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_text_styles.dart';
import '../models/subject_model.dart';

class SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  final bool usesGpa;
  final VoidCallback onDelete;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.usesGpa,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = usesGpa
        ? AppColors.gradeColor(subject.grade)
        : AppColors.percentageColor(subject.percentage ?? 0);

    final badgeText = usesGpa
        ? subject.grade
        : '${subject.percentage?.toStringAsFixed(0) ?? '--'}%';

    final subText = usesGpa
        ? '${subject.credits} credits  •  ${(AppConstants.gradePoints[subject.grade] ?? 0).toStringAsFixed(1)} pts'
        : '${subject.marksScored?.toStringAsFixed(0) ?? '--'} / ${subject.maxMarks?.toStringAsFixed(0) ?? '--'}';

    return Dismissible(
      key: Key(subject.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppConstants.paddingLG),
        decoration: BoxDecoration(
          color: AppColors.rose.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.rose),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMD),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left accent bar
            Container(
              width: 3,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppConstants.paddingMD),

            // Grade badge
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                border: Border.all(color: color.withOpacity(0.25)),
              ),
              child: Center(
                child: Text(badgeText,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: badgeText.length > 3 ? 11 : 14,
                    )),
              ),
            ),
            const SizedBox(width: AppConstants.paddingMD),

            // Name and info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subject.name,
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(subText, style: AppTextStyles.caption),
                ],
              ),
            ),

            // Weighted points chip
            if (usesGpa)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  ((AppConstants.gradePoints[subject.grade] ?? 0) * subject.credits).toStringAsFixed(1),
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
      ),
    );
  }
}