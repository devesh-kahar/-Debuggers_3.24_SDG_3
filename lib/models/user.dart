import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  int age;

  @HiveField(4)
  double height; // in cm

  @HiveField(5)
  double weight; // in kg

  @HiveField(6)
  String bloodType;

  @HiveField(7)
  String currentMode; // 'fertility' or 'pregnancy'

  @HiveField(8)
  DateTime? lastPeriodDate;

  @HiveField(9)
  int cycleLength;

  @HiveField(10)
  int periodLength;

  @HiveField(11)
  DateTime? dueDate;

  @HiveField(12)
  int? currentPregnancyWeek;

  @HiveField(13)
  List<String> medicalConditions;

  @HiveField(14)
  List<String> previousComplications;

  @HiveField(15)
  int previousPregnancies;

  @HiveField(16)
  bool isOnboardingComplete;

  @HiveField(17)
  String preferredUnits; // 'metric' or 'imperial'

  @HiveField(18)
  bool isDarkMode;

  @HiveField(19)
  DateTime createdAt;

  @HiveField(20)
  DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.age = 25,
    this.height = 160,
    this.weight = 60,
    this.bloodType = 'Unknown',
    this.currentMode = 'fertility',
    this.lastPeriodDate,
    this.cycleLength = 28,
    this.periodLength = 5,
    this.dueDate,
    this.currentPregnancyWeek,
    this.medicalConditions = const [],
    this.previousComplications = const [],
    this.previousPregnancies = 0,
    this.isOnboardingComplete = false,
    this.preferredUnits = 'metric',
    this.isDarkMode = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate BMI
  double get bmi => weight / ((height / 100) * (height / 100));

  // Get BMI category
  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // Check if high-risk age
  bool get isHighRiskAge => age < 18 || age > 35;

  // Get current trimester
  int? get currentTrimester {
    if (currentPregnancyWeek == null) return null;
    if (currentPregnancyWeek! <= 12) return 1;
    if (currentPregnancyWeek! <= 27) return 2;
    return 3;
  }

  // Copy with method
  User copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    double? height,
    double? weight,
    String? bloodType,
    String? currentMode,
    DateTime? lastPeriodDate,
    int? cycleLength,
    int? periodLength,
    DateTime? dueDate,
    int? currentPregnancyWeek,
    List<String>? medicalConditions,
    List<String>? previousComplications,
    int? previousPregnancies,
    bool? isOnboardingComplete,
    String? preferredUnits,
    bool? isDarkMode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bloodType: bloodType ?? this.bloodType,
      currentMode: currentMode ?? this.currentMode,
      lastPeriodDate: lastPeriodDate ?? this.lastPeriodDate,
      cycleLength: cycleLength ?? this.cycleLength,
      periodLength: periodLength ?? this.periodLength,
      dueDate: dueDate ?? this.dueDate,
      currentPregnancyWeek: currentPregnancyWeek ?? this.currentPregnancyWeek,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      previousComplications: previousComplications ?? this.previousComplications,
      previousPregnancies: previousPregnancies ?? this.previousPregnancies,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      preferredUnits: preferredUnits ?? this.preferredUnits,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
