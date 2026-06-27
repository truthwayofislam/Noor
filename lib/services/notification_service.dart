import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const _scheduleChannel = 'noor_schedules';
  static const _prayerChannel = 'prayer_times';
  static const _reminderChannel = 'daily_reminder';
  static const _generalChannel = 'general';

  Future<void> init() async {
    await AwesomeNotifications().initialize(
      null, // null = default app icon
      [
        NotificationChannel(
          channelKey: _scheduleChannel,
          channelName: 'Schedule Reminders',
          channelDescription: 'Islamic schedule reminders',
          importance: NotificationImportance.High,
          defaultColor: const Color(0xFF2E7D32),
          ledColor: const Color(0xFF2E7D32),
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: _prayerChannel,
          channelName: 'Prayer Times',
          channelDescription: 'Azan notifications for daily prayers',
          importance: NotificationImportance.Max,
          defaultColor: const Color(0xFF2E7D32),
          ledColor: const Color(0xFF2E7D32),
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: _reminderChannel,
          channelName: 'Daily Reminders',
          channelDescription: 'Daily Islamic reminders',
          importance: NotificationImportance.High,
          defaultColor: const Color(0xFF2E7D32),
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: _generalChannel,
          channelName: 'General',
          channelDescription: 'General notifications',
          importance: NotificationImportance.High,
          defaultColor: const Color(0xFF2E7D32),
          playSound: true,
          enableVibration: true,
        ),
      ],
      debug: false,
    );
  }

  Future<bool> requestPermission() async {
    final allowed = await AwesomeNotifications().isNotificationAllowed();
    if (!allowed) {
      return await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    return true;
  }

  Future<bool> hasPermission() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }

  Future<void> ensureExactAlarmPermission() async {
    // awesome_notifications handles this internally
  }

  /// Schedule a one-time or recurring notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    bool isRecurring = false,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: _scheduleChannel,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
      ),
      schedule: isRecurring
          ? NotificationCalendar(
              hour: scheduledTime.hour,
              minute: scheduledTime.minute,
              second: 0,
              repeats: true,
              allowWhileIdle: true,
              preciseAlarm: true,
            )
          : NotificationCalendar.fromDate(
              date: scheduledTime,
              allowWhileIdle: true,
              preciseAlarm: true,
            ),
    );
  }

  /// Schedule prayer notification at exact time
  Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: _prayerChannel,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        category: NotificationCategory.Alarm,
      ),
      schedule: NotificationCalendar.fromDate(
        date: scheduledTime,
        allowWhileIdle: true,
        preciseAlarm: true,
      ),
    );
  }

  /// Schedule daily recurring reminder
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: _reminderChannel,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        repeats: true,
        allowWhileIdle: true,
        preciseAlarm: true,
      ),
    );
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: _generalChannel,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  Future<void> cancelMultipleNotifications(List<int> ids) async {
    for (final id in ids) {
      await AwesomeNotifications().cancel(id);
    }
  }

  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}
