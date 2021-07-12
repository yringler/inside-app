// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handler_persist_position.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersistedPositionAdapter extends TypeAdapter<PersistedPosition> {
  @override
  final int typeId = 0;

  @override
  PersistedPosition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersistedPosition(
      modifiedDate: fields[0] as DateTime,
      milliseconds: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PersistedPosition obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.modifiedDate)
      ..writeByte(1)
      ..write(obj.milliseconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersistedPositionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
