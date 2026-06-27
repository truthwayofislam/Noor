import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
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
    enableVibration: true,
    enableLights: true,
  );

  static const _details = NotificationDetails(
    android: _androidDetails,
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  // Prayer notification IDs: 100-104 for prayers, 105 for midnight refresh
  static const int _fajrId = 100;
  static const int _dhuhrId = 101;
  static const int _asrId = 102;
  static const int _maghribId = 103;
  static const int _ishaId = 104;
  static const int _midnightRefreshId = 105;

  static Future<void> schedulePrayerNotifications(PrayerTimes times) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('prayer_notifications_enabled') ?? true)) return;

    // Cancel all prayer notifications
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

      // If time already passed today, schedule for tomorrow
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      try {
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
        
        if (kDebugMode) print('✅ Scheduled ${prayer['name']} at $scheduledTime');
      } catch (e) {
        if (kDebugMode) print('❌ Failed to schedule ${prayer['name']}: $e');
      }
    }

    // Schedule midnight refresh notification (this will trigger daily reset)
    await _scheduleMidnightRefresh();
    
    // Save last scheduled date
    await prefs.setString('last_prayer_schedule_date', DateTime.now().toIso8601String());
  }

  static Future<void> _scheduleMidnightRefresh() async {
    final now = DateTime.now();
    var midnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 1); // 12:00:01 AM

    try {
      await _notifications.zonedSchedule(
        _midnightRefreshId,
        '🌙 Prayer Times Updated',
        'Prayer times for today have been refreshed',
        tz.TZDateTime.from(midnight, tz.local),
        _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      
      if (kDebugMode) print('✅ Scheduled midnight refresh at $midnight');
    } catch (e) {
      if (kDebugMode) print('❌ Failed to schedule midnight refresh: $e');
    }
  }

  static Future<bool> needsRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    final lastScheduledStr = prefs.getString('last_prayer_schedule_date');
    
    if (lastScheduledStr == null) return true;
    
    final lastScheduled = DateTime.parse(lastScheduledStr);
    final now = DateTime.now();
    
    // Check if it's a new day
    return now.day != lastScheduled.day || 
           now.month != lastScheduled.month || 
           now.year != lastScheduled.year;
  }

  static Future<void> cancelAll() async {
    await _notifications.cancel(_fajrId);
    await _notifications.cancel(_dhuhrId);
    await _notifications.cancel(_asrId);
    await _notifications.cancel(_maghribId);
    await _notifications.cancel(_ishaId);
    await _notifications.cancel(_midnightRefreshId);
  }

  static DateTime _parseTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day,
        int.parse(parts[0]), int.parse(parts[1]));
  }
}
