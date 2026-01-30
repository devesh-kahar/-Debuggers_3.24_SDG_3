/// Gamification Model for MomAI
/// Handles streaks, badges, points, levels, and challenges for pregnancy/fertility tracking

class UserGamification {
  final String userId;
  
  // Streak
  int currentStreak;
  int longestStreak;
  DateTime? lastLogDate;
  int streakFreezes;
  
  // Points & Level
  int totalPoints;
  int weeklyPoints;
  int monthlyPoints;
  
  // Badges
  List<Badge> earnedBadges;
  
  // Challenges
  List<Challenge> activeChallenges;
  List<String> completedChallengeIds;
  
  UserGamification({
    required this.userId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastLogDate,
    this.streakFreezes = 0,
    this.totalPoints = 0,
    this.weeklyPoints = 0,
    this.monthlyPoints = 0,
    this.earnedBadges = const [],
    this.activeChallenges = const [],
    this.completedChallengeIds = const [],
  });

  // Calculate user level based on total points
  int get level {
    if (totalPoints < 200) return 1;
    if (totalPoints < 500) return 2;
    if (totalPoints < 800) return 3;
    if (totalPoints < 1200) return 4;
    if (totalPoints < 1700) return 5;
    if (totalPoints < 2300) return 6;
    if (totalPoints < 3000) return 7;
    if (totalPoints < 3800) return 8;
    if (totalPoints < 4700) return 9;
    if (totalPoints < 5700) return 10;
    return (totalPoints ~/ 1000) + 5;
  }

  // Get level title
  String get levelTitle {
    if (level <= 2) return 'Beginner';
    if (level <= 4) return 'Explorer';
    if (level <= 6) return 'Dedicated';
    if (level <= 8) return 'Expert';
    if (level <= 10) return 'Master';
    return 'Legend';
  }

  // Points needed for next level
  int get pointsToNextLevel {
    final thresholds = [0, 200, 500, 800, 1200, 1700, 2300, 3000, 3800, 4700, 5700];
    if (level >= 10) return ((level - 4) * 1000) - totalPoints;
    return thresholds[level] - totalPoints;
  }

  // Progress to next level (0.0 - 1.0)
  double get levelProgress {
    final thresholds = [0, 200, 500, 800, 1200, 1700, 2300, 3000, 3800, 4700, 5700];
    if (level >= 10) {
      final currentThreshold = (level - 5) * 1000 + 5700;
      final nextThreshold = currentThreshold + 1000;
      return (totalPoints - currentThreshold) / 1000;
    }
    final currentThreshold = thresholds[level - 1];
    final nextThreshold = thresholds[level];
    return (totalPoints - currentThreshold) / (nextThreshold - currentThreshold);
  }

  // Check if streak is still active
  bool get isStreakActive {
    if (lastLogDate == null) return false;
    final now = DateTime.now();
    final diff = now.difference(lastLogDate!).inDays;
    return diff <= 1;
  }

  // Update streak when user logs
  void updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (lastLogDate == null) {
      currentStreak = 1;
    } else {
      final lastLog = DateTime(lastLogDate!.year, lastLogDate!.month, lastLogDate!.day);
      final diff = today.difference(lastLog).inDays;
      
      if (diff == 0) {
        return; // Already logged today
      } else if (diff == 1) {
        currentStreak++;
      } else if (diff == 2 && streakFreezes > 0) {
        streakFreezes--;
        currentStreak++;
      } else {
        currentStreak = 1; // Streak broken
      }
    }
    
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }
    lastLogDate = today;
  }

  factory UserGamification.fromJson(Map<String, dynamic> json) {
    return UserGamification(
      userId: json['userId'] ?? '',
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastLogDate: json['lastLogDate'] != null 
          ? DateTime.parse(json['lastLogDate']) 
          : null,
      streakFreezes: json['streakFreezes'] ?? 0,
      totalPoints: json['totalPoints'] ?? 0,
      weeklyPoints: json['weeklyPoints'] ?? 0,
      monthlyPoints: json['monthlyPoints'] ?? 0,
      earnedBadges: (json['earnedBadges'] as List?)
          ?.map((b) => Badge.fromJson(b))
          .toList() ?? [],
      activeChallenges: (json['activeChallenges'] as List?)
          ?.map((c) => Challenge.fromJson(c))
          .toList() ?? [],
      completedChallengeIds: List<String>.from(json['completedChallengeIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastLogDate': lastLogDate?.toIso8601String(),
      'streakFreezes': streakFreezes,
      'totalPoints': totalPoints,
      'weeklyPoints': weeklyPoints,
      'monthlyPoints': monthlyPoints,
      'earnedBadges': earnedBadges.map((b) => b.toJson()).toList(),
      'activeChallenges': activeChallenges.map((c) => c.toJson()).toList(),
      'completedChallengeIds': completedChallengeIds,
    };
  }

  UserGamification copyWith({
    String? userId,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastLogDate,
    int? streakFreezes,
    int? totalPoints,
    int? weeklyPoints,
    int? monthlyPoints,
    List<Badge>? earnedBadges,
    List<Challenge>? activeChallenges,
    List<String>? completedChallengeIds,
  }) {
    return UserGamification(
      userId: userId ?? this.userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastLogDate: lastLogDate ?? this.lastLogDate,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      totalPoints: totalPoints ?? this.totalPoints,
      weeklyPoints: weeklyPoints ?? this.weeklyPoints,
      monthlyPoints: monthlyPoints ?? this.monthlyPoints,
      earnedBadges: earnedBadges ?? this.earnedBadges,
      activeChallenges: activeChallenges ?? this.activeChallenges,
      completedChallengeIds: completedChallengeIds ?? this.completedChallengeIds,
    );
  }
}

/// Point values for different actions
class PointValues {
  static const int logSymptom = 10;
  static const int logBBT = 15;
  static const int logVitals = 20;
  static const int logMood = 10;
  static const int dailyCheckIn = 25;
  static const int readArticle = 15;
  static const int askAI = 10;
  static const int completeChallenge = 100;
  static const int sevenDayStreakBonus = 50;
  static const int thirtyDayStreakBonus = 150;
  static const int ninetyDayStreakBonus = 300;
}

/// Badge model
class Badge {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final BadgeCategory category;
  final BadgeTier tier;
  final DateTime? earnedAt;
  final bool isEarned;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.category,
    this.tier = BadgeTier.bronze,
    this.earnedAt,
    this.isEarned = false,
  });

  Badge copyWith({
    String? id,
    String? name,
    String? description,
    String? emoji,
    BadgeCategory? category,
    BadgeTier? tier,
    DateTime? earnedAt,
    bool? isEarned,
  }) {
    return Badge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      tier: tier ?? this.tier,
      earnedAt: earnedAt ?? this.earnedAt,
      isEarned: isEarned ?? this.isEarned,
    );
  }

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      emoji: json['emoji'],
      category: BadgeCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => BadgeCategory.gettingStarted,
      ),
      tier: BadgeTier.values.firstWhere(
        (e) => e.name == json['tier'],
        orElse: () => BadgeTier.bronze,
      ),
      earnedAt: json['earnedAt'] != null 
          ? DateTime.parse(json['earnedAt']) 
          : null,
      isEarned: json['isEarned'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'emoji': emoji,
      'category': category.name,
      'tier': tier.name,
      'earnedAt': earnedAt?.toIso8601String(),
      'isEarned': isEarned,
    };
  }
}

enum BadgeCategory {
  gettingStarted,
  consistency,
  health,
  pregnancy,
  fertility,
  community,
}

enum BadgeTier {
  bronze,
  silver,
  gold,
  platinum,
}

extension BadgeTierExtension on BadgeTier {
  String get displayName {
    switch (this) {
      case BadgeTier.bronze:
        return 'Bronze';
      case BadgeTier.silver:
        return 'Silver';
      case BadgeTier.gold:
        return 'Gold';
      case BadgeTier.platinum:
        return 'Platinum';
    }
  }
}

/// All available badges for MomAI
class AllBadges {
  static List<Badge> all = [
    // Getting Started (Bronze)
    Badge(
      id: 'first_steps',
      name: 'First Steps',
      description: 'Completed onboarding',
      emoji: '🎯',
      category: BadgeCategory.gettingStarted,
      tier: BadgeTier.bronze,
    ),
    Badge(
      id: 'profile_complete',
      name: 'Profile Complete',
      description: 'Filled in your profile details',
      emoji: '📝',
      category: BadgeCategory.gettingStarted,
      tier: BadgeTier.bronze,
    ),
    Badge(
      id: 'ai_explorer',
      name: 'AI Explorer',
      description: 'First AI chatbot conversation',
      emoji: '💬',
      category: BadgeCategory.gettingStarted,
      tier: BadgeTier.bronze,
    ),
    Badge(
      id: 'first_log',
      name: 'Logger',
      description: 'Logged your first data',
      emoji: '📊',
      category: BadgeCategory.gettingStarted,
      tier: BadgeTier.bronze,
    ),

    // Consistency (Bronze → Platinum)
    Badge(
      id: 'week_warrior',
      name: 'Week Warrior',
      description: '7-day streak',
      emoji: '🔥',
      category: BadgeCategory.consistency,
      tier: BadgeTier.bronze,
    ),
    Badge(
      id: 'monthly_master',
      name: 'Monthly Master',
      description: '30-day streak',
      emoji: '📅',
      category: BadgeCategory.consistency,
      tier: BadgeTier.silver,
    ),
    Badge(
      id: 'quarter_champion',
      name: 'Quarter Champion',
      description: '90-day streak',
      emoji: '🏆',
      category: BadgeCategory.consistency,
      tier: BadgeTier.gold,
    ),
    Badge(
      id: 'legend_status',
      name: 'Legend Status',
      description: '365-day streak',
      emoji: '👑',
      category: BadgeCategory.consistency,
      tier: BadgeTier.platinum,
    ),

    // Health Tracking
    Badge(
      id: 'vital_tracker',
      name: 'Vital Tracker',
      description: 'Logged vitals 10 times',
      emoji: '❤️',
      category: BadgeCategory.health,
      tier: BadgeTier.bronze,
    ),
    Badge(
      id: 'health_conscious',
      name: 'Health Conscious',
      description: 'Logged vitals 50 times',
      emoji: '💪',
      category: BadgeCategory.health,
      tier: BadgeTier.silver,
    ),
    Badge(
      id: 'symptom_sleuth',
      name: 'Symptom Sleuth',
      description: 'Logged symptoms 20 times',
      emoji: '🔍',
      category: BadgeCategory.health,
      tier: BadgeTier.bronze,
    ),
    Badge(
      id: 'mood_master',
      name: 'Mood Master',
      description: 'Logged mood 30 times',
      emoji: '😊',
      category: BadgeCategory.health,
      tier: BadgeTier.silver,
    ),

    // Pregnancy Journey
    Badge(
      id: 'journey_begins',
      name: 'Journey Begins',
      description: 'Started pregnancy tracking',
      emoji: '🤰',
      category: BadgeCategory.pregnancy,
      tier: BadgeTier.bronze,
    ),
    Badge(
      id: 'first_trimester',
      name: 'First Trimester',
      description: 'Completed first trimester',
      emoji: '🌱',
      category: BadgeCategory.pregnancy,
      tier: BadgeTier.silver,
    ),
    Badge(
      id: 'second_trimester',
      name: 'Second Trimester',
      description: 'Completed second trimester',
      emoji: '🌸',
      category: BadgeCategory.pregnancy,
      tier: BadgeTier.gold,
    ),
    Badge(
      id: 'third_trimester',
      name: 'Third Trimester',
      description: 'Entering final stretch!',
      emoji: '🎉',
      category: BadgeCategory.pregnancy,
      tier: BadgeTier.platinum,
    ),
    Badge(
      id: 'weekly_check',
      name: 'Weekly Check',
      description: 'Logged for 4 weeks straight',
      emoji: '📆',
      category: BadgeCategory.pregnancy,
      tier: BadgeTier.bronze,
    ),

    // Fertility Tracking
    Badge(
      id: 'cycle_tracker',
      name: 'Cycle Tracker',
      description: 'Tracked 3 complete cycles',
      emoji: '🔄',
      category: BadgeCategory.fertility,
      tier: BadgeTier.silver,
    ),
    Badge(
      id: 'ovulation_detective',
      name: 'Ovulation Detective',
      description: 'First ovulation detected',
      emoji: '🥚',
      category: BadgeCategory.fertility,
      tier: BadgeTier.bronze,
    ),
    Badge(
      id: 'temp_tracker',
      name: 'Temp Tracker',
      description: 'Logged BBT 15 times',
      emoji: '🌡️',
      category: BadgeCategory.fertility,
      tier: BadgeTier.bronze,
    ),
    Badge(
      id: 'pattern_pro',
      name: 'Pattern Pro',
      description: 'Identified cycle patterns',
      emoji: '📈',
      category: BadgeCategory.fertility,
      tier: BadgeTier.gold,
    ),

    // Community
    Badge(
      id: 'knowledge_seeker',
      name: 'Knowledge Seeker',
      description: 'Read 10 articles',
      emoji: '📚',
      category: BadgeCategory.community,
      tier: BadgeTier.bronze,
    ),
    Badge(
      id: 'curious_mind',
      name: 'Curious Mind',
      description: 'Asked AI 25 questions',
      emoji: '🧠',
      category: BadgeCategory.community,
      tier: BadgeTier.silver,
    ),
  ];

  static Badge? getById(String id) {
    try {
      return all.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Challenge model
class Challenge {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final ChallengeType type;
  final int targetCount;
  int currentProgress;
  final int pointsReward;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;

  Challenge({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.type,
    required this.targetCount,
    this.currentProgress = 0,
    this.pointsReward = 100,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
  });

  double get progressPercent => 
      targetCount > 0 ? (currentProgress / targetCount).clamp(0.0, 1.0) : 0.0;

  bool get isExpired => DateTime.now().isAfter(endDate);

  int get daysRemaining {
    final diff = endDate.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  Challenge copyWith({
    String? id,
    String? name,
    String? description,
    String? emoji,
    ChallengeType? type,
    int? targetCount,
    int? currentProgress,
    int? pointsReward,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCompleted,
  }) {
    return Challenge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      type: type ?? this.type,
      targetCount: targetCount ?? this.targetCount,
      currentProgress: currentProgress ?? this.currentProgress,
      pointsReward: pointsReward ?? this.pointsReward,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      emoji: json['emoji'],
      type: ChallengeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChallengeType.tracking,
      ),
      targetCount: json['targetCount'],
      currentProgress: json['currentProgress'] ?? 0,
      pointsReward: json['pointsReward'] ?? 100,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'emoji': emoji,
      'type': type.name,
      'targetCount': targetCount,
      'currentProgress': currentProgress,
      'pointsReward': pointsReward,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }
}

enum ChallengeType {
  tracking,
  health,
  wellness,
  learning,
}

/// Weekly Challenge Templates for MomAI
class WeeklyChallenges {
  static List<Challenge> getWeeklyChallenges() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    return [
      Challenge(
        id: 'perfect_week',
        name: 'Perfect Week',
        description: 'Log data every day for 7 days',
        emoji: '✨',
        type: ChallengeType.tracking,
        targetCount: 7,
        pointsReward: 100,
        startDate: weekStart,
        endDate: weekEnd,
      ),
      Challenge(
        id: 'health_check',
        name: 'Health Check',
        description: 'Log vitals 5 times this week',
        emoji: '❤️',
        type: ChallengeType.health,
        targetCount: 5,
        pointsReward: 75,
        startDate: weekStart,
        endDate: weekEnd,
      ),
      Challenge(
        id: 'symptom_tracker',
        name: 'Symptom Tracker',
        description: 'Log symptoms 7 days straight',
        emoji: '📝',
        type: ChallengeType.tracking,
        targetCount: 7,
        pointsReward: 100,
        startDate: weekStart,
        endDate: weekEnd,
      ),
      Challenge(
        id: 'ai_explorer',
        name: 'AI Explorer',
        description: 'Ask AI 5 questions',
        emoji: '🤖',
        type: ChallengeType.learning,
        targetCount: 5,
        pointsReward: 75,
        startDate: weekStart,
        endDate: weekEnd,
      ),
      Challenge(
        id: 'mood_check',
        name: 'Mood Monitor',
        description: 'Log your mood 5 days this week',
        emoji: '😊',
        type: ChallengeType.wellness,
        targetCount: 5,
        pointsReward: 75,
        startDate: weekStart,
        endDate: weekEnd,
      ),
    ];
  }
}
