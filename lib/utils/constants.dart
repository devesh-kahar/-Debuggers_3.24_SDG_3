class AppConstants {
  // App Info
  static const String appName = 'MomAI';
  static const String appTagline = 'From Conception to Birth';
  static const String appVersion = '1.0.0';
  
  // User Modes
  static const String modeFertility = 'fertility';
  static const String modePregnancy = 'pregnancy';
  
  // Cycle Constants
  static const int defaultCycleLength = 28;
  static const int defaultPeriodLength = 5;
  static const int fertileWindowDays = 6;
  static const int ovulationDayBeforePeriod = 14;
  
  // Pregnancy Constants
  static const int pregnancyWeeks = 40;
  static const int trimester1End = 12;
  static const int trimester2End = 27;
  static const int trimester3End = 40;
  
  // Risk Thresholds
  static const int riskLowMax = 30;
  static const int riskMediumMax = 60;
  static const int riskHighMax = 100;
  
  // BP Thresholds
  static const int bpSystolicNormal = 120;
  static const int bpDiastolicNormal = 80;
  static const int bpSystolicHigh = 140;
  static const int bpDiastolicHigh = 90;
  
  // Blood Sugar Thresholds (mg/dL)
  static const int bloodSugarFastingNormal = 95;
  static const int bloodSugarPostMealNormal = 120;
  
  // BMI Categories
  static const double bmiUnderweight = 18.5;
  static const double bmiNormal = 24.9;
  static const double bmiOverweight = 29.9;
  
  // Baby Size Comparisons
  static const Map<int, String> babySizeComparisons = {
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
  
  // Symptom Categories
  static const List<String> fertilitySymptoms = [
    'Cramping',
    'Bloating',
    'Headache',
    'Back Pain',
    'Breast Tenderness',
    'Fatigue',
    'Mood Swings',
    'Acne',
    'Food Cravings',
    'Nausea',
  ];
  
  static const List<String> pregnancySymptoms = [
    'Nausea',
    'Fatigue',
    'Back Pain',
    'Swelling',
    'Headache',
    'Heartburn',
    'Constipation',
    'Shortness of Breath',
    'Frequent Urination',
    'Insomnia',
  ];
  
  // Cervical Mucus Types
  static const List<String> cervicalMucusTypes = [
    'Dry',
    'Sticky',
    'Creamy',
    'Watery',
    'Egg White',
  ];
  
  // Period Flow Intensity
  static const List<String> flowIntensity = [
    'Spotting',
    'Light',
    'Medium',
    'Heavy',
  ];
  
  // Warning Symptoms
  static const List<String> warningSymptoms = [
    'Severe Headache',
    'Vision Changes',
    'Severe Abdominal Pain',
    'Heavy Bleeding',
    'Decreased Fetal Movement',
    'Sudden Swelling',
    'High Fever',
    'Painful Urination',
  ];
  
  // Hive Box Names
  static const String userBox = 'user_box';
  static const String cycleBox = 'cycle_box';
  static const String pregnancyBox = 'pregnancy_box';
  static const String symptomsBox = 'symptoms_box';
  static const String vitalsBox = 'vitals_box';
  static const String messagesBox = 'messages_box';
}
