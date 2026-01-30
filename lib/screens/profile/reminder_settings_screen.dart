import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/notification_service.dart';
import '../../utils/theme.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  
  // Reminder toggles
  bool _dailyLogReminder = false;
  bool _prenatalVitaminReminder = false;
  bool _bbtReminder = false;
  bool _waterReminder = false;
  
  // Reminder times
  TimeOfDay _dailyLogTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _vitaminTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _bbtTime = const TimeOfDay(hour: 6, minute: 30);
  TimeOfDay _waterTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyLogReminder = prefs.getBool('reminder_daily_log') ?? false;
      _prenatalVitaminReminder = prefs.getBool('reminder_vitamin') ?? false;
      _bbtReminder = prefs.getBool('reminder_bbt') ?? false;
      _waterReminder = prefs.getBool('reminder_water') ?? false;
      
      _dailyLogTime = TimeOfDay(
        hour: prefs.getInt('reminder_daily_log_hour') ?? 9,
        minute: prefs.getInt('reminder_daily_log_min') ?? 0,
      );
      _vitaminTime = TimeOfDay(
        hour: prefs.getInt('reminder_vitamin_hour') ?? 8,
        minute: prefs.getInt('reminder_vitamin_min') ?? 0,
      );
      _bbtTime = TimeOfDay(
        hour: prefs.getInt('reminder_bbt_hour') ?? 6,
        minute: prefs.getInt('reminder_bbt_min') ?? 30,
      );
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('reminder_daily_log', _dailyLogReminder);
    await prefs.setBool('reminder_vitamin', _prenatalVitaminReminder);
    await prefs.setBool('reminder_bbt', _bbtReminder);
    await prefs.setBool('reminder_water', _waterReminder);
    
    await prefs.setInt('reminder_daily_log_hour', _dailyLogTime.hour);
    await prefs.setInt('reminder_daily_log_min', _dailyLogTime.minute);
    await prefs.setInt('reminder_vitamin_hour', _vitaminTime.hour);
    await prefs.setInt('reminder_vitamin_min', _vitaminTime.minute);
    await prefs.setInt('reminder_bbt_hour', _bbtTime.hour);
    await prefs.setInt('reminder_bbt_min', _bbtTime.minute);
  }

  Future<void> _selectTime(BuildContext context, TimeOfDay initial, Function(TimeOfDay) onSelect) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryPink,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onSelect(picked);
      await _saveSettings();
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _toggleReminder(String type, bool value) async {
    setState(() {
      switch (type) {
        case 'daily':
          _dailyLogReminder = value;
          break;
        case 'vitamin':
          _prenatalVitaminReminder = value;
          break;
        case 'bbt':
          _bbtReminder = value;
          break;
        case 'water':
          _waterReminder = value;
          break;
      }
    });
    
    await _saveSettings();
    
    // Schedule or cancel notification
    if (value) {
      switch (type) {
        case 'daily':
          await _notificationService.scheduleLoggingReminder(_dailyLogTime);
          break;
        case 'vitamin':
          await _notificationService.schedulePrenatalVitaminReminder(_vitaminTime);
          break;
        case 'bbt':
          await _notificationService.scheduleBBTReminder(_bbtTime);
          break;
        case 'water':
          await _notificationService.scheduleDailyReminder(
            id: 1004,
            title: '💧 Hydration Check',
            body: 'Remember to drink water! Staying hydrated is important.',
            time: _waterTime,
          );
          break;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder scheduled! ✓')),
      );
    } else {
      // Cancel the notification
      switch (type) {
        case 'daily':
          await _notificationService.cancelNotification(1002);
          break;
        case 'vitamin':
          await _notificationService.cancelNotification(1001);
          break;
        case 'bbt':
          await _notificationService.cancelNotification(1003);
          break;
        case 'water':
          await _notificationService.cancelNotification(1004);
          break;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder cancelled')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Text(
            'Stay on Track',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(
            'Set up reminders to help you maintain healthy habits',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textLight,
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 32),
          
          // Daily Log Reminder
          _buildReminderCard(
            icon: Iconsax.note_add,
            color: AppTheme.primaryTeal,
            title: 'Daily Check-In',
            subtitle: 'Remind me to log my daily health data',
            time: _dailyLogTime,
            isEnabled: _dailyLogReminder,
            onToggle: (val) => _toggleReminder('daily', val),
            onTimeTap: () => _selectTime(context, _dailyLogTime, (t) {
              setState(() => _dailyLogTime = t);
              if (_dailyLogReminder) {
                _notificationService.scheduleLoggingReminder(t);
              }
            }),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
          
          const SizedBox(height: 16),
          
          // Prenatal Vitamin Reminder
          _buildReminderCard(
            icon: Iconsax.heart,
            color: AppTheme.primaryPink,
            title: 'Prenatal Vitamin',
            subtitle: 'Never miss your daily prenatal vitamin',
            time: _vitaminTime,
            isEnabled: _prenatalVitaminReminder,
            onToggle: (val) => _toggleReminder('vitamin', val),
            onTimeTap: () => _selectTime(context, _vitaminTime, (t) {
              setState(() => _vitaminTime = t);
              if (_prenatalVitaminReminder) {
                _notificationService.schedulePrenatalVitaminReminder(t);
              }
            }),
          ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
          
          const SizedBox(height: 16),
          
          // BBT Reminder (Fertility mode)
          _buildReminderCard(
            icon: Iconsax.chart_2,
            color: AppTheme.info,
            title: 'BBT Tracking',
            subtitle: 'Track basal body temperature each morning',
            time: _bbtTime,
            isEnabled: _bbtReminder,
            onToggle: (val) => _toggleReminder('bbt', val),
            onTimeTap: () => _selectTime(context, _bbtTime, (t) {
              setState(() => _bbtTime = t);
              if (_bbtReminder) {
                _notificationService.scheduleBBTReminder(t);
              }
            }),
          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
          
          const SizedBox(height: 16),
          
          // Water Reminder
          _buildReminderCard(
            icon: Iconsax.drop,
            color: Colors.blue,
            title: 'Hydration',
            subtitle: 'Stay hydrated throughout the day',
            time: _waterTime,
            isEnabled: _waterReminder,
            onToggle: (val) => _toggleReminder('water', val),
            onTimeTap: () => _selectTime(context, _waterTime, (t) {
              setState(() => _waterTime = t);
              if (_waterReminder) {
                _notificationService.scheduleDailyReminder(
                  id: 1004,
                  title: '💧 Hydration Check',
                  body: 'Remember to drink water!',
                  time: t,
                );
              }
            }),
          ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
          
          const SizedBox(height: 32),
          
          // Test Notification Button
          OutlinedButton.icon(
            onPressed: () async {
              await _notificationService.showNotification(
                title: '🔔 Test Notification',
                body: 'Your notifications are working perfectly!',
                payload: 'test',
              );
            },
            icon: const Icon(Iconsax.notification),
            label: const Text('Send Test Notification'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryPink,
              side: BorderSide(color: AppTheme.primaryPink.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildReminderCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required TimeOfDay time,
    required bool isEnabled,
    required Function(bool) onToggle,
    required VoidCallback onTimeTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnabled ? color.withOpacity(0.3) : Colors.grey.shade200,
          width: isEnabled ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isEnabled ? color.withOpacity(0.1) : Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: onToggle,
                activeColor: color,
              ),
            ],
          ),
          if (isEnabled) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: onTimeTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.clock, size: 20, color: color),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(time),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Iconsax.edit_2, size: 16, color: color.withOpacity(0.5)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
