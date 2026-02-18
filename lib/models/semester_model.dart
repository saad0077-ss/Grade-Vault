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

  SemesterModel({
    required this.id,
    required this.name,
    required this.subjects,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  SemesterModel copyWith({
    String? id,
    String? name,
    List<SubjectModel>? subjects,
    DateTime? createdAt,
  }) {
    return SemesterModel(
      id:        id        ?? this.id,
      name:      name      ?? this.name,
      subjects:  subjects  ?? this.subjects,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}