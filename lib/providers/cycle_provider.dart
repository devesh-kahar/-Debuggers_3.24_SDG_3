import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/cycle.dart';
import '../models/symptom.dart';

class CycleProvider extends ChangeNotifier {
  Cycle? _currentCycle;
  List<Cycle> _cycleHistory = [];
  List<DailyLog> _dailyLogs = [];
  List<Symptom> _symptoms = [];
  final _uuid = const Uuid();

  Cycle? get currentCycle => _currentCycle;
  List<Cycle> get cycleHistory => _cycleHistory;
  List<DailyLog> get dailyLogs => _dailyLogs;
  List<Symptom> get symptoms => _symptoms;

  // Get current cycle day
  int get currentCycleDay => _currentCycle?.getCurrentCycleDay() ?? 1;

  // Get days until next period
  int get daysUntilNextPeriod => _currentCycle?.getDaysUntilNextPeriod() ?? 0;

  // Get today's fertility score
  int get todaysFertilityScore => _currentCycle?.getFertilityScore(DateTime.now()) ?? 0;

  // Get fertile window dates
  List<DateTime> get fertileWindow => _currentCycle?.calculateFertileWindow() ?? [];

  // Get predicted ovulation date
  DateTime? get predictedOvulationDate => _currentCycle?.ovulationDate ?? 
      _currentCycle?.startDate.add(Duration(days: (_currentCycle?.cycleLength ?? 28) - 14));

  // Initialize with demo data
  void initDemoData(DateTime lastPeriodDate, int cycleLength, int periodLength) {
    _currentCycle = Cycle(
      id: _uuid.v4(),
      oderId: 'demo-user-001',
      startDate: lastPeriodDate,
      cycleLength: cycleLength,
      periodLength: periodLength,
      ovulationDate: lastPeriodDate.add(Duration(days: cycleLength - 14)),
      isActive: true,
    );

    // Add some demo daily logs
    for (int i = 0; i < 14; i++) {
      final date = lastPeriodDate.add(Duration(days: i));
      _dailyLogs.add(DailyLog(
        id: _uuid.v4(),
        oderId: 'demo-user-001',
        date: date,
        bbtTemperature: 36.2 + (i > 10 ? 0.4 : 0), // Temperature rise after ovulation
        cervicalMucus: i < 5 ? 'dry' : (i < 10 ? 'creamy' : 'eggWhite'),
        flowIntensity: i < 5 ? (i < 2 ? 'heavy' : 'medium') : null,
        symptoms: i < 5 ? ['Cramping'] : [],
        moodRating: 3 + (i % 3),
        energyLevel: 5 + (i % 4),
        createdAt: date,
      ));
    }

    notifyListeners();
  }

  // Start new cycle (period started)
  void startNewCycle(DateTime startDate) {
    if (_currentCycle != null) {
      _currentCycle!.isActive = false;
      _currentCycle!.endDate = startDate.subtract(const Duration(days: 1));
      _cycleHistory.add(_currentCycle!);
    }

    _currentCycle = Cycle(
      id: _uuid.v4(),
      oderId: 'demo-user-001',
      startDate: startDate,
      cycleLength: _calculateAverageCycleLength(),
      periodLength: 5,
      isActive: true,
    );
    notifyListeners();
  }

  // Calculate average cycle length from history
  int _calculateAverageCycleLength() {
    if (_cycleHistory.isEmpty) return 28;
    final total = _cycleHistory.fold<int>(0, (sum, c) => sum + c.cycleLength);
    return (total / _cycleHistory.length).round();
  }

  // Log daily entry
  void logDailyEntry({
    double? bbtTemperature,
    String? cervicalMucus,
    String? flowIntensity,
    bool? hadIntercourse,
    bool? usedProtection,
    List<String>? symptoms,
    int? moodRating,
    int? energyLevel,
    double? hoursSlept,
    String? notes,
  }) {
    final today = DateTime.now();
    final normalizedDate = DateTime(today.year, today.month, today.day);
    
    // Check if entry exists for today
    final existingIndex = _dailyLogs.indexWhere((log) {
      final logDate = DateTime(log.date.year, log.date.month, log.date.day);
      return logDate == normalizedDate;
    });

    if (existingIndex >= 0) {
      // Update existing entry
      final existing = _dailyLogs[existingIndex];
      _dailyLogs[existingIndex] = DailyLog(
        id: existing.id,
        oderId: existing.oderId,
        date: existing.date,
        bbtTemperature: bbtTemperature ?? existing.bbtTemperature,
        cervicalMucus: cervicalMucus ?? existing.cervicalMucus,
        flowIntensity: flowIntensity ?? existing.flowIntensity,
        hadIntercourse: hadIntercourse ?? existing.hadIntercourse,
        usedProtection: usedProtection ?? existing.usedProtection,
        symptoms: symptoms ?? existing.symptoms,
        moodRating: moodRating ?? existing.moodRating,
        energyLevel: energyLevel ?? existing.energyLevel,
        hoursSlept: hoursSlept ?? existing.hoursSlept,
        notes: notes ?? existing.notes,
        createdAt: existing.createdAt,
      );
    } else {
      // Create new entry
      _dailyLogs.add(DailyLog(
        id: _uuid.v4(),
        oderId: 'demo-user-001',
        date: normalizedDate,
        bbtTemperature: bbtTemperature,
        cervicalMucus: cervicalMucus,
        flowIntensity: flowIntensity,
        hadIntercourse: hadIntercourse,
        usedProtection: usedProtection,
        symptoms: symptoms ?? [],
        moodRating: moodRating,
        energyLevel: energyLevel,
        hoursSlept: hoursSlept,
        notes: notes,
        createdAt: DateTime.now(),
      ));
    }
    notifyListeners();
  }

  // Log symptom
  void logSymptom(String type, int severity, {String category = 'physical', bool isWarning = false}) {
    _symptoms.add(Symptom(
      id: _uuid.v4(),
      oderId: 'demo-user-001',
      date: DateTime.now(),
      type: type,
      severity: severity,
      category: category,
      isWarning: isWarning,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  // Get daily log for date
  DailyLog? getLogForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    try {
      return _dailyLogs.firstWhere((log) {
        final logDate = DateTime(log.date.year, log.date.month, log.date.day);
        return logDate == normalizedDate;
      });
    } catch (_) {
      return null;
    }
  }

  // Get BBT data for chart
  List<Map<String, dynamic>> getBBTChartData() {
    return _dailyLogs
        .where((log) => log.bbtTemperature != null)
        .map((log) => {
              'date': log.date,
              'temp': log.bbtTemperature,
            })
        .toList();
  }

  // Get day type for calendar coloring
  String getDayType(DateTime date) {
    if (_currentCycle == null) return 'unknown';
    if (_currentCycle!.isPeriodDay(date)) return 'period';
    if (_currentCycle!.isOvulationDay(date)) return 'ovulation';
    if (_currentCycle!.isFertileDay(date)) return 'fertile';
    return 'safe';
  }

  // Check if date is in future
  bool isFutureDate(DateTime date) {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return normalizedDate.isAfter(normalizedToday);
  }
}
