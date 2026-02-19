import 'package:grade_vault/core/constants/app_text_styles.dart';
import 'package:grade_vault/models/subject_model.dart';

class GpaCalculator {
  GpaCalculator._();

  //Calculates weighted GPA from a list of subjects.
  static double calculate(List<SubjectModel> subjects) {
    if(subjects.isEmpty) return 0.0;

    double totalWeightedPoints = 0;
    int totalCredits = 0;

    for(final subject in subjects) {
      final points = AppConstants.gradePoints[subject.grade] ?? 0.0;
      totalWeightedPoints += points * subject.credits;
      totalCredits += subject.credits;
    }


    if(totalCredits == 0)return 0.0;
      return totalWeightedPoints / totalCredits;
  }

  //Returns a letter classification for a GPA value
  static String classify(double gpa){
    if(gpa >=3.7)return 'Summa Cum Laude';
    if(gpa >= 3.5)return 'Magna Cum Laude';
    if(gpa >= 3.0)return 'Magna Cum Laude';
    if(gpa >= 2.0)return 'Satisfactory';
    if(gpa >= 1.0)return 'Needs Improvement';
    return "Academic Probation";
  }

  //Return percentage value from 0-100 from UI progress indicators.
  static double toPercentageToGrade(double gpa) => (gpa / 4.0).clamp(0.0, 1.0);

  //Converts raw Percentage marks to a letter grade
  static String percentageToGrade(double percentage){
    if(percentage >= 97) return 'A+';
    if(percentage >= 93) return 'A';
    if(percentage >= 90) return 'A-';
    if(percentage >= 87) return 'B+';
    if(percentage >= 83) return 'B';
    if(percentage >= 80) return 'B-';
    if(percentage >= 77) return 'C+';
    if(percentage >= 73) return 'C';
    if(percentage >= 70) return 'C-';
    if (percentage >= 67) return 'D+';
    if (percentage >= 63) return 'D';
    if (percentage >= 60) return 'D-';
    return 'F';
  }

  //Return total credit hours.
  static int totalCredits(List<SubjectModel> subjects)=>
    subjects.fold(0, (sum,s) => sum + s.credits);


}