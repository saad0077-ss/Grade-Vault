enum StudentType {
  higherSecondary,  // Grade 11–12 / +1 +2
  seniorSecondary,  // Grade 9–10 / SSLC
  undergraduate,    // College / Degree
  postgraduate,     // Masters / PG
}

extension StudentTypeExtension on StudentType {
  String get label {
    switch (this) {
      case StudentType.higherSecondary:
        return 'Higher Secondary';
      case StudentType.seniorSecondary:
        return 'Senior Secondary';
      case StudentType.undergraduate:
        return 'Undergraduate';
      case StudentType.postgraduate:
        return 'Postgraduate';
    }
  }

  String get subtitle {
    switch (this) {
      case StudentType.higherSecondary:
        return 'Grade 11 – 12 / +1 +2';
      case StudentType.seniorSecondary:
        return 'Grade 9 – 10 / SSLC';
      case StudentType.undergraduate:
        return 'Degree / College';
      case StudentType.postgraduate:
        return 'Masters / PG';
    }
  }

  String get emoji {
    switch (this) {
      case StudentType.higherSecondary:
        return '📘';
      case StudentType.seniorSecondary:
        return '📗';
      case StudentType.undergraduate:
        return '🎓';
      case StudentType.postgraduate:
        return '🏛️';
    }
  }

  /// Whether this type uses percentage-based grading (no credit hours)
  bool get usesPercentage {
    return this == StudentType.higherSecondary ||
        this == StudentType.seniorSecondary;
  }

  /// Whether this type uses GPA with credit hours
  bool get usesGpa {
    return this == StudentType.undergraduate ||
        this == StudentType.postgraduate;
  }
}