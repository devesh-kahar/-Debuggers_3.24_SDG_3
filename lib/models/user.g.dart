// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      age: fields[3] as int,
      height: fields[4] as double,
      weight: fields[5] as double,
      bloodType: fields[6] as String,
      currentMode: fields[7] as String,
      lastPeriodDate: fields[8] as DateTime?,
      cycleLength: fields[9] as int,
      periodLength: fields[10] as int,
      dueDate: fields[11] as DateTime?,
      currentPregnancyWeek: fields[12] as int?,
      medicalConditions: (fields[13] as List).cast<String>(),
      previousComplications: (fields[14] as List).cast<String>(),
      previousPregnancies: fields[15] as int,
      isOnboardingComplete: fields[16] as bool,
      preferredUnits: fields[17] as String,
      isDarkMode: fields[18] as bool,
      createdAt: fields[19] as DateTime,
      updatedAt: fields[20] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.age)
      ..writeByte(4)
      ..write(obj.height)
      ..writeByte(5)
      ..write(obj.weight)
      ..writeByte(6)
      ..write(obj.bloodType)
      ..writeByte(7)
      ..write(obj.currentMode)
      ..writeByte(8)
      ..write(obj.lastPeriodDate)
      ..writeByte(9)
      ..write(obj.cycleLength)
      ..writeByte(10)
      ..write(obj.periodLength)
      ..writeByte(11)
      ..write(obj.dueDate)
      ..writeByte(12)
      ..write(obj.currentPregnancyWeek)
      ..writeByte(13)
      ..write(obj.medicalConditions)
      ..writeByte(14)
      ..write(obj.previousComplications)
      ..writeByte(15)
      ..write(obj.previousPregnancies)
      ..writeByte(16)
      ..write(obj.isOnboardingComplete)
      ..writeByte(17)
      ..write(obj.preferredUnits)
      ..writeByte(18)
      ..write(obj.isDarkMode)
      ..writeByte(19)
      ..write(obj.createdAt)
      ..writeByte(20)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
