import 'package:flutter/cupertino.dart';
import '../core/services/hive_services.dart';
import '../core/utils/gpa_calculator.dart';
import '../core/utils/student_type.dart';
import '../models/semester_model.dart';
import '../models/subject_model.dart';

class GradeProvider extends ChangeNotifier {
  List<SubjectModel>  _subjects             = [];
  List<SemesterModel> _semesters            = [];
  String              _currentSemesterName  = 'Current Semester';
  bool                _isLoading            = true;
  StudentType?        _studentType;

  // User profile fields
  String _userName      = '';
  String _userSchool    = '';
  String _userPhone     = '';
  String _userEmail     = '';
  String _userImagePath = '';

  // ─── Getters ──────────────────────────────────────────────────────────────
  List<SubjectModel>  get subjects            => List.unmodifiable(_subjects);
  List<SemesterModel> get semesters           => List.unmodifiable(_semesters);
  String              get currentSemesterName  => _currentSemesterName;
  bool                get isLoading           => _isLoading;
  StudentType?        get studentType         => _studentType;
  bool                get hasStudentType      => _studentType != null;
  bool                get usesGpa            => _studentType?.usesGpa ?? true;
  bool                get usesPercentage     => _studentType?.usesPercentage ?? false;

  // User profile getters
  String get userName      => _userName;
  String get userSchool    => _userSchool;
  String get userPhone     => _userPhone;
  String get userEmail     => _userEmail;
  String get userImagePath => _userImagePath;
  bool   get hasProfile    => _userName.isNotEmpty;

  // GPA metrics
  double get currentGpa            => GpaCalculator.calculate(_subjects);
  String get gpaClassification     => GpaCalculator.classify(currentGpa);
  int    get totalCredits          => GpaCalculator.totalCredits(_subjects);
  double get gpaPercentage         => GpaCalculator.toPercentage(currentGpa);

  // Percentage metrics
  double get averagePercentage     => GpaCalculator.averagePercentage(_subjects);
  double get overallPercentage     => GpaCalculator.overallPercentage(_subjects);
  String get percentClassification => GpaCalculator.classifyPercentage(overallPercentage);
  double get totalScored           => GpaCalculator.totalScoredMarks(_subjects);
  double get totalMax              => GpaCalculator.totalMaxMarks(_subjects);

  double get cumulativeGpa {
    final all = [..._semesters.expand((s) => s.subjects), ..._subjects];
    return GpaCalculator.calculate(all);
  }

  double get cumulativePercentage {
    final all = [..._semesters.expand((s) => s.subjects), ..._subjects];
    return GpaCalculator.overallPercentage(all);
  }

  // ─── Init ─────────────────────────────────────────────────────────────────
  Future<void> loadFromStorage() async {
    _subjects            = HiveServices.getSubjects();
    _semesters           = HiveServices.getSemesters();
    _currentSemesterName = HiveServices.getSemesterName();

    final typeStr = HiveServices.getStudentType();
    if (typeStr.isNotEmpty) {
      _studentType = StudentType.values.firstWhere(
            (e) => e.name == typeStr,
        orElse: () => StudentType.undergraduate,
      );
    }

    // Load user profile
    _userName      = HiveServices.getUserName();
    _userSchool    = HiveServices.getUserSchool();
    _userPhone     = HiveServices.getUserPhone();
    _userEmail     = HiveServices.getUserEmail();
    _userImagePath = HiveServices.getUserImagePath();

    _isLoading = false;
    notifyListeners();
  }

  // ─── User Profile ─────────────────────────────────────────────────────────
  Future<void> saveUserProfile({
    required String name,
    required String school,
    required String phone,
    required String email,
  }) async {
    await HiveServices.setUserName(name);
    await HiveServices.setUserSchool(school);
    await HiveServices.setUserPhone(phone);
    await HiveServices.setUserEmail(email);
    _userName   = name;
    _userSchool = school;
    _userPhone  = phone;
    _userEmail  = email;
    notifyListeners();
  }

  Future<void> setUserImagePath(String path) async {
    await HiveServices.setUserImagePath(path);
    _userImagePath = path;
    notifyListeners();
  }

  // ─── Student Type ─────────────────────────────────────────────────────────
  Future<void> setStudentType(StudentType type) async {
    await HiveServices.setStudentType(type.name);
    _studentType = type;
    notifyListeners();
  }

  // ─── Subjects ─────────────────────────────────────────────────────────────
  Future<void> addSubject(SubjectModel subject) async {
    await HiveServices.addSubject(subject);
    _subjects.add(subject);
    notifyListeners();
  }

  Future<void> removeSubject(String id) async {
    await HiveServices.deleteSubject(id);
    _subjects.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  Future<void> updateSubject(SubjectModel updated) async {
    await HiveServices.updateSubject(updated);
    final index = _subjects.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      _subjects[index] = updated;
      notifyListeners();
    }
  }

  Future<void> clearSubjects() async {
    await HiveServices.clearSubjects();
    _subjects.clear();
    notifyListeners();
  }

  // ─── Semesters ────────────────────────────────────────────────────────────
  Future<void> saveSemester() async {
    if (_subjects.isEmpty) return;

    final semester = SemesterModel(
      id:          DateTime.now().millisecondsSinceEpoch.toString(),
      name:        _currentSemesterName,
      subjects:    List.from(_subjects),
      studentType: _studentType?.name ?? 'undergraduate',
    );

    await HiveServices.saveSemester(semester);
    await HiveServices.clearSubjects();
    await HiveServices.setSemesterName('New Semester');

    _semesters.insert(0, semester);
    _subjects.clear();
    _currentSemesterName = 'New Semester';
    notifyListeners();
  }

  Future<void> setSemesterName(String name) async {
    await HiveServices.setSemesterName(name);
    _currentSemesterName = name;
    notifyListeners();
  }

  Future<void> deleteSemester(String id) async {
    await HiveServices.deleteSemester(id);
    _semesters.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  /// Update a saved semester's subjects and persist to Hive
  Future<void> updateSemesterSubjects(String semesterId, List<SubjectModel> updatedSubjects) async {
    final index = _semesters.indexWhere((s) => s.id == semesterId);
    if (index == -1) return;

    final old = _semesters[index];
    final updated = SemesterModel(
      id:          old.id,
      name:        old.name,
      subjects:    updatedSubjects,
      studentType: old.studentType,
      createdAt:   old.createdAt,
    );

    await HiveServices.saveSemester(updated);
    _semesters[index] = updated;
    notifyListeners();
  }

  /// Rename a saved semester
  Future<void> renameSemester(String semesterId, String newName) async {
    final index = _semesters.indexWhere((s) => s.id == semesterId);
    if (index == -1) return;

    final old = _semesters[index];
    final updated = SemesterModel(
      id:          old.id,
      name:        newName,
      subjects:    old.subjects,
      studentType: old.studentType,
      createdAt:   old.createdAt,
    );

    await HiveServices.saveSemester(updated);
    _semesters[index] = updated;
    notifyListeners();
  }
}