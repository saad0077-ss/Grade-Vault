import 'package:flutter/material.dart';
import 'package:grade_vault/screen/semester_details_screen.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_color.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/gpa_calculator.dart';
import '../models/semester_model.dart';
import '../providers/grade_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GradeProvider>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('History', style: AppTextStyles.headline),
                  Text('Tap a semester to view & edit',
                      style: AppTextStyles.caption),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Text('${provider.semesters.length} saved',
                      style: AppTextStyles.caption),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMD),

            // Cumulative card
            _buildCumulativeCard(provider),
            const SizedBox(height: AppConstants.paddingMD),

            Text('SEMESTERS', style: AppTextStyles.label),
            const SizedBox(height: AppConstants.paddingSM),

            // List
            Expanded(
              child: provider.semesters.isEmpty
                  ? _buildEmpty()
                  : ListView.separated(
                itemCount: provider.semesters.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: AppConstants.paddingSM),
                itemBuilder: (_, i) {
                  final sem = provider.semesters[i];
                  return _buildSemCard(context, sem, provider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCumulativeCard(GradeProvider provider) {
    final usesGpa = provider.usesGpa;
    final value = usesGpa
        ? provider.cumulativeGpa.toStringAsFixed(2)
        : '${provider.cumulativePercentage.toStringAsFixed(1)}%';
    final label = usesGpa
        ? provider.gpaClassification
        : GpaCalculator.classifyPercentage(provider.cumulativePercentage);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLG),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1F35), Color(0xFF111523)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: AppColors.accentGlow, blurRadius: 20)],
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('CUMULATIVE', style: AppTextStyles.label),
            const SizedBox(height: 4),
            Text(value, style: AppTextStyles.gpaHero.copyWith(fontSize: 44)),
            Text(label,
                style: AppTextStyles.caption.copyWith(color: AppColors.accent)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${provider.semesters.length}', style: AppTextStyles.headline),
          Text('saved', style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(
              '${provider.semesters.fold(0, (a, s) => a + s.subjects.length)}',
              style: AppTextStyles.headline),
          Text('subjects', style: AppTextStyles.caption),
        ]),
      ]),
    );
  }

  Widget _buildSemCard(
      BuildContext context, SemesterModel sem, GradeProvider provider) {
    final usesGpa = sem.studentType == 'undergraduate' ||
        sem.studentType == 'postgraduate';
    final gpa = GpaCalculator.calculate(sem.subjects);
    final pct = GpaCalculator.overallPercentage(sem.subjects);
    final value = usesGpa ? gpa : pct;
    final color = usesGpa
        ? AppColors.gradeColor(GpaCalculator.percentageToGrade(gpa / 4.0 * 100))
        : AppColors.percentageColor(pct);

    final bestSubject = sem.subjects.isEmpty
        ? null
        : sem.subjects.reduce((a, b) {
      if (usesGpa) {
        return (AppConstants.gradePoints[a.grade] ?? 0) >=
            (AppConstants.gradePoints[b.grade] ?? 0)
            ? a
            : b;
      } else {
        return (a.percentage ?? 0) >= (b.percentage ?? 0) ? a : b;
      }
    });

    return Dismissible(
      key: Key(sem.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusLG)),
            title: Text('Delete Semester', style: AppTextStyles.title),
            content: Text('Delete "${sem.name}"? This cannot be undone.',
                style: AppTextStyles.body),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel',
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rose,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(AppConstants.radiusSM)),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => provider.deleteSemester(sem.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppConstants.paddingLG),
        decoration: BoxDecoration(
          color: AppColors.rose.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.delete_rounded, color: AppColors.rose),
          const SizedBox(height: 4),
          Text('Delete', style: AppTextStyles.caption.copyWith(color: AppColors.rose)),
        ]),
      ),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SemesterDetailScreen(semester: sem),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingMD),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusLG),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                // Grade badge
                Container(
                  width: 58, height: 58,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      usesGpa
                          ? value.toStringAsFixed(1)
                          : '${value.toStringAsFixed(0)}%',
                      style: AppTextStyles.caption.copyWith(
                          color: color,
                          fontWeight: FontWeight.w900,
                          fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMD),

                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(sem.name,
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(
                      '${sem.subjects.length} subjects  •  ${sem.createdAt.day}/${sem.createdAt.month}/${sem.createdAt.year}',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      usesGpa
                          ? GpaCalculator.classify(gpa)
                          : GpaCalculator.classifyPercentage(pct),
                      style: AppTextStyles.caption
                          .copyWith(color: color, fontWeight: FontWeight.w600),
                    ),
                  ]),
                ),

                // Arrow with edit hint
                Column(children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                    ),
                    child: const Icon(Icons.edit_rounded,
                        color: AppColors.textSecondary, size: 16),
                  ),
                  const SizedBox(height: 4),
                  Text('Edit', style: AppTextStyles.caption.copyWith(fontSize: 9)),
                ]),
              ]),

              // Best subject chip
              if (bestSubject != null) ...[
                const SizedBox(height: AppConstants.paddingSM),
                const Divider(color: AppColors.cardBorder, height: 1),
                const SizedBox(height: AppConstants.paddingSM),
                Row(children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.accent, size: 14),
                  const SizedBox(width: 5),
                  Text('Best: ',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary)),
                  Text(bestSubject.name,
                      style: AppTextStyles.caption
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 4),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      usesGpa
                          ? bestSubject.grade
                          : '${bestSubject.percentage?.toStringAsFixed(0)}%',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.accent, fontWeight: FontWeight.w700,
                          fontSize: 10),
                    ),
                  ),
                  const Spacer(),
                  // Subject grade mini pills
                  ...sem.subjects.take(4).map((s) {
                    final c = usesGpa
                        ? AppColors.gradeColor(s.grade)
                        : AppColors.percentageColor(s.percentage ?? 0);
                    return Container(
                      width: 20, height: 20,
                      margin: const EdgeInsets.only(left: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.withOpacity(0.2),
                        border: Border.all(color: c.withOpacity(0.4)),
                      ),
                      child: Center(
                        child: Text(
                          usesGpa ? s.grade[0] : '${(s.percentage ?? 0).toStringAsFixed(0)}',
                          style: TextStyle(
                              color: c, fontSize: 8, fontWeight: FontWeight.w800),
                        ),
                      ),
                    );
                  }),
                  if (sem.subjects.length > 4)
                    Container(
                      width: 20, height: 20,
                      margin: const EdgeInsets.only(left: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceLight,
                      ),
                      child: Center(
                        child: Text(
                          '+${sem.subjects.length - 4}',
                          style: AppTextStyles.caption
                              .copyWith(fontSize: 7, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                ]),
              ],
            ],
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
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Icon(Icons.history_rounded,
                size: 36, color: AppColors.textHint),
          ),
          const SizedBox(height: AppConstants.paddingMD),
          Text('No saved semesters',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text('Save a semester from the Home tab',
              style: AppTextStyles.caption),
        ],
      ),
    );
  }
}