import 'package:flutter/cupertino.dart';
import 'package:grade_vault/core/services/hive_services.dart';
import 'package:grade_vault/models/semester_model.dart';
import 'package:grade_vault/models/subject_model.dart';
import '../core/utils/gpa_calculator.dart';

class GradeProvider extends ChangeNotifier {
  List<SubjectModel> _subjects = [];
  List<SemesterModel> _semesters = [];
  String _currentSemesterName = 'Current Semester';
  bool _isLoading = true;

  // ─── Getters ──────────────────────────────────────────────────────────────
  List<SubjectModel> get subjects           => List.unmodifiable(_subjects);
  List<SemesterModel> get semesters         => List.unmodifiable(_semesters);
  String get currentSemesterName            => _currentSemesterName;
  bool get isLoading                        => _isLoading;

  double get currentGpa                     => GpaCalculator.calculate(_subjects);
  String get gpaClassification              => GpaCalculator.classify(currentGpa);
  int get totalCredits                      => GpaCalculator.totalCredits(_subjects);
  double get gpaPercentage                  => GpaCalculator.toPercentage(currentGpa); // ✅ Fix 1: was toPercentageToGrade

  double get cumulativeGpa {
    final all = [
      ..._semesters.expand((s) => s.subjects),
      ..._subjects,
    ];
    return GpaCalculator.calculate(all);
  }

  // ─── Init (load from Hive) ────────────────────────────────────────────────
  Future<void> loadFromStorage() async {
    _subjects            = HiveServices.getSubjects();
    _semesters           = HiveServices.getSemesters();
    _currentSemesterName = HiveServices.getSemesterName();
    _isLoading           = false;
    notifyListeners();
  }

  // ─── Subject Operations ───────────────────────────────────────────────────
  Future<void> addSubject(SubjectModel subject) async {
    await HiveServices.addSubject(subject);
    _subjects.add(subject);
    notifyListeners();
  }

  Future<void> updateSubject(SubjectModel updated) async {
    await HiveServices.updateSubject(updated);
    final index = _subjects.indexWhere((s) => s.id == updated.id);
    if (index != -1) { // ✅ Fix 2: was index != 1
      _subjects[index] = updated;
      notifyListeners();
    }
  }

  Future<void> removeSubject(String id) async {
    await HiveServices.deleteSubject(id);
    _subjects.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  Future<void> clearSubjects() async {
    await HiveServices.clearSubjects();
    _subjects.clear();
    notifyListeners();
  }

  // ─── Semester Operations ──────────────────────────────────────────────────
  Future<void> saveSemester() async { // ✅ Fix 3: was addSemester, home_screen calls saveSemester
    if (_subjects.isEmpty) return;

    final semester = SemesterModel(
      id:       DateTime.now().millisecondsSinceEpoch.toString(),
      name:     _currentSemesterName,
      subjects: List.from(_subjects),
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
}