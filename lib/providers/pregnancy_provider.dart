import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/pregnancy.dart';
import '../models/symptom.dart';

class PregnancyProvider extends ChangeNotifier {
  Pregnancy? _pregnancy;
  List<Vitals> _vitals = [];
  List<Symptom> _symptoms = [];
  List<FetalMovement> _fetalMovements = [];
  List<Contraction> _contractions = [];
  final _uuid = const Uuid();
  
  // Contraction timer state
  bool _isTimingContraction = false;
  DateTime? _contractionStartTime;

  Pregnancy? get pregnancy => _pregnancy;
  List<Vitals> get vitals => _vitals;
  List<Symptom> get symptoms => _symptoms;
  List<FetalMovement> get fetalMovements => _fetalMovements;
  List<Contraction> get contractions => _contractions;
  bool get isTimingContraction => _isTimingContraction;

  // Pregnancy info getters
  int get currentWeek => _pregnancy?.currentWeek ?? 1;
  int get daysRemaining => _pregnancy?.daysRemaining ?? 280;
  double get progressPercentage => _pregnancy?.progressPercentage ?? 0;
  String get trimesterName => _pregnancy?.trimesterName ?? 'First Trimester';
  String get babySizeComparison => _pregnancy?.babySizeComparison ?? 'Tiny Miracle';
  double get riskScore => _pregnancy?.riskScore ?? 0;
  String get riskLevel => _pregnancy?.riskLevel ?? 'low';

  // Initialize pregnancy
  void initPregnancy(DateTime lastMenstrualPeriod) {
    final dueDate = Pregnancy.calculateDueDate(lastMenstrualPeriod);
    final currentWeek = Pregnancy.calculateCurrentWeek(lastMenstrualPeriod);
    
    _pregnancy = Pregnancy(
      id: _uuid.v4(),
      oderId: 'demo-user-001',
      lastMenstrualPeriod: lastMenstrualPeriod,
      dueDate: dueDate,
      currentWeek: currentWeek,
      currentDay: (DateTime.now().difference(lastMenstrualPeriod).inDays % 7) + 1,
      riskScore: 25, // Start with low baseline
      riskLevel: 'low',
      riskFactors: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    _initDemoVitals();
    notifyListeners();
  }

  // Initialize demo vitals for hackathon
  void _initDemoVitals() {
    final now = DateTime.now();
    
    // Add some BP readings
    for (int i = 30; i >= 0; i -= 3) {
      _vitals.add(Vitals(
        id: _uuid.v4(),
        oderId: 'demo-user-001',
        date: now.subtract(Duration(days: i)),
        type: 'bp',
        value: 115 + (i % 10).toDouble(), // Systolic
        secondaryValue: 75 + (i % 5).toDouble(), // Diastolic
        timeOfDay: 'morning',
        createdAt: now.subtract(Duration(days: i)),
      ));
    }

    // Add weight readings
    double baseWeight = 62;
    for (int i = 30; i >= 0; i -= 7) {
      _vitals.add(Vitals(
        id: _uuid.v4(),
        oderId: 'demo-user-001',
        date: now.subtract(Duration(days: i)),
        type: 'weight',
        value: baseWeight + ((30 - i) / 10),
        createdAt: now.subtract(Duration(days: i)),
      ));
    }
  }

  // Log blood pressure
  void logBloodPressure(double systolic, double diastolic, {String? notes}) {
    final vital = Vitals(
      id: _uuid.v4(),
      oderId: 'demo-user-001',
      date: DateTime.now(),
      type: 'bp',
      value: systolic,
      secondaryValue: diastolic,
      timeOfDay: _getTimeOfDay(),
      notes: notes,
      createdAt: DateTime.now(),
    );
    
    _vitals.add(vital);
    _updateRiskScore();
    notifyListeners();
  }

  // Log weight
  void logWeight(double weight) {
    _vitals.add(Vitals(
      id: _uuid.v4(),
      oderId: 'demo-user-001',
      date: DateTime.now(),
      type: 'weight',
      value: weight,
      createdAt: DateTime.now(),
    ));
    _updateRiskScore();
    notifyListeners();
  }

  // Log blood sugar
  void logBloodSugar(double value, {String mealContext = 'fasting'}) {
    _vitals.add(Vitals(
      id: _uuid.v4(),
      oderId: 'demo-user-001',
      date: DateTime.now(),
      type: 'bloodSugar',
      value: value,
      mealContext: mealContext,
      createdAt: DateTime.now(),
    ));
    _updateRiskScore();
    notifyListeners();
  }

  // Log symptom
  void logSymptom(String type, int severity, {bool isWarning = false}) {
    _symptoms.add(Symptom(
      id: _uuid.v4(),
      oderId: 'demo-user-001',
      date: DateTime.now(),
      type: type,
      severity: severity,
      isWarning: isWarning,
      createdAt: DateTime.now(),
    ));
    _updateRiskScore();
    notifyListeners();
  }

  // Start kick counter
  FetalMovement startKickCounter() {
    final movement = FetalMovement(
      id: _uuid.v4(),
      oderId: 'demo-user-001',
      date: DateTime.now(),
      startTime: DateTime.now(),
    );
    _fetalMovements.add(movement);
    notifyListeners();
    return movement;
  }

  // Add kick
  void addKick(String movementId) {
    final index = _fetalMovements.indexWhere((m) => m.id == movementId);
    if (index >= 0) {
      _fetalMovements[index].kickCount++;
      _fetalMovements[index].durationMinutes = 
          DateTime.now().difference(_fetalMovements[index].startTime).inMinutes;
      notifyListeners();
    }
  }

  // End kick counter
  void endKickCounter(String movementId) {
    final index = _fetalMovements.indexWhere((m) => m.id == movementId);
    if (index >= 0) {
      _fetalMovements[index].endTime = DateTime.now();
      _fetalMovements[index].durationMinutes = 
          _fetalMovements[index].endTime!.difference(_fetalMovements[index].startTime).inMinutes;
      notifyListeners();
    }
  }

  // Start contraction timer
  void startContractionTimer() {
    _isTimingContraction = true;
    _contractionStartTime = DateTime.now();
    notifyListeners();
  }

  // Stop contraction timer
  void stopContractionTimer({int? intensityRating}) {
    if (_contractionStartTime != null) {
      final endTime = DateTime.now();
      _contractions.add(Contraction(
        id: _uuid.v4(),
        oderId: 'demo-user-001',
        startTime: _contractionStartTime!,
        endTime: endTime,
        durationSeconds: endTime.difference(_contractionStartTime!).inSeconds,
        intensityRating: intensityRating,
      ));
    }
    _isTimingContraction = false;
    _contractionStartTime = null;
    notifyListeners();
  }

  // Get time since contraction started
  int get contractionDurationSeconds {
    if (_contractionStartTime == null) return 0;
    return DateTime.now().difference(_contractionStartTime!).inSeconds;
  }

  // Check if ready for hospital (5-1-1 rule)
  bool get isReadyForHospital {
    if (_contractions.length < 3) return false;
    
    final recentContractions = _contractions.reversed.take(3).toList();
    
    // Check if contractions are about 5 min apart and lasting ~1 min
    bool fiveMinApart = true;
    bool oneMinDuration = true;
    
    for (int i = 0; i < recentContractions.length - 1; i++) {
      final gap = recentContractions[i].startTime
          .difference(recentContractions[i + 1].endTime ?? recentContractions[i + 1].startTime)
          .inMinutes;
      if (gap > 6) fiveMinApart = false;
      if (recentContractions[i].durationSeconds < 45) oneMinDuration = false;
    }
    
    return fiveMinApart && oneMinDuration;
  }

  // Calculate and update risk score
  void _updateRiskScore() {
    if (_pregnancy == null) return;
    
    double score = 10; // Base score
    List<String> factors = [];
    
    // Check BP
    final recentBP = _vitals.where((v) => v.type == 'bp').toList();
    if (recentBP.isNotEmpty) {
      final latestBP = recentBP.last;
      if (latestBP.isHighBP) {
        score += 30;
        factors.add('High Blood Pressure');
      } else if (latestBP.isElevatedBP) {
        score += 15;
        factors.add('Elevated Blood Pressure');
      }
    }
    
    // Check blood sugar
    final recentBS = _vitals.where((v) => v.type == 'bloodSugar').toList();
    if (recentBS.isNotEmpty && recentBS.last.isHighBloodSugar) {
      score += 20;
      factors.add('High Blood Sugar');
    }
    
    // Check warning symptoms
    final warningSymptoms = _symptoms.where((s) => s.isWarning).toList();
    if (warningSymptoms.isNotEmpty) {
      score += warningSymptoms.length * 15;
      factors.add('Warning Symptoms Reported');
    }
    
    // Check decreased fetal movement
    if (_fetalMovements.isNotEmpty && _fetalMovements.last.isConcerning) {
      score += 25;
      factors.add('Decreased Fetal Movement');
    }
    
    // Cap at 100
    score = score.clamp(0, 100);
    
    // Determine level
    String level = 'low';
    if (score > 60) {
      level = 'high';
    } else if (score > 30) {
      level = 'medium';
    }
    
    _pregnancy = Pregnancy(
      id: _pregnancy!.id,
      oderId: _pregnancy!.oderId,
      lastMenstrualPeriod: _pregnancy!.lastMenstrualPeriod,
      dueDate: _pregnancy!.dueDate,
      currentWeek: _pregnancy!.currentWeek,
      currentDay: _pregnancy!.currentDay,
      riskScore: score,
      riskLevel: level,
      riskFactors: factors,
      createdAt: _pregnancy!.createdAt,
      updatedAt: DateTime.now(),
    );
    
    notifyListeners();
  }

  // Get BP data for chart
  List<Map<String, dynamic>> get bpChartData {
    return _vitals
        .where((v) => v.type == 'bp')
        .map((v) => {
              'date': v.date,
              'systolic': v.value,
              'diastolic': v.secondaryValue ?? 80,
            })
        .toList();
  }

  // Get weight data for chart
  List<Map<String, dynamic>> get weightChartData {
    return _vitals
        .where((v) => v.type == 'weight')
        .map((v) => {
              'date': v.date,
              'weight': v.value,
            })
        .toList();
  }

  // Get count of vitals logged this week
  int get vitalsCount {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _vitals.where((v) => v.date.isAfter(weekAgo)).length;
  }

  // Get latest BP reading
  Vitals? get latestBP {
    final bpReadings = _vitals.where((v) => v.type == 'bp').toList();
    return bpReadings.isNotEmpty ? bpReadings.last : null;
  }

  // Get latest weight reading
  Vitals? get latestWeight {
    final weightReadings = _vitals.where((v) => v.type == 'weight').toList();
    return weightReadings.isNotEmpty ? weightReadings.last : null;
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}
