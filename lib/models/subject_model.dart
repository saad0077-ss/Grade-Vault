 import 'package:hive/hive.dart';

 part 'subject_model.g.dart';

@HiveType(typeId: 0)
class SubjectModel extends HiveObject  {

 @HiveField(0)
 final String id;

 @HiveField(1)
 final String name;

 @HiveField(2)
 final String grade;


 @HiveField(3)
 final int credits;


 SubjectModel({
  required this.id, required this.name, required this.grade, required this.credits
});

 SubjectModel copyWith({
  String? id,
  String? name,
  String? grade,
  int? credits,
 }) {
  return SubjectModel(
   id:      id      ?? this.id,
   name:    name    ?? this.name,
   grade:   grade   ?? this.grade,
   credits: credits ?? this.credits,
  );
 }

 @override
 bool operator ==(Object other) =>
     other is SubjectModel && other.id == id;

 @override
 int get hashCode => id.hashCode;

 @override
 String toString() =>
     'SubjectModel(id: $id, name: $name, grade: $grade, credits: $credits)';

 }