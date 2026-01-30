import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  bool get isOnboardingComplete => _user?.isOnboardingComplete ?? false;
  String get currentMode => _user?.currentMode ?? AppConstants.modeFertility;
  bool get isFertilityMode => currentMode == AppConstants.modeFertility;
  bool get isPregnancyMode => currentMode == AppConstants.modePregnancy;

  // Initialize with demo user for hackathon
  void initDemoUser() {
    _user = User(
      id: 'demo-user-001',
      name: 'Sarah',
      email: 'sarah@example.com',
      age: 28,
      height: 165,
      weight: 62,
      bloodType: 'O+',
      currentMode: AppConstants.modeFertility,
      lastPeriodDate: DateTime.now().subtract(const Duration(days: 14)),
      cycleLength: 28,
      periodLength: 5,
      medicalConditions: [],
      previousComplications: [],
      previousPregnancies: 0,
      isOnboardingComplete: true,
      preferredUnits: 'metric',
      isDarkMode: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  // Set user
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  // Update user
  void updateUser(User Function(User) updater) {
    if (_user != null) {
      _user = updater(_user!);
      notifyListeners();
    }
  }

  // Toggle mode between fertility and pregnancy
  void toggleMode() {
    if (_user != null) {
      final newMode = isFertilityMode 
          ? AppConstants.modePregnancy 
          : AppConstants.modeFertility;
      _user = _user!.copyWith(
        currentMode: newMode,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Switch to pregnancy mode
  void switchToPregnancyMode({DateTime? lastPeriodDate}) {
    if (_user != null) {
      final lmp = lastPeriodDate ?? _user!.lastPeriodDate ?? DateTime.now().subtract(const Duration(days: 28));
      final dueDate = lmp.add(const Duration(days: 280));
      final currentWeek = ((DateTime.now().difference(lmp).inDays) / 7).floor() + 1;
      
      _user = _user!.copyWith(
        currentMode: AppConstants.modePregnancy,
        lastPeriodDate: lmp,
        dueDate: dueDate,
        currentPregnancyWeek: currentWeek,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Switch to fertility mode
  void switchToFertilityMode() {
    if (_user != null) {
      _user = _user!.copyWith(
        currentMode: AppConstants.modeFertility,
        dueDate: null,
        currentPregnancyWeek: null,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Update weight
  void updateWeight(double weight) {
    if (_user != null) {
      _user = _user!.copyWith(
        weight: weight,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Update last period date
  void updateLastPeriodDate(DateTime date) {
    if (_user != null) {
      _user = _user!.copyWith(
        lastPeriodDate: date,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Toggle dark mode
  void toggleDarkMode() {
    if (_user != null) {
      _user = _user!.copyWith(
        isDarkMode: !_user!.isDarkMode,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Complete onboarding
  void completeOnboarding() {
    if (_user != null) {
      _user = _user!.copyWith(
        isOnboardingComplete: true,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Logout
  void logout() {
    _user = null;
    notifyListeners();
  }
}
