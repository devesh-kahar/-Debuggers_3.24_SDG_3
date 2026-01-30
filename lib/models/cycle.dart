import 'package:hive/hive.dart';

part 'cycle.g.dart';

@HiveType(typeId: 1)
class Cycle extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String oderId;

  @HiveField(2)
  DateTime startDate;

  @HiveField(3)
  DateTime? endDate;

  @HiveField(4)
  int cycleLength;

  @HiveField(5)
  int periodLength;

  @HiveField(6)
  DateTime? ovulationDate;

  @HiveField(7)
  List<DateTime> periodDays;

  @HiveField(8)
  List<DateTime> fertileDays;

  @HiveField(9)
  bool isActive;

  @HiveField(10)
  String? notes;

  Cycle({
    required this.id,
    required this.oderId,
    required this.startDate,
    this.endDate,
    this.cycleLength = 28,
    this.periodLength = 5,
    this.ovulationDate,
    this.periodDays = const [],
    this.fertileDays = const [],
    this.isActive = true,
    this.notes,
  });

  // Calculate fertile window (6 days: 5 before ovulation + ovulation day)
  List<DateTime> calculateFertileWindow() {
    final ovulation = ovulationDate ?? startDate.add(Duration(days: cycleLength - 14));
    return List.generate(6, (i) => ovulation.subtract(Duration(days: 5 - i)));
  }

  // Calculate expected period days
  List<DateTime> calculatePeriodDays() {
    return List.generate(periodLength, (i) => startDate.add(Duration(days: i)));
  }

  // Get days until next period
  int getDaysUntilNextPeriod() {
    final nextPeriod = startDate.add(Duration(days: cycleLength));
    return nextPeriod.difference(DateTime.now()).inDays;
  }

  // Get current cycle day
  int getCurrentCycleDay() {
    return DateTime.now().difference(startDate).inDays + 1;
  }

  // Check if date is period day
  bool isPeriodDay(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    for (var periodDay in calculatePeriodDays()) {
      final normalizedPeriod = DateTime(periodDay.year, periodDay.month, periodDay.day);
      if (normalizedDate == normalizedPeriod) return true;
    }
    return false;
  }

  // Check if date is fertile day
  bool isFertileDay(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    for (var fertileDay in calculateFertileWindow()) {
      final normalizedFertile = DateTime(fertileDay.year, fertileDay.month, fertileDay.day);
      if (normalizedDate == normalizedFertile) return true;
    }
    return false;
  }

  // Check if date is ovulation day
  bool isOvulationDay(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final ovulation = ovulationDate ?? startDate.add(Duration(days: cycleLength - 14));
    final normalizedOvulation = DateTime(ovulation.year, ovulation.month, ovulation.day);
    return normalizedDate == normalizedOvulation;
  }

  // Calculate fertility score for a given date (0-100)
  int getFertilityScore(DateTime date) {
    if (isPeriodDay(date)) return 0;
    if (isOvulationDay(date)) return 100;
    if (isFertileDay(date)) {
      final ovulation = ovulationDate ?? startDate.add(Duration(days: cycleLength - 14));
      final daysFromOvulation = date.difference(ovulation).inDays.abs();
      if (daysFromOvulation == 1) return 85;
      if (daysFromOvulation == 2) return 70;
      if (daysFromOvulation == 3) return 50;
      if (daysFromOvulation == 4) return 35;
      if (daysFromOvulation == 5) return 20;
    }
    return 5; // Safe days
  }
}

@HiveType(typeId: 2)
class DailyLog extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String oderId;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  double? bbtTemperature; // Basal Body Temperature

  @HiveField(4)
  String? cervicalMucus; // dry, sticky, creamy, watery, eggWhite

  @HiveField(5)
  String? flowIntensity; // spotting, light, medium, heavy

  @HiveField(6)
  bool? hadIntercourse;

  @HiveField(7)
  bool? usedProtection;

  @HiveField(8)
  List<String> symptoms;

  @HiveField(9)
  int? moodRating; // 1-5

  @HiveField(10)
  int? energyLevel; // 1-10

  @HiveField(11)
  double? hoursSlept;

  @HiveField(12)
  String? notes;

  @HiveField(13)
  DateTime createdAt;

  DailyLog({
    required this.id,
    required this.oderId,
    required this.date,
    this.bbtTemperature,
    this.cervicalMucus,
    this.flowIntensity,
    this.hadIntercourse,
    this.usedProtection,
    this.symptoms = const [],
    this.moodRating,
    this.energyLevel,
    this.hoursSlept,
    this.notes,
    required this.createdAt,
  });
}
