
import 'package:flutter/material.dart';
import '../core/constants/app_color.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_text_styles.dart';

class GradeDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const GradeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          isExpanded: true,
          dropdownColor: AppColors.card,
          style: AppTextStyles.body,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary),
          items: AppConstants.gradeOptions.map((grade) {
            final color = AppColors.gradeColor(grade);
            final points = AppConstants.gradePoints[grade] ?? 0.0;
            return DropdownMenuItem<String>(
              value: grade,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        grade,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(grade, style: AppTextStyles.body),
                  const Spacer(),
                  Text(
                    '${points.toStringAsFixed(1)} pts',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}