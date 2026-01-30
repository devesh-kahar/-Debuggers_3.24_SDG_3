import 'package:hive/hive.dart';

part 'pregnancy.g.dart';

@HiveType(typeId: 3)
class Pregnancy extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String oderId;

  @HiveField(2)
  DateTime lastMenstrualPeriod;

  @HiveField(3)
  DateTime dueDate;

  @HiveField(4)
  DateTime? conceptionDate;

  @HiveField(5)
  int currentWeek;

  @HiveField(6)
  int currentDay;

  @HiveField(7)
  double riskScore; // 0-100

  @HiveField(8)
  String riskLevel; // low, medium, high

  @HiveField(9)
  List<String> riskFactors;

  @HiveField(10)
  bool isActive;

  @HiveField(11)
  DateTime createdAt;

  @HiveField(12)
  DateTime updatedAt;

  Pregnancy({
    required this.id,
    required this.oderId,
    required this.lastMenstrualPeriod,
    required this.dueDate,
    this.conceptionDate,
    this.currentWeek = 1,
    this.currentDay = 1,
    this.riskScore = 0,
    this.riskLevel = 'low',
    this.riskFactors = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate due date from LMP (40 weeks)
  static DateTime calculateDueDate(DateTime lmp) {
    return lmp.add(const Duration(days: 280));
  }

  // Calculate current week from LMP
  static int calculateCurrentWeek(DateTime lmp) {
    final daysSinceLMP = DateTime.now().difference(lmp).inDays;
    return (daysSinceLMP / 7).floor() + 1;
  }

  // Calculate days remaining
  int get daysRemaining => dueDate.difference(DateTime.now()).inDays;

  // Calculate progress percentage
  double get progressPercentage => ((40 - (daysRemaining / 7)) / 40) * 100;

  // Get current trimester
  int get trimester {
    if (currentWeek <= 12) return 1;
    if (currentWeek <= 27) return 2;
    return 3;
  }

  // Get trimester name
  String get trimesterName {
    switch (trimester) {
      case 1:
        return 'First Trimester';
      case 2:
        return 'Second Trimester';
      case 3:
        return 'Third Trimester';
      default:
        return '';
    }
  }

  // Get baby size comparison
  String get babySizeComparison {
    const sizes = {
      4: 'Poppy Seed',
      5: 'Sesame Seed',
      6: 'Lentil',
      7: 'Blueberry',
      8: 'Raspberry',
      9: 'Cherry',
      10: 'Strawberry',
      11: 'Lime',
      12: 'Plum',
      13: 'Lemon',
      14: 'Peach',
      15: 'Apple',
      16: 'Avocado',
      17: 'Pear',
      18: 'Bell Pepper',
      19: 'Mango',
      20: 'Banana',
      21: 'Carrot',
      22: 'Papaya',
      23: 'Grapefruit',
      24: 'Corn',
      25: 'Cauliflower',
      26: 'Lettuce',
      27: 'Cabbage',
      28: 'Eggplant',
      29: 'Butternut Squash',
      30: 'Cucumber',
      31: 'Pineapple',
      32: 'Squash',
      33: 'Celery',
      34: 'Cantaloupe',
      35: 'Honeydew Melon',
      36: 'Romaine Lettuce',
      37: 'Swiss Chard',
      38: 'Leek',
      39: 'Mini Watermelon',
      40: 'Watermelon',
    };
    return sizes[currentWeek] ?? 'Tiny Miracle';
  }

  // Update pregnancy progress
  void updateProgress() {
    final daysSinceLMP = DateTime.now().difference(lastMenstrualPeriod).inDays;
    currentWeek = (daysSinceLMP / 7).floor() + 1;
    currentDay = (daysSinceLMP % 7) + 1;
    updatedAt = DateTime.now();
  }

  // JSON serialization
  factory Pregnancy.fromJson(Map<String, dynamic> json) {
    return Pregnancy(
      id: json['_id'] ?? json['id'],
      oderId: json['oderId'] ?? '',
      lastMenstrualPeriod: DateTime.parse(json['lastMenstrualPeriod']),
      dueDate: DateTime.parse(json['dueDate']),
      conceptionDate: json['conceptionDate'] != null ? DateTime.parse(json['conceptionDate']) : null,
      currentWeek: json['currentWeek'] ?? 1,
      currentDay: json['currentDay'] ?? 1,
      riskScore: (json['riskScore'] as num?)?.toDouble() ?? 0,
      riskLevel: json['riskLevel'] ?? 'low',
      riskFactors: List<String>.from(json['riskFactors'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'oderId': oderId,
      'lastMenstrualPeriod': lastMenstrualPeriod.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'conceptionDate': conceptionDate?.toIso8601String(),
      'currentWeek': currentWeek,
      'currentDay': currentDay,
      'riskScore': riskScore,
      'riskLevel': riskLevel,
      'riskFactors': riskFactors,
      'isActive': isActive,
    };
  }
}

@HiveType(typeId: 4)
class Vitals extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String oderId;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String type; // bp, weight, bloodSugar, temperature

  @HiveField(4)
  double value;

  @HiveField(5)
  double? secondaryValue; // for BP diastolic

  @HiveField(6)
  String? timeOfDay; // morning, afternoon, evening

  @HiveField(7)
  String? mealContext; // fasting, postMeal

  @HiveField(8)
  String? notes;

  @HiveField(9)
  DateTime createdAt;

  Vitals({
    required this.id,
    required this.oderId,
    required this.date,
    required this.type,
    required this.value,
    this.secondaryValue,
    this.timeOfDay,
    this.mealContext,
    this.notes,
    required this.createdAt,
  });

  // Check if BP is high
  bool get isHighBP {
    if (type != 'bp') return false;
    return value >= 140 || (secondaryValue ?? 0) >= 90;
  }

  // Check if BP is elevated
  bool get isElevatedBP {
    if (type != 'bp') return false;
    return value >= 120 || (secondaryValue ?? 0) >= 80;
  }

  // Get BP category
  String get bpCategory {
    if (type != 'bp') return '';
    if (value < 120 && (secondaryValue ?? 0) < 80) return 'Normal';
    if (value < 140 && (secondaryValue ?? 0) < 90) return 'Elevated';
    if (value < 160 && (secondaryValue ?? 0) < 100) return 'High (Stage 1)';
    return 'High (Stage 2)';
  }

  // Check if blood sugar is high
  bool get isHighBloodSugar {
    if (type != 'bloodSugar') return false;
    if (mealContext == 'fasting') return value > 95;
    return value > 120;
  }

  // Format display value
  String get displayValue {
    switch (type) {
      case 'bp':
        return '${value.toInt()}/${secondaryValue?.toInt() ?? 0} mmHg';
      case 'weight':
        return '${value.toStringAsFixed(1)} kg';
      case 'bloodSugar':
        return '${value.toInt()} mg/dL';
      case 'temperature':
        return '${value.toStringAsFixed(1)}°C';
      default:
        return value.toString();
    }
  }

  // JSON serialization
  factory Vitals.fromJson(Map<String, dynamic> json) {
    return Vitals(
      id: json['_id'] ?? json['id'],
      oderId: json['oderId'] ?? '',
      date: DateTime.parse(json['date']),
      type: json['type'],
      value: (json['value'] as num).toDouble(),
      secondaryValue: (json['secondaryValue'] as num?)?.toDouble(),
      timeOfDay: json['timeOfDay'],
      mealContext: json['mealContext'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'oderId': oderId,
      'date': date.toIso8601String(),
      'type': type,
      'value': value,
      'secondaryValue': secondaryValue,
      'timeOfDay': timeOfDay,
      'mealContext': mealContext,
      'notes': notes,
    };
  }
}

@HiveType(typeId: 5)
class FetalMovement extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String oderId;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  int kickCount;

  @HiveField(4)
  int durationMinutes;

  @HiveField(5)
  DateTime startTime;

  @HiveField(6)
  DateTime? endTime;

  @HiveField(7)
  String? notes;

  FetalMovement({
    required this.id,
    required this.oderId,
    required this.date,
    this.kickCount = 0,
    this.durationMinutes = 0,
    required this.startTime,
    this.endTime,
    this.notes,
  });

  // Check if movement is concerning (less than 10 kicks in 2 hours)
  bool get isConcerning {
    if (durationMinutes >= 120 && kickCount < 10) return true;
    return false;
  }

  // JSON serialization
  factory FetalMovement.fromJson(Map<String, dynamic> json) {
    return FetalMovement(
      id: json['_id'] ?? json['id'],
      oderId: json['oderId'] ?? '',
      date: DateTime.parse(json['date']),
      kickCount: json['kickCount'] ?? 0,
      durationMinutes: json['durationMinutes'] ?? 0,
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'oderId': oderId,
      'date': date.toIso8601String(),
      'kickCount': kickCount,
      'durationMinutes': durationMinutes,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'notes': notes,
    };
  }
}

@HiveType(typeId: 6)
class Contraction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String oderId;

  @HiveField(2)
  DateTime startTime;

  @HiveField(3)
  DateTime? endTime;

  @HiveField(4)
  int durationSeconds;

  @HiveField(5)
  int? intensityRating; // 1-10

  @HiveField(6)
  String? notes;

  Contraction({
    required this.id,
    required this.oderId,
    required this.startTime,
    this.endTime,
    this.durationSeconds = 0,
    this.intensityRating,
    this.notes,
  });

  // Calculate duration
  int get duration {
    if (endTime == null) return 0;
    return endTime!.difference(startTime).inSeconds;
  }

  // JSON serialization
  factory Contraction.fromJson(Map<String, dynamic> json) {
    return Contraction(
      id: json['_id'] ?? json['id'],
      oderId: json['oderId'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      durationSeconds: json['durationSeconds'] ?? 0,
      intensityRating: json['intensityRating'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'oderId': oderId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationSeconds': durationSeconds,
      'intensityRating': intensityRating,
      'notes': notes,
    };
  }
}
