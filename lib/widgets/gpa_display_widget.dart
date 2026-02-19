import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_color.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_text_styles.dart';
import '../providers/grade_provider.dart';

class GpaDisplayWidget extends StatelessWidget {
  const GpaDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GradeProvider>(
      builder: (_, provider, __) {
        return Container(
          margin: const EdgeInsets.all(AppConstants.paddingLG),
          padding: const EdgeInsets.all(AppConstants.paddingLG),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1E2E), Color(0xFF1E2438)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusXL),
            border: Border.all(
              color: AppColors.surfaceLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _GpaRingIndicator(
                gpa: provider.currentGpa,
                percentage: provider.gpaPercentage,
              ),
              const SizedBox(width: AppConstants.paddingLG),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CURRENT GPA', style: AppTextStyles.label),
                    const SizedBox(height: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        provider.currentGpa.toStringAsFixed(2),
                        key: ValueKey(provider.currentGpa),
                        style: AppTextStyles.gpaDisplay,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.gpaClassification,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSM),
                    _buildStats(provider),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStats(GradeProvider provider) {
    return Row(
      children: [
        _StatChip(
          label: 'Subjects',
          value: '${provider.subjects.length}',
        ),
        const SizedBox(width: AppConstants.paddingSM),
        _StatChip(
          label: 'Credits',
          value: '${provider.totalCredits}',
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: AppTextStyles.body
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _GpaRingIndicator extends StatelessWidget {
  final double gpa;
  final double percentage;

  const _GpaRingIndicator({required this.gpa, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: CustomPaint(
        painter: _RingPainter(percentage: percentage),
        child: Center(
          child: Text(
            gpa.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percentage;
  const _RingPainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 6.0;

    // Background ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.surfaceLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5707963, // -90 degrees in radians
      percentage * 2 * 3.14159265,
      false,
      Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.percentage != percentage;
}