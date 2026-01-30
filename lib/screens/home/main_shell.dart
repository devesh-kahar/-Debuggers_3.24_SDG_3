import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

import '../../providers/user_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/pregnancy_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/gamification_widgets.dart'; // Add widget import
import 'fertility_home.dart';
import 'pregnancy_home.dart';
import '../fertility/calendar_screen.dart';
import '../chatbot/ai_chat_screen.dart';
import '../gamification/gamification_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize gamification after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (userProvider.user != null) {
        context.read<GamificationProvider>().init(userProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final gamificationProvider = context.watch<GamificationProvider>();
    final isFertilityMode = userProvider.isFertilityMode;

    // Check for unlocked badges
    if (gamificationProvider.hasNewBadges) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final badges = context.read<GamificationProvider>().consumeNewBadges();
        for (final badge in badges) {
          BadgeUnlockDialog.show(context, badge);
        }
      });
    }

    final screens = [
      isFertilityMode ? const FertilityHome() : const PregnancyHome(),
      const CalendarScreen(),
      const AIChatScreen(),
      const GamificationScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Theme.of(context).cardColor,
            selectedItemColor: isFertilityMode 
                ? AppTheme.primaryTeal 
                : AppTheme.primaryPink,
            unselectedItemColor: AppTheme.textLight,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            items: [
              BottomNavigationBarItem(
                icon: Icon(_currentIndex == 0 ? Iconsax.home5 : Iconsax.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(_currentIndex == 1 ? Iconsax.calendar5 : Iconsax.calendar),
                label: 'Calendar',
              ),
              BottomNavigationBarItem(
                icon: Icon(_currentIndex == 2 ? Iconsax.message5 : Iconsax.message),
                label: 'AI Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(_currentIndex == 3 ? Iconsax.cup5 : Iconsax.cup),
                label: 'Rewards',
              ),
              BottomNavigationBarItem(
                icon: Icon(_currentIndex == 4 ? Iconsax.user5 : Iconsax.user),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
