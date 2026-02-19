class AppConstants {
  AppConstants._();

  static const double paddingXS  = 4.0;
  static const double paddingSM  = 8.0;
  static const double paddingMD  = 16.0;
  static const double paddingLG  = 24.0;
  static const double paddingXL  = 32.0;
  static const double paddingXXL = 48.0;

  static const double radiusSM   = 8.0;
  static const double radiusMD   = 14.0;
  static const double radiusLG   = 20.0;
  static const double radiusXL   = 28.0;
  static const double radiusXXL  = 40.0;

  // GPA Grade points (4.0 scale)
  static const Map<String, double> gradePoints = {
    'A+': 4.0, 'A': 4.0, 'A-': 3.7,
    'B+': 3.3, 'B': 3.0, 'B-': 2.7,
    'C+': 2.3, 'C': 2.0, 'C-': 1.7,
    'D+': 1.3, 'D': 1.0, 'D-': 0.7,
    'F' : 0.0,
  };

  static const List<String> gradeOptions = [
    'A+', 'A', 'A-',
    'B+', 'B', 'B-',
    'C+', 'C', 'C-',
    'D+', 'D', 'D-',
    'F',
  ];

  static const List<int> creditOptions = [1, 2, 3, 4, 5, 6];

  // For percentage-based students (Secondary)
  static const List<String> subjectTemplatesHigher = [
    'Mathematics', 'Physics', 'Chemistry', 'Biology',
    'Computer Science', 'English', 'History', 'Geography',
    'Economics', 'Accountancy', 'Political Science', 'Psychology',
  ];

  static const List<String> subjectTemplatesSecondary = [
    'Mathematics', 'Science', 'Social Studies', 'English',
    'Hindi', 'Malayalam', 'IT', 'Art',
  ];
}