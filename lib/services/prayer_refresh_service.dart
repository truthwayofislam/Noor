import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'notification_service.dart';
import 'prayer_times_service.dart';
import 'prayer_notification_service.dart';

/// Service to handle automatic daily prayer times refresh
class PrayerRefreshService {
  static FlutterLocalNotificationsPlugin get _notifications =>
      NotificationService().plugin;

  static const int _refreshTriggerId = 106;

  /// Initialize the service and schedule daily refresh
  static Future<void> init() async {
    await _scheduleDailyRefreshTrigger();
  }

  /// Schedule a silent notification at midnight to trigger app refresh
  static Future<void> _scheduleDailyRefreshTrigger() async {
    try {
      final now = DateTime.now();
      var midnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 5); // 12:00:05 AM

      const androidDetails = AndroidNotificationDetails(
        'prayer_refresh',
        'Prayer Times Refresh',
        channelDescription: 'Silent notifications to refresh prayer times',
        importance: Importance.low,
        priority: Priority.low,
        playSound: false,
        enableVibration: false,
        showWhen: false,
        ongoing: false,
        autoCancel: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: false,
          presentBadge: false,
          presentSound: false,
        ),
      );

      await _notifications.zonedSchedule(
        _refreshTriggerId,
        '🌙 Prayer Times',
        'Updating for new day...',
        tz.TZDateTime.from(midnight, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      if (kDebugMode) print('✅ Scheduled daily prayer refresh trigger at midnight');
    } catch (e) {
      if (kDebugMode) print('❌ Failed to schedule refresh trigger: $e');
    }
  }

  /// Check if prayer times need to be refreshed and refresh if needed
  static Future<void> checkAndRefresh() async {
    try {
      final needsRefresh = await PrayerNotificationService.needsRefresh();
      
      if (needsRefresh) {
        if (kDebugMode) print('🔄 Refreshing prayer times for new day...');
        
        // Get last known location
        final prefs = await SharedPreferences.getInstance();
        final lat = prefs.getDouble('last_location_lat');
        final lng = prefs.getDouble('last_location_lng');
        
        if (lat != null && lng != null) {
          final service = PrayerTimesService();
          final times = await service.getPrayerTimes(
            latitude: lat,
            longitude: lng,
          );
          
          if (times != null) {
            await PrayerNotificationService.schedulePrayerNotifications(times);
            if (kDebugMode) print('✅ Prayer times refreshed successfully');
          }
        }
        
        // Reschedule next day's trigger
        await _scheduleDailyRefreshTrigger();
      }
    } catch (e) {
      if (kDebugMode) print('❌ Failed to refresh prayer times: $e');
    }
  }

  /// Save location for automatic refresh
  static Future<void> saveLocation(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('last_location_lat', lat);
    await prefs.setDouble('last_location_lng', lng);
    if (kDebugMode) print('✅ Location saved for auto-refresh');
  }

  /// Cancel refresh trigger
  static Future<void> cancel() async {
    await _notifications.cancel(_refreshTriggerId);
  }
}
