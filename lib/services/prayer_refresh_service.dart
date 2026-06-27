import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'prayer_times_service.dart';
import 'prayer_notification_service.dart';

class PrayerRefreshService {
  static Future<void> init() async {
    await checkAndRefresh();
  }

  static Future<void> checkAndRefresh() async {
    try {
      final needsRefresh = await PrayerNotificationService.needsRefresh();
      if (!needsRefresh) return;

      if (kDebugMode) print('🔄 Refreshing prayer times for new day...');

      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble('last_location_lat');
      final lng = prefs.getDouble('last_location_lng');

      if (lat != null && lng != null) {
        final service = PrayerTimesService();
        // Force fresh fetch by clearing cache
        await prefs.remove('cached_prayer_times');
        final times = await service.getPrayerTimes(latitude: lat, longitude: lng);
        if (times != null) {
          await PrayerNotificationService.schedulePrayerNotifications(times);
          if (kDebugMode) print('✅ Prayer times refreshed');
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ Failed to refresh prayer times: $e');
    }
  }

  static Future<void> saveLocation(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('last_location_lat', lat);
    await prefs.setDouble('last_location_lng', lng);
  }
}
