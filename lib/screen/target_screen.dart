import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_color.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/gpa_calculator.dart';
import '../providers/grade_provider.dart';

class TargetScreen extends StatefulWidget {
  const TargetScreen({super.key});

  @override
  State<TargetScreen> createState() => _TargetScreenState();
}

class _TargetScreenState extends State<TargetScreen> {
  final _targetGpaCtrl     = TextEditingController(text: '3.5');
  final _targetPctCtrl     = TextEditingController(text: '75');
  final _remainingCtrl     = TextEditingController(text: '100');
  double? _neededMarks;
  double? _neededGpa;

  @override
  void dispose() {
    _targetGpaCtrl.dispose();
    _targetPctCtrl.dispose();
    _remainingCtrl.dispose();
    super.dispose();
  }

  void _calculate(GradeProvider provider) {
    if (provider.usesGpa) {
      final target = double.tryParse(_targetGpaCtrl.text);
      if (target == null) return;
      setState(() => _neededGpa = target);
    } else {
      final target    = double.tryParse(_targetPctCtrl.text);
      final remaining = double.tryParse(_remainingCtrl.text);
      if (target == null || remaining == null) return;
      final needed = GpaCalculator.marksNeeded(
        subjects: provider.subjects,
        targetPct: target,
        remainingMaxMarks: remaining,
      );
      setState(() => _neededMarks = needed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GradeProvider>();
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Target Calculator', style: AppTextStyles.headline),
            Text('Find out what you need', style: AppTextStyles.caption),
            const SizedBox(height: AppConstants.paddingLG),
            _buildCurrentStatus(provider),
            const SizedBox(height: AppConstants.paddingLG),
            provider.usesGpa
                ? _buildGpaTarget(provider)
                : _buildPercentageTarget(provider),
            const SizedBox(height: AppConstants.paddingLG),
            if (_neededMarks != null || _neededGpa != null)
              _buildResult(provider),
            const SizedBox(height: AppConstants.paddingLG),
            _buildGpaScaleReference(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatus(GradeProvider provider) {
    final usesGpa = provider.usesGpa;
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLG),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1F35), Color(0xFF111523)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: AppColors.tealGlow, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CURRENT STATUS', style: AppTextStyles.label),
                const SizedBox(height: 8),
                Text(
                  usesGpa
                      ? provider.currentGpa.toStringAsFixed(2)
                      : '${provider.overallPercentage.toStringAsFixed(1)}%',
                  style: AppTextStyles.gpaHero.copyWith(
                      fontSize: 48, color: AppColors.teal),
                ),
                Text(
                  usesGpa ? provider.gpaClassification : provider.percentClassification,
                  style: AppTextStyles.caption.copyWith(color: AppColors.teal),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (usesGpa) ...[
                Text('${provider.totalCredits}', style: AppTextStyles.title),
                Text('credits', style: AppTextStyles.caption),
              ] else ...[
                Text('${provider.subjects.length}', style: AppTextStyles.title),
                Text('subjects', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Text('${provider.totalScored.toStringAsFixed(0)}/${provider.totalMax.toStringAsFixed(0)}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.teal)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGpaTarget(GradeProvider provider) {
    return _buildCard(
      title: 'GPA Target',
      icon: Icons.track_changes_rounded,
      color: AppColors.violet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What GPA are you aiming for?', style: AppTextStyles.caption),
          const SizedBox(height: AppConstants.paddingMD),
          _buildSlider(
            label: 'Target GPA',
            value: double.tryParse(_targetGpaCtrl.text) ?? 3.5,
            min: 0, max: 4,
            color: AppColors.violet,
            display: (v) => v.toStringAsFixed(1),
            onChanged: (v) {
              setState(() {
                _targetGpaCtrl.text = v.toStringAsFixed(1);
                _neededGpa = v;
              });
            },
          ),
          const SizedBox(height: AppConstants.paddingMD),
          _buildRequirementsList(
              double.tryParse(_targetGpaCtrl.text) ?? 3.5, provider),
        ],
      ),
    );
  }

  Widget _buildPercentageTarget(GradeProvider provider) {
    return _buildCard(
      title: 'Marks Target',
      icon: Icons.track_changes_rounded,
      color: AppColors.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Target percentage you want to achieve', style: AppTextStyles.caption),
          const SizedBox(height: AppConstants.paddingMD),
          _buildSlider(
            label: 'Target %',
            value: double.tryParse(_targetPctCtrl.text) ?? 75,
            min: 35, max: 100,
            color: AppColors.accent,
            display: (v) => '${v.toStringAsFixed(0)}%',
            onChanged: (v) => setState(() => _targetPctCtrl.text = v.toStringAsFixed(0)),
          ),
          const SizedBox(height: AppConstants.paddingMD),
          Text('REMAINING MAX MARKS', style: AppTextStyles.label),
          const SizedBox(height: AppConstants.paddingSM),
          TextFormField(
            controller: _remainingCtrl,
            style: AppTextStyles.body,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            cursorColor: AppColors.accent,
            decoration: InputDecoration(
              hintText: 'e.g. 300',
              hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
              filled: true, fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(AppConstants.paddingMD),
            ),
          ),
          const SizedBox(height: AppConstants.paddingMD),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _calculate(provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD)),
              ),
              child: const Text('Calculate',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required Color color,
    required String Function(double) display,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: AppTextStyles.caption),
          Text(display(value),
              style: AppTextStyles.title.copyWith(color: color)),
        ]),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: AppColors.surfaceLight,
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min, max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementsList(double targetGpa, GradeProvider provider) {
    final diff = targetGpa - provider.currentGpa;
    final color = diff <= 0 ? AppColors.gradeA : AppColors.accent;
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMD),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(diff <= 0 ? Icons.check_circle_rounded : Icons.info_rounded,
            color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            diff <= 0
                ? 'You have already met this target! 🎉'
                : 'You need ${diff.toStringAsFixed(2)} more GPA points to reach ${targetGpa.toStringAsFixed(1)}',
            style: AppTextStyles.body.copyWith(color: color),
          ),
        ),
      ]),
    );
  }

  Widget _buildResult(GradeProvider provider) {
    final isMarks = _neededMarks != null;
    final value   = isMarks
        ? '${_neededMarks!.toStringAsFixed(1)} marks'
        : '${_neededGpa!.toStringAsFixed(2)} GPA';
    final color = AppColors.accent;

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLG),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: color.withOpacity(0.4)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 20)],
      ),
      child: Row(children: [
        Icon(Icons.emoji_events_rounded, color: color, size: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('You need at least', style: AppTextStyles.caption),
            Text(value, style: AppTextStyles.title.copyWith(color: color)),
            Text(
              isMarks ? 'in your remaining exams' : 'target to aim for',
              style: AppTextStyles.caption,
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildGpaScaleReference() {
    return _buildCard(
      title: 'GPA Scale Reference',
      icon: Icons.info_outline_rounded,
      color: AppColors.textSecondary,
      child: Column(
        children: [
          {'range': '3.7 – 4.0', 'label': 'Summa Cum Laude', 'color': AppColors.gradeA},
          {'range': '3.5 – 3.6', 'label': 'Magna Cum Laude', 'color': AppColors.gradeB},
          {'range': '3.0 – 3.4', 'label': 'Cum Laude',       'color': AppColors.gradeC},
          {'range': '2.0 – 2.9', 'label': 'Satisfactory',    'color': AppColors.gradeD},
          {'range': '0.0 – 1.9', 'label': 'Needs Improvement','color': AppColors.gradeF},
        ].map((row) {
          final color = row['color'] as Color;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Container(width: 10, height: 10,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
              const SizedBox(width: 8),
              Text(row['range'] as String, style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Text(row['label'] as String, style: AppTextStyles.caption),
            ]),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.title),
          ]),
          const SizedBox(height: AppConstants.paddingMD),
          child,
        ],
      ),
    );
  }
}