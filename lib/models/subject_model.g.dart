// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'subject_model.dart';

class SubjectModelAdapter extends TypeAdapter<SubjectModel> {
  @override
  final int typeId = 0;

  @override
  SubjectModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubjectModel(
      id:          fields[0] as String,
      name:        fields[1] as String,
      grade:       fields[2] as String,
      credits:     fields[3] as int,
      marksScored: fields[4] as double?,
      maxMarks:    fields[5] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, SubjectModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.grade)
      ..writeByte(3)..write(obj.credits)
      ..writeByte(4)..write(obj.marksScored)
      ..writeByte(5)..write(obj.maxMarks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      other is SubjectModelAdapter && typeId == other.typeId;
}