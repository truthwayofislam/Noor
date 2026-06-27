import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  FlutterLocalNotificationsPlugin get plugin => _notifications;

  Future<void> init() async {
    tz.initializeTimeZones();
    // Set local timezone
    try {
      final String localTz = DateTime.now().timeZoneName;
      // Try to find matching timezone, fallback to UTC
      final locations = tz.timeZoneDatabase.locations;
      if (locations.containsKey(localTz)) {
        tz.setLocalLocation(tz.getLocation(localTz));
      }
    } catch (_) {
      // Keep default UTC if timezone detection fails
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<bool> requestPermission() async {
    final androidImpl = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl != null) {
      // Request notification permission (Android 13+)
      await androidImpl.requestNotificationsPermission();
      // Request exact alarm permission (Android 12+)
      await androidImpl.requestExactAlarmsPermission();
    }

    // iOS
    final iosImpl = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await iosImpl?.requestPermissions(alert: true, badge: true, sound: true);

    // Check actual status after requesting
    return await hasPermission();
  }

  Future<bool> hasPermission() async {
    final androidImpl = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    // areNotificationsEnabled returns true on Android < 13 by default
    return await androidImpl?.areNotificationsEnabled() ?? true;
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    bool isRecurring = false,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'noor_schedules',
      'Schedule Reminders',
      channelDescription: 'Islamic schedule reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      color: Color(0xFF2E7D32),
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // Safe TZDateTime conversion — always use UTC offset instead of named timezone
    final tzTime = tz.TZDateTime(
      tz.local,
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    if (isRecurring) {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } else {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelMultipleNotifications(List<int> ids) async {
    for (final id in ids) {
      await _notifications.cancel(id);
    }
  }

  static int generateUniqueId(String title, DateTime time, {int? dayOffset}) {
    final baseHash = title.hashCode;
    final timeHash = time.millisecondsSinceEpoch ~/ 1000;
    final offset = dayOffset ?? 0;
    return (baseHash + timeHash + offset).abs() % 2147483647;
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'welcome_channel',
      'Welcome Messages',
      channelDescription: 'Welcome and informational notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      color: Color(0xFF2E7D32),
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

    await _notifications.show(
      id,
      title,
      body,
      details,
    );
  }
}
