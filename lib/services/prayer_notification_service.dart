import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/prayer_times_model.dart';
import 'notification_service.dart';

class PrayerNotificationService {
  static const int _fajrId = 100;
  static const int _dhuhrId = 101;
  static const int _asrId = 102;
  static const int _maghribId = 103;
  static const int _ishaId = 104;

  static Future<void> schedulePrayerNotifications(PrayerTimes times) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('prayer_notifications_enabled') ?? true)) return;

    await cancelAll();

    final prayers = [
      {'id': _fajrId, 'name': 'Fajr', 'time': times.fajr},
      {'id': _dhuhrId, 'name': 'Dhuhr', 'time': times.dhuhr},
      {'id': _asrId, 'name': 'Asr', 'time': times.asr},
      {'id': _maghribId, 'name': 'Maghrib', 'time': times.maghrib},
      {'id': _ishaId, 'name': 'Isha', 'time': times.isha},
    ];

    final now = DateTime.now();

    for (final prayer in prayers) {
      DateTime scheduledTime = _parseTime(prayer['time'] as String);
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      try {
        await NotificationService().schedulePrayerNotification(
          id: prayer['id'] as int,
          title: '🕌 ${prayer['name']} Prayer',
          body: 'It\'s time for ${prayer['name']} - الصلاة خير من النوم',
          scheduledTime: scheduledTime,
        );
        if (kDebugMode) print('✅ Scheduled ${prayer['name']} at $scheduledTime');
      } catch (e) {
        if (kDebugMode) print('❌ Failed to schedule ${prayer['name']}: $e');
      }
    }

    await prefs.setString('last_prayer_schedule_date', DateTime.now().toIso8601String());
  }

  static Future<bool> needsRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    final lastStr = prefs.getString('last_prayer_schedule_date');
    if (lastStr == null) return true;
    final last = DateTime.parse(lastStr);
    final now = DateTime.now();
    return now.day != last.day || now.month != last.month || now.year != last.year;
  }

  static Future<void> cancelAll() async {
    await NotificationService().cancelNotification(_fajrId);
    await NotificationService().cancelNotification(_dhuhrId);
    await NotificationService().cancelNotification(_asrId);
    await NotificationService().cancelNotification(_maghribId);
    await NotificationService().cancelNotification(_ishaId);
  }

  static DateTime _parseTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day,
        int.parse(parts[0]), int.parse(parts[1]));
  }
}
