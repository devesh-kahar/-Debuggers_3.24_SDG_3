// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CycleAdapter extends TypeAdapter<Cycle> {
  @override
  final int typeId = 1;

  @override
  Cycle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Cycle(
      id: fields[0] as String,
      oderId: fields[1] as String,
      startDate: fields[2] as DateTime,
      endDate: fields[3] as DateTime?,
      cycleLength: fields[4] as int,
      periodLength: fields[5] as int,
      ovulationDate: fields[6] as DateTime?,
      periodDays: (fields[7] as List).cast<DateTime>(),
      fertileDays: (fields[8] as List).cast<DateTime>(),
      isActive: fields[9] as bool,
      notes: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Cycle obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.oderId)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.endDate)
      ..writeByte(4)
      ..write(obj.cycleLength)
      ..writeByte(5)
      ..write(obj.periodLength)
      ..writeByte(6)
      ..write(obj.ovulationDate)
      ..writeByte(7)
      ..write(obj.periodDays)
      ..writeByte(8)
      ..write(obj.fertileDays)
      ..writeByte(9)
      ..write(obj.isActive)
      ..writeByte(10)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CycleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DailyLogAdapter extends TypeAdapter<DailyLog> {
  @override
  final int typeId = 2;

  @override
  DailyLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyLog(
      id: fields[0] as String,
      oderId: fields[1] as String,
      date: fields[2] as DateTime,
      bbtTemperature: fields[3] as double?,
      cervicalMucus: fields[4] as String?,
      flowIntensity: fields[5] as String?,
      hadIntercourse: fields[6] as bool?,
      usedProtection: fields[7] as bool?,
      symptoms: (fields[8] as List).cast<String>(),
      moodRating: fields[9] as int?,
      energyLevel: fields[10] as int?,
      hoursSlept: fields[11] as double?,
      notes: fields[12] as String?,
      createdAt: fields[13] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DailyLog obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.oderId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.bbtTemperature)
      ..writeByte(4)
      ..write(obj.cervicalMucus)
      ..writeByte(5)
      ..write(obj.flowIntensity)
      ..writeByte(6)
      ..write(obj.hadIntercourse)
      ..writeByte(7)
      ..write(obj.usedProtection)
      ..writeByte(8)
      ..write(obj.symptoms)
      ..writeByte(9)
      ..write(obj.moodRating)
      ..writeByte(10)
      ..write(obj.energyLevel)
      ..writeByte(11)
      ..write(obj.hoursSlept)
      ..writeByte(12)
      ..write(obj.notes)
      ..writeByte(13)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
