// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pregnancy.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PregnancyAdapter extends TypeAdapter<Pregnancy> {
  @override
  final int typeId = 3;

  @override
  Pregnancy read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pregnancy(
      id: fields[0] as String,
      oderId: fields[1] as String,
      lastMenstrualPeriod: fields[2] as DateTime,
      dueDate: fields[3] as DateTime,
      conceptionDate: fields[4] as DateTime?,
      currentWeek: fields[5] as int,
      currentDay: fields[6] as int,
      riskScore: fields[7] as double,
      riskLevel: fields[8] as String,
      riskFactors: (fields[9] as List).cast<String>(),
      isActive: fields[10] as bool,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Pregnancy obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.oderId)
      ..writeByte(2)
      ..write(obj.lastMenstrualPeriod)
      ..writeByte(3)
      ..write(obj.dueDate)
      ..writeByte(4)
      ..write(obj.conceptionDate)
      ..writeByte(5)
      ..write(obj.currentWeek)
      ..writeByte(6)
      ..write(obj.currentDay)
      ..writeByte(7)
      ..write(obj.riskScore)
      ..writeByte(8)
      ..write(obj.riskLevel)
      ..writeByte(9)
      ..write(obj.riskFactors)
      ..writeByte(10)
      ..write(obj.isActive)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PregnancyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VitalsAdapter extends TypeAdapter<Vitals> {
  @override
  final int typeId = 4;

  @override
  Vitals read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vitals(
      id: fields[0] as String,
      oderId: fields[1] as String,
      date: fields[2] as DateTime,
      type: fields[3] as String,
      value: fields[4] as double,
      secondaryValue: fields[5] as double?,
      timeOfDay: fields[6] as String?,
      mealContext: fields[7] as String?,
      notes: fields[8] as String?,
      createdAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Vitals obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.oderId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.value)
      ..writeByte(5)
      ..write(obj.secondaryValue)
      ..writeByte(6)
      ..write(obj.timeOfDay)
      ..writeByte(7)
      ..write(obj.mealContext)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VitalsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FetalMovementAdapter extends TypeAdapter<FetalMovement> {
  @override
  final int typeId = 5;

  @override
  FetalMovement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FetalMovement(
      id: fields[0] as String,
      oderId: fields[1] as String,
      date: fields[2] as DateTime,
      kickCount: fields[3] as int,
      durationMinutes: fields[4] as int,
      startTime: fields[5] as DateTime,
      endTime: fields[6] as DateTime?,
      notes: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FetalMovement obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.oderId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.kickCount)
      ..writeByte(4)
      ..write(obj.durationMinutes)
      ..writeByte(5)
      ..write(obj.startTime)
      ..writeByte(6)
      ..write(obj.endTime)
      ..writeByte(7)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FetalMovementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ContractionAdapter extends TypeAdapter<Contraction> {
  @override
  final int typeId = 6;

  @override
  Contraction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Contraction(
      id: fields[0] as String,
      oderId: fields[1] as String,
      startTime: fields[2] as DateTime,
      endTime: fields[3] as DateTime?,
      durationSeconds: fields[4] as int,
      intensityRating: fields[5] as int?,
      notes: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Contraction obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.oderId)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.durationSeconds)
      ..writeByte(5)
      ..write(obj.intensityRating)
      ..writeByte(6)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContractionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
