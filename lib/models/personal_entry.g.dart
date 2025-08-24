// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonalEntryAdapter extends TypeAdapter<PersonalEntry> {
  @override
  final int typeId = 4;

  @override
  PersonalEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersonalEntry(
      id: fields[0] as String,
      name: fields[1] as String,
      value: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PersonalEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
