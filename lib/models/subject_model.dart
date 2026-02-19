import 'package:hive/hive.dart';

part 'subject_model.g.dart';

@HiveType(typeId: 0)
class SubjectModel extends HiveObject {
 @HiveField(0)
 final String id;

 @HiveField(1)
 final String name;

 // For GPA-based students (college)
 @HiveField(2)
 final String grade;

 @HiveField(3)
 final int credits;

 // For percentage-based students (secondary)
 @HiveField(4)
 final double? marksScored;

 @HiveField(5)
 final double? maxMarks;

 SubjectModel({
  required this.id,
  required this.name,
  this.grade = 'A',
  this.credits = 3,
  this.marksScored,
  this.maxMarks,
 });

 double? get percentage =>
     (marksScored != null && maxMarks != null && maxMarks! > 0)
         ? (marksScored! / maxMarks!) * 100
         : null;

 SubjectModel copyWith({
  String? id, String? name, String? grade,
  int? credits, double? marksScored, double? maxMarks,
 }) {
  return SubjectModel(
   id: id ?? this.id,
   name: name ?? this.name,
   grade: grade ?? this.grade,
   credits: credits ?? this.credits,
   marksScored: marksScored ?? this.marksScored,
   maxMarks: maxMarks ?? this.maxMarks,
  );
 }

 @override
 bool operator ==(Object other) => other is SubjectModel && other.id == id;

 @override
 int get hashCode => id.hashCode;
}