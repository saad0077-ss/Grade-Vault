import 'package:grade_vault/models/semester_model.dart';
import 'package:grade_vault/models/subject_model.dart';
import 'package:hive_flutter/adapters.dart';

class HiveServices {
  HiveServices._();

  //-----------Box Names ------------------

  static const String _subjectsBoxName = 'current_subjects';
  static const String _semestersBoxName = 'semesters';
  static const String _settingsBoxName = 'settings';

  //---------Settings Keys--------------
  static const String _semesterNameKey = 'current_semester_name';

  //-----Box Getters ----------------
  static Box<SubjectModel> get _subjectsBox => Hive.box<SubjectModel>(_subjectsBoxName);
  static Box<SemesterModel> get _semestersBox => Hive.box<SemesterModel>(_semestersBoxName);
  static Box get _settingsBox => Hive.box<SubjectModel>(_settingsBoxName);

  //------Initialization -------------------

  static Future<void> init() async{
    await Hive.initFlutter();

    if(!Hive.isAdapterRegistered(0)){
      Hive.registerAdapter(SubjectModelAdapter());
    }
    if(!Hive.isAdapterRegistered(1)){
      Hive.registerAdapter(SemesterModelAdapter());
    }

    await Hive.openBox<SubjectModel>(_subjectsBoxName);
    await Hive.openBox<SemesterModel>(_semestersBoxName);
    await Hive.openBox(_settingsBoxName);
  }

  //----Current Subjects-------------------
  static List<SubjectModel> getSubjects()=>_subjectsBox.values.toList();

  static Future<void> addSubject(SubjectModel subject) async =>await _subjectsBox.put(subject.id,subject);

  static Future<void> deleteSubject(String id) async => await _subjectsBox.delete(id);

  static Future<void> updateSubject(SubjectModel subject) async => await _subjectsBox.put(subject.id,subject);

  static Future<void> clearSubjects() async => await _subjectsBox.clear();

  //--Semester-------------------------------

  static List<SemesterModel> getSemesters() => _semestersBox.values.toList()..sort((a,b)=>b.createdAt.compareTo(a.createdAt));

  static Future<void> saveSemester(SemesterModel semester) async => await _semestersBox.put(semester.id,semester);

  static Future<void> deleteSemester(String id) async => await _semestersBox.delete(id);

  //-----settings---------

  static String getSemesterName() => _settingsBox.get(_semesterNameKey,defaultValue: 'Current Semester') as String;

  static Future<void> setSemesterName(String name) async => await _settingsBox.put(_semesterNameKey,name);

}