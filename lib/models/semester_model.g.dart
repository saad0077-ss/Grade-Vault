// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'semester_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SemesterModelAdapter extends TypeAdapter<SemesterModel> {
  @override
  final int typeId = 1;

  @override
  SemesterModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SemesterModel(
      id: fields[0] as String,
      name: fields[1] as String,
      subjects: (fields[2] as List).cast<SubjectModel>(),
      createdAt: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SemesterModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.subjects)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemesterModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
