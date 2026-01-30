import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/cycle.dart';
import '../models/symptom.dart';
import '../services/api_service.dart';

class CycleProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  Cycle? _currentCycle;
  List<Cycle> _cycleHistory = [];
  List<DailyLog> _dailyLogs = [];
  List<Symptom> _symptoms = [];
  final _uuid = const Uuid();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

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

  // Fetch cycle data from backend
  Future<void> fetchCycleData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final cycleResponse = await _api.dio.get('/cycle/active');
      if (cycleResponse.statusCode == 200 && cycleResponse.data != null) {
        _currentCycle = Cycle.fromJson(cycleResponse.data);
      }

      final logsResponse = await _api.dio.get('/cycle/logs');
      if (logsResponse.statusCode == 200) {
        _dailyLogs = (logsResponse.data as List).map((l) => DailyLog.fromJson(l)).toList();
      }

      final historyResponse = await _api.dio.get('/cycle/history');
      if (historyResponse.statusCode == 200) {
        _cycleHistory = (historyResponse.data as List).map((c) => Cycle.fromJson(c)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching cycle data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Start new cycle (period started)
  Future<void> startNewCycle(DateTime startDate) async {
    try {
      final response = await _api.dio.post('/cycle', data: {
        'startDate': startDate.toIso8601String(),
        'cycleLength': _calculateAverageCycleLength(),
        'periodLength': 5,
      });

      if (response.statusCode == 201) {
        await fetchCycleData(); // Refresh history and current cycle
      }
    } catch (e) {
      debugPrint('Error starting new cycle: $e');
    }
  }

  // Calculate average cycle length from history
  int _calculateAverageCycleLength() {
    if (_cycleHistory.isEmpty) return 28;
    final total = _cycleHistory.fold<int>(0, (sum, c) => sum + c.cycleLength);
    return (total / _cycleHistory.length).round();
  }

  // Log daily entry
  Future<void> logDailyEntry({
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
  }) async {
    final entryData = {
      'date': DateTime.now().toIso8601String(),
      'bbtTemperature': bbtTemperature,
      'cervicalMucus': cervicalMucus,
      'flowIntensity': flowIntensity,
      'hadIntercourse': hadIntercourse,
      'usedProtection': usedProtection,
      'symptoms': symptoms,
      'moodRating': moodRating,
      'energyLevel': energyLevel,
      'hoursSlept': hoursSlept,
      'notes': notes,
    };

    try {
      final response = await _api.dio.post('/cycle/logs', data: entryData);
      if (response.statusCode == 201 || response.statusCode == 200) {
        final log = DailyLog.fromJson(response.data);
        final index = _dailyLogs.indexWhere((l) => l.id == log.id);
        if (index >= 0) {
          _dailyLogs[index] = log;
        } else {
          _dailyLogs.add(log);
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error logging daily entry: $e');
    }
  }

  // Log symptom
  Future<void> logSymptom(String type, int severity, {String category = 'physical', bool isWarning = false}) async {
    try {
      final response = await _api.dio.post('/cycle/symptoms', data: {
        'type': type,
        'severity': severity,
        'category': category,
        'isWarning': isWarning,
        'date': DateTime.now().toIso8601String(),
      });
      if (response.statusCode == 201) {
        _symptoms.add(Symptom.fromJson(response.data));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error logging symptom: $e');
    }
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
