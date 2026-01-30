import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/notification_service.dart';

import 'utils/theme.dart';
import 'providers/user_provider.dart';
import 'providers/cycle_provider.dart';
import 'providers/pregnancy_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/gamification_provider.dart';
import 'screens/home/main_shell.dart';
import 'screens/auth/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(NotificationService.firebaseBackgroundHandler);
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MomAIApp());
}

class MomAIApp extends StatelessWidget {
  const MomAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CycleProvider()),
        ChangeNotifierProvider(create: (_) => PregnancyProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => GamificationProvider()),
      ],
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return MaterialApp(
            title: 'MomAI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: userProvider.user?.isDarkMode == true 
                ? ThemeMode.dark 
                : ThemeMode.light,
            home: const AppRouter(),
          );
        },
      ),
    );
  }
}

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    await NotificationService().init();
    
    // Set up notification tap handler
    NotificationService().onNotificationTap = (payload) {
      debugPrint('Notification tapped with payload: $payload');
      // Navigate based on payload
      // TODO: Add navigation logic based on payload type
    };
  }

  Future<void> _initializeApp() async {
    final userProvider = context.read<UserProvider>();
    final cycleProvider = context.read<CycleProvider>();
    final pregnancyProvider = context.read<PregnancyProvider>();

    // Check for existing session
    await userProvider.init();
    
    // If logged in, fetch related data
    if (userProvider.isLoggedIn) {
      await cycleProvider.fetchCycleData();
      if (userProvider.isPregnancyMode) {
        await pregnancyProvider.fetchPregnancyData(userProvider.user!.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (!userProvider.isLoggedIn) {
          return const WelcomeScreen();
        }
        return const MainShell();
      },
    );
  }
}
