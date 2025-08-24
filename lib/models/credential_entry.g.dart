// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CredentialEntryAdapter extends TypeAdapter<CredentialEntry> {
  @override
  final int typeId = 1;

  @override
  CredentialEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CredentialEntry(
      id: fields[0] as String,
      serviceName: fields[1] as String,
      category: fields[2] as String,
      fields: (fields[3] as List).cast<Entry>(),
    );
  }

  @override
  void write(BinaryWriter writer, CredentialEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.serviceName)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.fields);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CredentialEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
