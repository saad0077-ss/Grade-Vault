import '../../models/subject_model.dart';
import '../constants/app_constants.dart';

class GpaCalculator {
  GpaCalculator._();

  /// Weighted GPA (for college students)
  static double calculate(List<SubjectModel> subjects) {
    if (subjects.isEmpty) return 0.0;
    double totalPoints = 0;
    int totalCredits = 0;
    for (final s in subjects) {
      final pts = AppConstants.gradePoints[s.grade] ?? 0.0;
      totalPoints += pts * s.credits;
      totalCredits += s.credits;
    }
    if (totalCredits == 0) return 0.0;
    return totalPoints / totalCredits;
  }

  /// Average percentage (for secondary students)
  static double averagePercentage(List<SubjectModel> subjects) {
    if (subjects.isEmpty) return 0.0;
    final total = subjects.fold(0.0, (sum, s) => sum + (s.percentage ?? 0.0));
    return total / subjects.length;
  }

  /// Total marks scored vs total max marks
  static double totalScoredMarks(List<SubjectModel> subjects) =>
      subjects.fold(0.0, (sum, s) => sum + (s.marksScored ?? 0.0));

  static double totalMaxMarks(List<SubjectModel> subjects) =>
      subjects.fold(0.0, (sum, s) => sum + (s.maxMarks ?? 100.0));

  static double overallPercentage(List<SubjectModel> subjects) {
    final max = totalMaxMarks(subjects);
    if (max == 0) return 0.0;
    return (totalScoredMarks(subjects) / max) * 100;
  }

  static String classify(double gpa) {
    if (gpa >= 3.7) return 'Summa Cum Laude';
    if (gpa >= 3.5) return 'Magna Cum Laude';
    if (gpa >= 3.0) return 'Cum Laude';
    if (gpa >= 2.0) return 'Satisfactory';
    if (gpa >= 1.0) return 'Needs Improvement';
    return 'Academic Probation';
  }

  static String classifyPercentage(double pct) {
    if (pct >= 90) return 'Outstanding';
    if (pct >= 80) return 'Distinction';
    if (pct >= 70) return 'First Class';
    if (pct >= 60) return 'Second Class';
    if (pct >= 50) return 'Pass';
    if (pct >= 35) return 'Marginal Pass';
    return 'Fail';
  }

  static double toPercentage(double gpa) => (gpa / 4.0).clamp(0.0, 1.0);

  static String percentageToGrade(double pct) {
    if (pct >= 97) return 'A+';
    if (pct >= 93) return 'A';
    if (pct >= 90) return 'A-';
    if (pct >= 87) return 'B+';
    if (pct >= 83) return 'B';
    if (pct >= 80) return 'B-';
    if (pct >= 77) return 'C+';
    if (pct >= 73) return 'C';
    if (pct >= 70) return 'C-';
    if (pct >= 67) return 'D+';
    if (pct >= 63) return 'D';
    if (pct >= 60) return 'D-';
    return 'F';
  }

  static int totalCredits(List<SubjectModel> subjects) =>
      subjects.fold(0, (sum, s) => sum + s.credits);

  /// Marks needed to reach target percentage
  static double marksNeeded({
    required List<SubjectModel> subjects,
    required double targetPct,
    required double remainingMaxMarks,
  }) {
    final currentTotal = totalScoredMarks(subjects);
    final currentMax   = totalMaxMarks(subjects);
    final needed = (targetPct / 100) * (currentMax + remainingMaxMarks) - currentTotal;
    return needed.clamp(0, remainingMaxMarks);
  }
}