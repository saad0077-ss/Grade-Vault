import 'package:flutter/material.dart';
import '../core/constants/app_color.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/gpa_calculator.dart';
import '../models/subject_model.dart';

class SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  final VoidCallback onDelete;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final gradeColor = AppColors.gradeColor(subject.grade);
    final points = AppConstants.gradePoints[subject.grade] ?? 0.0;

    return Dismissible(
      key: Key(subject.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppConstants.paddingLG),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.danger),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMD),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border(
            left: BorderSide(color: gradeColor, width: 3),
          ),
        ),
        child: Row(
          children: [
            // Grade Badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: gradeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppConstants.radiusSM),
              ),
              child: Center(
                child: Text(
                  subject.grade,
                  style: TextStyle(
                    color: gradeColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.paddingMD),
            // Name & Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subject.name,
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    '${subject.credits} credits  •  ${points.toStringAsFixed(1)} pts',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            // Points pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppConstants.radiusSM),
              ),
              child: Text(
                (points * subject.credits).toStringAsFixed(1),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}