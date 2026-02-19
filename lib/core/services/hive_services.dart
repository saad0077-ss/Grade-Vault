import 'package:hive_flutter/hive_flutter.dart';
import '../../models/subject_model.dart';
import '../../models/semester_model.dart';

class HiveServices {
  HiveServices._();

  static const String _subjectsBoxName  = 'current_subjects';
  static const String _semestersBoxName = 'semesters';
  static const String _settingsBoxName  = 'settings';

  // Settings keys
  static const String _semesterNameKey  = 'current_semester_name';
  static const String _studentTypeKey   = 'student_type';
  static const String _userNameKey      = 'user_name';
  static const String _userSchoolKey    = 'user_school';
  static const String _userPhoneKey     = 'user_phone';
  static const String _userEmailKey     = 'user_email';
  static const String _userImageKey     = 'user_image_path';

  static Box<SubjectModel>  get _subjectsBox  => Hive.box<SubjectModel>(_subjectsBoxName);
  static Box<SemesterModel> get _semestersBox => Hive.box<SemesterModel>(_semestersBoxName);
  static Box                get _settingsBox  => Hive.box(_settingsBoxName);

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(SubjectModelAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(SemesterModelAdapter());
    await Hive.openBox<SubjectModel>(_subjectsBoxName);
    await Hive.openBox<SemesterModel>(_semestersBoxName);
    await Hive.openBox(_settingsBoxName);
  }

  // ── Subjects ──────────────────────────────────────────────────────────────
  static List<SubjectModel> getSubjects() => _subjectsBox.values.toList();
  static Future<void> addSubject(SubjectModel s)    async => _subjectsBox.put(s.id, s);
  static Future<void> deleteSubject(String id)      async => _subjectsBox.delete(id);
  static Future<void> updateSubject(SubjectModel s) async => _subjectsBox.put(s.id, s);
  static Future<void> clearSubjects()               async => _subjectsBox.clear();

  // ── Semesters ─────────────────────────────────────────────────────────────
  static List<SemesterModel> getSemesters() =>
      _semestersBox.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  static Future<void> saveSemester(SemesterModel s) async => _semestersBox.put(s.id, s);
  static Future<void> deleteSemester(String id)     async => _semestersBox.delete(id);

  // ── Settings ──────────────────────────────────────────────────────────────
  static String getSemesterName() =>
      _settingsBox.get(_semesterNameKey, defaultValue: 'Current Semester') as String;
  static Future<void> setSemesterName(String name) async =>
      _settingsBox.put(_semesterNameKey, name);

  static String getStudentType() =>
      _settingsBox.get(_studentTypeKey, defaultValue: '') as String;
  static Future<void> setStudentType(String type) async =>
      _settingsBox.put(_studentTypeKey, type);

  static bool get hasStudentType =>
      (_settingsBox.get(_studentTypeKey, defaultValue: '') as String).isNotEmpty;

  // ── User Profile ──────────────────────────────────────────────────────────
  static String getUserName()      => _settingsBox.get(_userNameKey,   defaultValue: '') as String;
  static String getUserSchool()    => _settingsBox.get(_userSchoolKey, defaultValue: '') as String;
  static String getUserPhone()     => _settingsBox.get(_userPhoneKey,  defaultValue: '') as String;
  static String getUserEmail()     => _settingsBox.get(_userEmailKey,  defaultValue: '') as String;
  static String getUserImagePath() => _settingsBox.get(_userImageKey,  defaultValue: '') as String;

  static Future<void> setUserName(String v)      async => _settingsBox.put(_userNameKey,   v);
  static Future<void> setUserSchool(String v)    async => _settingsBox.put(_userSchoolKey, v);
  static Future<void> setUserPhone(String v)     async => _settingsBox.put(_userPhoneKey,  v);
  static Future<void> setUserEmail(String v)     async => _settingsBox.put(_userEmailKey,  v);
  static Future<void> setUserImagePath(String v) async => _settingsBox.put(_userImageKey,  v);
}