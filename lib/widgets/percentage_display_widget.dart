import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_color.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_text_styles.dart';
import '../providers/grade_provider.dart';

class PercentageDisplayWidget extends StatefulWidget {
  const PercentageDisplayWidget({super.key});

  @override
  State<PercentageDisplayWidget> createState() => _PercentageDisplayWidgetState();
}

class _PercentageDisplayWidgetState extends State<PercentageDisplayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<GradeProvider>(
      builder: (_, provider, __) {
        final pct   = provider.overallPercentage;
        final color = AppColors.percentageColor(pct);

        return AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => Container(
            margin: const EdgeInsets.fromLTRB(AppConstants.paddingLG,
                AppConstants.paddingMD, AppConstants.paddingLG, 0),
            padding: const EdgeInsets.all(AppConstants.paddingLG),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0E1828), Color(0xFF131F30)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusXL),
              border: Border.all(color: AppColors.teal.withOpacity(0.25)),
              boxShadow: [BoxShadow(color: AppColors.tealGlow, blurRadius: 24)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('OVERALL PERCENTAGE', style: AppTextStyles.label),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Text(provider.percentClassification,
                          style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    '${pct.toStringAsFixed(1)}%',
                    key: ValueKey(pct.toStringAsFixed(1)),
                    style: AppTextStyles.percentHero.copyWith(color: color),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMD),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (pct / 100).clamp(0, 1) * _anim.value,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSM),
                Row(children: [
                  _StatPill('${provider.totalScored.toStringAsFixed(0)}', 'Scored', color),
                  const SizedBox(width: 6),
                  _StatPill('${provider.totalMax.toStringAsFixed(0)}', 'Total', AppColors.textSecondary),
                  const SizedBox(width: 6),
                  _StatPill('${provider.subjects.length}', 'Subjects', AppColors.teal),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatPill(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSM),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(value, style: AppTextStyles.caption.copyWith(
            color: color, fontWeight: FontWeight.w700, fontSize: 11)),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
      ]),
    );
  }
}