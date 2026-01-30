import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/gamification.dart';

/// Provider for managing gamification state (streaks, badges, points, challenges)
class GamificationProvider extends ChangeNotifier {
  UserGamification? _gamification;
  bool _isLoading = false;
  final List<Badge> _newlyUnlockedBadges = [];
  
  UserGamification? get gamification => _gamification;
  bool get isLoading => _isLoading;
  bool get hasNewBadges => _newlyUnlockedBadges.isNotEmpty;
  
  // Quick accessors
  int get currentStreak => _gamification?.currentStreak ?? 0;
  int get totalPoints => _gamification?.totalPoints ?? 0;
  int get level => _gamification?.level ?? 1;
  String get levelTitle => _gamification?.levelTitle ?? 'Beginner';
  double get levelProgress => _gamification?.levelProgress ?? 0.0;
  List<Badge> get earnedBadges => _gamification?.earnedBadges ?? [];
  List<Challenge> get activeChallenges => _gamification?.activeChallenges ?? [];
  
  /// Consume new badges (returns list and clears it)
  List<Badge> consumeNewBadges() {
    final badges = List<Badge>.from(_newlyUnlockedBadges);
    _newlyUnlockedBadges.clear();
    return badges;
  }
  
  /// Initialize gamification data
  Future<void> init(String userId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('gamification_$userId');
      
      if (data != null) {
        _gamification = UserGamification.fromJson(json.decode(data));
      } else {
        // Create new gamification profile
        _gamification = UserGamification(userId: userId);
        await _saveToPrefs();
      }
      
      // Load weekly challenges
      _loadWeeklyChallenges();
      
    } catch (e) {
      debugPrint('Error loading gamification: $e');
      _gamification = UserGamification(userId: userId);
    }
    
    _isLoading = false;
    notifyListeners();
  }

  /// Save gamification data to local storage
  Future<void> _saveToPrefs() async {
    if (_gamification == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'gamification_${_gamification!.userId}',
        json.encode(_gamification!.toJson()),
      );
    } catch (e) {
      debugPrint('Error saving gamification: $e');
    }
  }

  /// Load or refresh weekly challenges
  void _loadWeeklyChallenges() {
    if (_gamification == null) return;
    
    final weeklyChallenges = WeeklyChallenges.getWeeklyChallenges();
    
    // Check if we need new challenges (new week started)
    if (_gamification!.activeChallenges.isEmpty ||
        _gamification!.activeChallenges.first.isExpired) {
      _gamification = _gamification!.copyWith(
        activeChallenges: weeklyChallenges,
      );
      _saveToPrefs();
    }
  }

  /// Record a log action (called when user logs symptoms, vitals, etc.)
  Future<void> recordLog(LogType type) async {
    if (_gamification == null) return;
    
    // Update streak
    _gamification!.updateStreak();
    
    // Add points based on log type
    int points = _getPointsForLog(type);
    _gamification = _gamification!.copyWith(
      totalPoints: _gamification!.totalPoints + points,
      weeklyPoints: _gamification!.weeklyPoints + points,
    );
    
    // Update challenge progress
    _updateChallengeProgress(type);
    
    // Check for new badges
    _checkForNewBadges();
    
    // Check for streak milestones
    _checkStreakMilestones();
    
    await _saveToPrefs();
    notifyListeners();
  }

  /// Get points for different log types
  int _getPointsForLog(LogType type) {
    switch (type) {
      case LogType.symptom:
        return PointValues.logSymptom;
      case LogType.vitals:
        return PointValues.logVitals;
      case LogType.mood:
        return PointValues.logMood;
      case LogType.bbt:
        return PointValues.logBBT;
      case LogType.checkIn:
        return PointValues.dailyCheckIn;
      case LogType.askAI:
        return PointValues.askAI;
      case LogType.readArticle:
        return PointValues.readArticle;
    }
  }

  /// Update challenge progress based on log type
  void _updateChallengeProgress(LogType type) {
    if (_gamification == null) return;
    
    final updatedChallenges = _gamification!.activeChallenges.map((challenge) {
      bool shouldUpdate = false;
      
      switch (challenge.id) {
        case 'perfect_week':
          shouldUpdate = true;
          break;
        case 'health_check':
          shouldUpdate = type == LogType.vitals;
          break;
        case 'symptom_tracker':
          shouldUpdate = type == LogType.symptom;
          break;
        case 'ai_explorer':
          shouldUpdate = type == LogType.askAI;
          break;
        case 'mood_check':
          shouldUpdate = type == LogType.mood;
          break;
      }
      
      if (shouldUpdate && !challenge.isCompleted) {
        final newProgress = challenge.currentProgress + 1;
        final isNowComplete = newProgress >= challenge.targetCount;
        
        if (isNowComplete) {
          // Award challenge points
          _gamification = _gamification!.copyWith(
            totalPoints: _gamification!.totalPoints + challenge.pointsReward,
            completedChallengeIds: [
              ..._gamification!.completedChallengeIds,
              challenge.id,
            ],
          );
        }
        
        return challenge.copyWith(
          currentProgress: newProgress,
          isCompleted: isNowComplete,
        );
      }
      
      return challenge;
    }).toList();
    
    _gamification = _gamification!.copyWith(activeChallenges: updatedChallenges);
  }

  /// Check and award streak milestone badges
  void _checkStreakMilestones() {
    if (_gamification == null) return;
    
    final streak = _gamification!.currentStreak;
    
    // Award streak bonus points
    if (streak == 7) {
      _addPoints(PointValues.sevenDayStreakBonus);
      _awardBadge('week_warrior');
    } else if (streak == 30) {
      _addPoints(PointValues.thirtyDayStreakBonus);
      _awardBadge('monthly_master');
    } else if (streak == 90) {
      _addPoints(PointValues.ninetyDayStreakBonus);
      _awardBadge('quarter_champion');
    } else if (streak == 365) {
      _awardBadge('legend_status');
    }
  }

  /// Check for new badges based on current state
  void _checkForNewBadges() {
    if (_gamification == null) return;
    
    // First log badge
    if (!_hasBadge('first_log') && _gamification!.currentStreak >= 1) {
      _awardBadge('first_log');
    }
  }

  /// Check if user has a specific badge
  bool _hasBadge(String badgeId) {
    return _gamification?.earnedBadges.any((b) => b.id == badgeId) ?? false;
  }

  /// Award a badge to the user
  void _awardBadge(String badgeId) {
    if (_gamification == null || _hasBadge(badgeId)) return;
    
    final badge = AllBadges.getById(badgeId);
    if (badge == null) return;
    
    final earnedBadge = badge.copyWith(
      isEarned: true,
      earnedAt: DateTime.now(),
    );
    
    _gamification = _gamification!.copyWith(
      earnedBadges: [..._gamification!.earnedBadges, earnedBadge],
    );
    
    _newlyUnlockedBadges.add(earnedBadge);
    notifyListeners();
  }

  /// Add points
  void _addPoints(int points) {
    if (_gamification == null) return;
    
    _gamification = _gamification!.copyWith(
      totalPoints: _gamification!.totalPoints + points,
    );
  }

  /// Called when user completes onboarding
  Future<void> onOnboardingComplete() async {
    if (_gamification == null) return;
    
    _awardBadge('first_steps');
    await _saveToPrefs();
    notifyListeners();
  }

  /// Called when user completes profile
  Future<void> onProfileComplete() async {
    if (_gamification == null) return;
    
    _awardBadge('profile_complete');
    await _saveToPrefs();
    notifyListeners();
  }

  /// Called when user starts pregnancy tracking
  Future<void> onPregnancyStart() async {
    if (_gamification == null) return;
    
    _awardBadge('journey_begins');
    await _saveToPrefs();
    notifyListeners();
  }

  /// Called when user detects ovulation
  Future<void> onOvulationDetected() async {
    if (_gamification == null) return;
    
    _awardBadge('ovulation_detective');
    await _saveToPrefs();
    notifyListeners();
  }

  /// Get recent earned badges (for display)
  List<Badge> get recentBadges {
    if (_gamification == null) return [];
    
    final sorted = [..._gamification!.earnedBadges];
    sorted.sort((a, b) => (b.earnedAt ?? DateTime(2000))
        .compareTo(a.earnedAt ?? DateTime(2000)));
    return sorted.take(5).toList();
  }

  /// Get all badges with earned status
  List<Badge> get allBadgesWithStatus {
    final earnedIds = _gamification?.earnedBadges.map((b) => b.id).toSet() ?? {};
    
    return AllBadges.all.map((badge) {
      if (earnedIds.contains(badge.id)) {
        final earned = _gamification!.earnedBadges.firstWhere((b) => b.id == badge.id);
        return earned;
      }
      return badge;
    }).toList();
  }

  /// Get completed challenges count
  int get completedChallengesCount {
    return _gamification?.activeChallenges.where((c) => c.isCompleted).length ?? 0;
  }
}

/// Types of logs for point tracking
enum LogType {
  symptom,
  vitals,
  mood,
  bbt,
  checkIn,
  askAI,
  readArticle,
}
