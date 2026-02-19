import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_color.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_text_styles.dart';
import '../providers/grade_provider.dart';

class GpaDisplayWidget extends StatefulWidget {
  const GpaDisplayWidget({super.key});

  @override
  State<GpaDisplayWidget> createState() => _GpaDisplayWidgetState();
}

class _GpaDisplayWidgetState extends State<GpaDisplayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _ring;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _ring = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<GradeProvider>(
      builder: (_, provider, __) {
        return AnimatedBuilder(
          animation: _ring,
          builder: (_, __) => Container(
            margin: const EdgeInsets.fromLTRB(AppConstants.paddingLG,
                AppConstants.paddingMD, AppConstants.paddingLG, 0),
            padding: const EdgeInsets.all(AppConstants.paddingLG),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF161B2E), Color(0xFF1A1F35)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusXL),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [BoxShadow(color: AppColors.accentGlow, blurRadius: 24, offset: const Offset(0, 8))],
            ),
            child: Row(
              children: [
                _GpaRing(
                  gpa: provider.currentGpa,
                  progress: provider.gpaPercentage * _ring.value,
                ),
                const SizedBox(width: AppConstants.paddingLG),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SEMESTER GPA', style: AppTextStyles.label),
                      const SizedBox(height: 4),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          provider.currentGpa.toStringAsFixed(2),
                          key: ValueKey(provider.currentGpa.toStringAsFixed(2)),
                          style: AppTextStyles.gpaHero,
                        ),
                      ),
                      Text(provider.gpaClassification,
                          style: AppTextStyles.caption.copyWith(color: AppColors.accent)),
                      const SizedBox(height: AppConstants.paddingSM),
                      Row(children: [
                        _Chip('${provider.subjects.length} subjects', AppColors.teal),
                        const SizedBox(width: 6),
                        _Chip('${provider.totalCredits} credits', AppColors.violet),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppConstants.radiusSM),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600, fontSize: 10)),
    );
  }
}

class _GpaRing extends StatelessWidget {
  final double gpa;
  final double progress;
  const _GpaRing({required this.gpa, required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: CustomPaint(
        painter: _RingPainter(progress),
        child: Center(
          child: Text(gpa.toStringAsFixed(1),
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.accent)),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  const _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    canvas.drawCircle(center, radius,
        Paint()..color = AppColors.surfaceLight..style = PaintingStyle.stroke..strokeWidth = 7);

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -1.5707963,
        progress * 2 * 3.14159265,
        false,
        Paint()
          ..shader = const SweepGradient(
            colors: [AppColors.accent, AppColors.teal],
            startAngle: 0, endAngle: 6.28,
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}