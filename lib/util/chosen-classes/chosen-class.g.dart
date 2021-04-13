// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chosen-class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChoosenClassAdapter extends TypeAdapter<ChoosenClass> {
  @override
  final int typeId = 1;

  @override
  ChoosenClass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChoosenClass(
      media: fields[0] as Media?,
      isFavorite: fields[1] as bool?,
      isRecent: fields[2] as bool?,
      modifiedDate: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ChoosenClass obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.media)
      ..writeByte(1)
      ..write(obj.isFavorite)
      ..writeByte(2)
      ..write(obj.isRecent)
      ..writeByte(3)
      ..write(obj.modifiedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChoosenClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
