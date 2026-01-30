import 'package:hive/hive.dart';

part 'symptom.g.dart';

@HiveType(typeId: 7)
class Symptom extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String oderId;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String type;

  @HiveField(4)
  int severity; // 1-10

  @HiveField(5)
  String category; // physical, emotional, digestive, warning

  @HiveField(6)
  bool isWarning;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  DateTime createdAt;

  Symptom({
    required this.id,
    required this.oderId,
    required this.date,
    required this.type,
    this.severity = 5,
    this.category = 'physical',
    this.isWarning = false,
    this.notes,
    required this.createdAt,
  });

  // Get severity level name
  String get severityLevel {
    if (severity <= 3) return 'Mild';
    if (severity <= 6) return 'Moderate';
    return 'Severe';
  }

  // Get color for severity (for UI)
  String get severityColor {
    if (severity <= 3) return 'green';
    if (severity <= 6) return 'yellow';
    return 'red';
  }

  // Check if requires medical attention
  bool get requiresAttention {
    return isWarning || severity >= 8;
  }

  // Common fertility symptoms
  static const List<Map<String, dynamic>> fertilitySymptomsList = [
    {'name': 'Cramping', 'icon': '🤕', 'category': 'physical'},
    {'name': 'Bloating', 'icon': '😣', 'category': 'physical'},
    {'name': 'Headache', 'icon': '🤯', 'category': 'physical'},
    {'name': 'Back Pain', 'icon': '😩', 'category': 'physical'},
    {'name': 'Breast Tenderness', 'icon': '💔', 'category': 'physical'},
    {'name': 'Fatigue', 'icon': '😴', 'category': 'physical'},
    {'name': 'Mood Swings', 'icon': '😤', 'category': 'emotional'},
    {'name': 'Anxiety', 'icon': '😰', 'category': 'emotional'},
    {'name': 'Irritability', 'icon': '😠', 'category': 'emotional'},
    {'name': 'Nausea', 'icon': '🤢', 'category': 'digestive'},
    {'name': 'Food Cravings', 'icon': '🍔', 'category': 'digestive'},
    {'name': 'Acne', 'icon': '😕', 'category': 'physical'},
  ];

  // Common pregnancy symptoms
  static const List<Map<String, dynamic>> pregnancySymptomsList = [
    {'name': 'Morning Sickness', 'icon': '🤢', 'category': 'digestive'},
    {'name': 'Fatigue', 'icon': '😴', 'category': 'physical'},
    {'name': 'Back Pain', 'icon': '😩', 'category': 'physical'},
    {'name': 'Swelling', 'icon': '🦶', 'category': 'physical'},
    {'name': 'Heartburn', 'icon': '🔥', 'category': 'digestive'},
    {'name': 'Constipation', 'icon': '😣', 'category': 'digestive'},
    {'name': 'Shortness of Breath', 'icon': '😮‍💨', 'category': 'physical'},
    {'name': 'Frequent Urination', 'icon': '🚽', 'category': 'physical'},
    {'name': 'Insomnia', 'icon': '😵', 'category': 'physical'},
    {'name': 'Leg Cramps', 'icon': '🦵', 'category': 'physical'},
    {'name': 'Mood Changes', 'icon': '😢', 'category': 'emotional'},
    {'name': 'Headache', 'icon': '🤯', 'category': 'physical'},
  ];

  // Warning symptoms that need immediate attention
  static const List<Map<String, dynamic>> warningSymptomsList = [
    {'name': 'Severe Headache', 'icon': '⚠️', 'category': 'warning', 'urgent': true},
    {'name': 'Vision Changes', 'icon': '👁️', 'category': 'warning', 'urgent': true},
    {'name': 'Severe Abdominal Pain', 'icon': '🚨', 'category': 'warning', 'urgent': true},
    {'name': 'Heavy Bleeding', 'icon': '🩸', 'category': 'warning', 'urgent': true},
    {'name': 'Decreased Fetal Movement', 'icon': '👶', 'category': 'warning', 'urgent': true},
    {'name': 'Sudden Swelling', 'icon': '😨', 'category': 'warning', 'urgent': true},
    {'name': 'High Fever', 'icon': '🤒', 'category': 'warning', 'urgent': true},
    {'name': 'Water Breaking', 'icon': '💧', 'category': 'warning', 'urgent': true},
    {'name': 'Regular Contractions', 'icon': '⏰', 'category': 'warning', 'urgent': false},
    {'name': 'Painful Urination', 'icon': '😖', 'category': 'warning', 'urgent': false},
  ];
}
