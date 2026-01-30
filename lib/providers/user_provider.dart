import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../services/fcm_service.dart';

class UserProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  User? _user;
  bool _isLoading = false;
  String? _token;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  bool get isOnboardingComplete => _user?.isOnboardingComplete ?? false;
  String get currentMode => _user?.currentMode ?? AppConstants.modeFertility;
  bool get isFertilityMode => currentMode == AppConstants.modeFertility;
  bool get isPregnancyMode => currentMode == AppConstants.modePregnancy;
  String? get token => _token;

  // Initialize and check for existing session
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _token = await _api.getToken();
    if (_token != null) {
      try {
        final response = await _api.dio.get('/auth/profile');
        if (response.statusCode == 200) {
          _user = User.fromJson(response.data);
          SocketService().init(_user!.id);
        }
      } catch (e) {
        await _api.deleteToken();
        _token = null;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Register
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201) {
        _token = response.data['token'];
        _user = User.fromJson(response.data['user']);
        await _api.saveToken(_token!);
        
        // Sync FCM Token
        final fcmToken = await FcmService().getToken();
        if (fcmToken != null) {
          await _api.dio.post('/auth/update-fcm', data: {'fcmToken': fcmToken});
        }
        
        SocketService().init(_user!.id);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Register error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        _token = response.data['token'];
        _user = User.fromJson(response.data['user']);
        await _api.saveToken(_token!);
        
        // Sync FCM Token
        final fcmToken = await FcmService().getToken();
        if (fcmToken != null) {
          await _api.dio.post('/auth/update-fcm', data: {'fcmToken': fcmToken});
        }
        
        SocketService().init(_user!.id);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

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

  // Update user profile info
  void updateUser({
    String? name,
    int? age,
    double? height,
    double? weight,
    String? currentMode,
    bool? isOnboardingComplete,
  }) {
    if (_user != null) {
      _user = _user!.copyWith(
        name: name,
        age: age,
        height: height,
        weight: weight,
        currentMode: currentMode,
        isOnboardingComplete: isOnboardingComplete,
        updatedAt: DateTime.now(),
      );
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
