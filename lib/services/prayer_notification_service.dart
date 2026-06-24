import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/prayer_times_model.dart';

class PrayerNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const _androidDetails = AndroidNotificationDetails(
    'prayer_times',
    'Prayer Times',
    channelDescription: 'Azan notifications for daily prayers',
    importance: Importance.max,
    priority: Priority.max,
    playSound: true,
  );

  static const _details = NotificationDetails(
    android: _androidDetails,
    iOS: DarwinNotificationDetails(),
  );

  static Future<void> schedulePrayerNotifications(PrayerTimes times) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('prayer_notifications_enabled') ?? true)) return;

    // Cancel only prayer IDs (0-4), not daily reminder (999)
    for (int i = 0; i < 5; i++) {
      await _notifications.cancel(i);
    }

    final prayers = [
      {'id': 0, 'name': 'Fajr', 'time': times.fajr},
      {'id': 1, 'name': 'Dhuhr', 'time': times.dhuhr},
      {'id': 2, 'name': 'Asr', 'time': times.asr},
      {'id': 3, 'name': 'Maghrib', 'time': times.maghrib},
      {'id': 4, 'name': 'Isha', 'time': times.isha},
    ];

    final now = DateTime.now();

    for (final prayer in prayers) {
      DateTime scheduledTime = _parseTime(prayer['time'] as String);

      // If time already passed today, schedule for tomorrow
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        prayer['id'] as int,
        '🕌 ${prayer['name']} Prayer',
        'It\'s time for ${prayer['name']} - الصلاة خير من النوم',
        tz.TZDateTime.from(scheduledTime, tz.local),
        _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> cancelAll() async {
    for (int i = 0; i < 5; i++) {
      await _notifications.cancel(i);
    }
  }

  static DateTime _parseTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day,
        int.parse(parts[0]), int.parse(parts[1]));
  }
}
