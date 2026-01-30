import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:developer' as dev;

/// Comprehensive notification service handling both FCM and local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  // Callback for when notification is tapped
  Function(String? payload)? onNotificationTap;

  /// Initialize the notification service
  Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Initialize local notifications
    await _initLocalNotifications();

    // Initialize FCM
    await _initFirebaseMessaging();

    dev.log('NotificationService initialized');
  }

  /// Initialize local notifications plugin
  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        dev.log('Notification tapped: ${response.payload}');
        onNotificationTap?.call(response.payload);
      },
    );

    // Request Android 13+ permission
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  /// Initialize Firebase Cloud Messaging
  Future<void> _initFirebaseMessaging() async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    dev.log('FCM Permission: ${settings.authorizationStatus}');

    // Handle foreground messages - show local notification
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app was in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened via notification
    RemoteMessage? initialMessage = 
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Handle foreground FCM messages by showing local notification
  void _handleForegroundMessage(RemoteMessage message) {
    dev.log('Foreground message: ${message.notification?.title}');
    
    if (message.notification != null) {
      showNotification(
        title: message.notification!.title ?? 'MomAI',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    dev.log('Notification tap: ${message.data}');
    onNotificationTap?.call(message.data.toString());
  }

  /// Get FCM token for this device
  Future<String?> getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      dev.log('FCM Token: $token');
      return token;
    } catch (e) {
      dev.log('Error getting FCM token: $e');
      return null;
    }
  }

  /// Show an immediate local notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'mommai_channel',
      'MomAI Notifications',
      channelDescription: 'Health reminders and updates from MomAI',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF26A69A),
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  /// Schedule a notification for a specific time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'mommai_reminders',
      'Health Reminders',
      channelDescription: 'Scheduled health reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFE91E63),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    dev.log('Scheduled notification $id for $scheduledTime');
  }

  /// Schedule daily reminder at a specific time
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'mommai_daily',
      'Daily Reminders',
      channelDescription: 'Daily health tracking reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF26A69A),
    );

    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      payload: payload,
    );

    dev.log('Scheduled daily reminder $id at ${time.hour}:${time.minute}');
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // ==================== PRESET REMINDERS ====================

  /// Schedule medication reminder
  Future<void> scheduleMedicationReminder({
    required String medicationName,
    required TimeOfDay time,
  }) async {
    await scheduleDailyReminder(
      id: medicationName.hashCode,
      title: '💊 Medication Reminder',
      body: 'Time to take your $medicationName',
      time: time,
      payload: 'medication:$medicationName',
    );
  }

  /// Schedule prenatal vitamin reminder (common for pregnancy)
  Future<void> schedulePrenatalVitaminReminder(TimeOfDay time) async {
    await scheduleDailyReminder(
      id: 1001,
      title: '💊 Prenatal Vitamin',
      body: 'Don\'t forget your prenatal vitamin today!',
      time: time,
      payload: 'vitamin:prenatal',
    );
  }

  /// Schedule daily logging reminder
  Future<void> scheduleLoggingReminder(TimeOfDay time) async {
    await scheduleDailyReminder(
      id: 1002,
      title: '📝 Daily Check-In',
      body: 'Log your symptoms and vitals to keep your streak going! 🔥',
      time: time,
      payload: 'action:log',
    );
  }

  /// Schedule BBT tracking reminder (for fertility mode)
  Future<void> scheduleBBTReminder(TimeOfDay time) async {
    await scheduleDailyReminder(
      id: 1003,
      title: '🌡️ BBT Reminder',
      body: 'Time to take your basal body temperature!',
      time: time,
      payload: 'action:bbt',
    );
  }

  /// Schedule appointment reminder
  Future<void> scheduleAppointmentReminder({
    required String appointmentTitle,
    required DateTime appointmentTime,
  }) async {
    // Remind 1 day before
    final dayBefore = appointmentTime.subtract(const Duration(days: 1));
    await scheduleNotification(
      id: appointmentTime.hashCode,
      title: '📅 Appointment Tomorrow',
      body: '$appointmentTitle is scheduled for tomorrow',
      scheduledTime: dayBefore,
      payload: 'appointment:$appointmentTitle',
    );

    // Remind 1 hour before
    final hourBefore = appointmentTime.subtract(const Duration(hours: 1));
    await scheduleNotification(
      id: appointmentTime.hashCode + 1,
      title: '🏥 Appointment in 1 Hour',
      body: '$appointmentTitle starts soon!',
      scheduledTime: hourBefore,
      payload: 'appointment:$appointmentTitle',
    );
  }

  /// Schedule fertile window notification
  Future<void> notifyFertileWindow(DateTime startDate) async {
    await scheduleNotification(
      id: 2001,
      title: '🌸 Fertile Window Starting',
      body: 'Your fertile window begins today! Great time to try to conceive.',
      scheduledTime: startDate,
      payload: 'fertility:window',
    );
  }

  /// Notify about ovulation day prediction
  Future<void> notifyOvulationDay(DateTime ovulationDate) async {
    await scheduleNotification(
      id: 2002,
      title: '🥚 Ovulation Day',
      body: 'Today is your predicted ovulation day!',
      scheduledTime: ovulationDate,
      payload: 'fertility:ovulation',
    );
  }

  /// Background message handler (must be top-level function)
  static Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    dev.log('Background message: ${message.messageId}');
  }
}
