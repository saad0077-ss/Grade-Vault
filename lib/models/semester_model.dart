import 'package:hive/hive.dart';
import 'subject_model.dart';

part 'semester_model.g.dart';

@HiveType(typeId: 1)
class SemesterModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<SubjectModel> subjects;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final String studentType; // stored as string

  SemesterModel({
    required this.id,
    required this.name,
    required this.subjects,
    required this.studentType,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}