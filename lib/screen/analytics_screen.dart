import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_color.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_text_styles.dart';
import '../providers/grade_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GradeProvider>();
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Analytics', style: AppTextStyles.headline),
            Text('Your academic overview', style: AppTextStyles.caption),
            const SizedBox(height: AppConstants.paddingLG),
            _buildSummaryCards(provider),
            const SizedBox(height: AppConstants.paddingLG),
            _buildGradeDistribution(provider),
            const SizedBox(height: AppConstants.paddingLG),
            _buildSemesterTrend(provider),
            const SizedBox(height: AppConstants.paddingLG),
            _buildSubjectPerformance(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(GradeProvider provider) {
    final items = provider.usesGpa
        ? [
      _SummaryItem('Current GPA', provider.currentGpa.toStringAsFixed(2),
          AppColors.accent, Icons.stars_rounded),
      _SummaryItem('Cumulative', provider.cumulativeGpa.toStringAsFixed(2),
          AppColors.teal, Icons.trending_up_rounded),
      _SummaryItem('Classification', provider.gpaClassification.split(' ').first,
          AppColors.violet, Icons.military_tech_rounded),
      _SummaryItem('Credits', '${provider.totalCredits}',
          AppColors.mint, Icons.school_rounded),
    ]
        : [
      _SummaryItem('Average %', '${provider.averagePercentage.toStringAsFixed(1)}%',
          AppColors.accent, Icons.percent_rounded),
      _SummaryItem('Total Scored', '${provider.totalScored.toStringAsFixed(0)}',
          AppColors.teal, Icons.score_rounded),
      _SummaryItem('Total Max', '${provider.totalMax.toStringAsFixed(0)}',
          AppColors.violet, Icons.bar_chart_rounded),
      _SummaryItem('Status', provider.percentClassification.split(' ').first,
          AppColors.mint, Icons.military_tech_rounded),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppConstants.paddingSM,
      crossAxisSpacing: AppConstants.paddingSM,
      childAspectRatio: 1.6,
      children: items.map((item) => _buildSummaryCard(item)).toList(),
    );
  }

  Widget _buildSummaryCard(_SummaryItem item) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(item.icon, color: item.color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.value,
                  style: AppTextStyles.title.copyWith(color: item.color)),
              Text(item.label, style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGradeDistribution(GradeProvider provider) {
    if (provider.subjects.isEmpty) return const SizedBox.shrink();

    final gradeCounts = <String, int>{};
    for (final s in provider.subjects) {
      final key = s.grade.substring(0, 1);
      gradeCounts[key] = (gradeCounts[key] ?? 0) + 1;
    }
    final total = provider.subjects.length;

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
          Text('Grade Distribution', style: AppTextStyles.title),
          const SizedBox(height: AppConstants.paddingMD),
          ...['A', 'B', 'C', 'D', 'F'].map((g) {
            final count = gradeCounts[g] ?? 0;
            final frac  = total > 0 ? count / total : 0.0;
            final color = AppColors.gradeColor('$g');
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    child: Text(g,
                        style: AppTextStyles.body.copyWith(
                            color: color, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _anim,
                      builder: (_, __) => ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: frac * _anim.value,
                          backgroundColor: AppColors.surfaceLight,
                          valueColor: AlwaysStoppedAnimation(color),
                          minHeight: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('$count',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSemesterTrend(GradeProvider provider) {
    if (provider.semesters.length < 2) return const SizedBox.shrink();
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
          Text('Semester Trend', style: AppTextStyles.title),
          const SizedBox(height: AppConstants.paddingMD),
          SizedBox(
            height: 100,
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => CustomPaint(
                painter: _TrendPainter(provider.semesters, _anim.value, provider.usesGpa),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectPerformance(GradeProvider provider) {
    if (provider.subjects.isEmpty) return const SizedBox.shrink();
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
          Text('Subject Performance', style: AppTextStyles.title),
          const SizedBox(height: AppConstants.paddingMD),
          ...provider.subjects.map((s) {
            final pct = provider.usesGpa
                ? ((AppConstants.gradePoints[s.grade] ?? 0) / 4.0)
                : ((s.percentage ?? 0) / 100);
            final color = provider.usesGpa
                ? AppColors.gradeColor(s.grade)
                : AppColors.percentageColor(s.percentage ?? 0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.name,
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                      Text(
                        provider.usesGpa
                            ? s.grade
                            : '${s.percentage?.toStringAsFixed(1) ?? '--'}%',
                        style: AppTextStyles.body.copyWith(color: color, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  AnimatedBuilder(
                    animation: _anim,
                    builder: (_, __) => ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct * _anim.value,
                        backgroundColor: AppColors.surfaceLight,
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 6,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SummaryItem {
  final String label, value;
  final Color color;
  final IconData icon;
  const _SummaryItem(this.label, this.value, this.color, this.icon);
}

class _TrendPainter extends CustomPainter {
  final List semesters;
  final double progress;
  final bool usesGpa;

  _TrendPainter(this.semesters, this.progress, this.usesGpa);

  @override
  void paint(Canvas canvas, Size size) {
    if (semesters.length < 2) return;
    final values = semesters.map<double>((s) {
      if (usesGpa) {
        double total = 0, credits = 0;
        for (final sub in s.subjects) {
          final pts = (AppConstants.gradePoints[sub.grade] ?? 0.0) as double;
          total += pts * sub.credits; credits += sub.credits;
        }
        return credits > 0 ? total / credits / 4.0 : 0.0;
      } else {
        if (s.subjects.isEmpty) return 0.0;
        final pct = s.subjects.fold(0.0, (a, b) => a + (b.percentage ?? 0.0));
        return pct / s.subjects.length / 100;
      }
    }).toList().reversed.toList();

    final paint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width * progress;
      final y = size.height - (values[i] * size.height);
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);

    for (final pt in points) {
      canvas.drawCircle(pt, 4, Paint()..color = AppColors.accent);
      canvas.drawCircle(pt, 4,
          Paint()..color = AppColors.background..style = PaintingStyle.stroke..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(_TrendPainter old) => old.progress != progress;
}