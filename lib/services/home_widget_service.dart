import 'package:home_widget/home_widget.dart';
import 'package:flutter/foundation.dart';
import '../models/prayer_times_model.dart';

class HomeWidgetService {
  static Future<void> updatePrayerTimesWidget(PrayerTimes times, String nextPrayer) async {
    try {
      // Save data for widget
      await HomeWidget.saveWidgetData<String>('fajr', times.fajr);
      await HomeWidget.saveWidgetData<String>('dhuhr', times.dhuhr);
      await HomeWidget.saveWidgetData<String>('asr', times.asr);
      await HomeWidget.saveWidgetData<String>('maghrib', times.maghrib);
      await HomeWidget.saveWidgetData<String>('isha', times.isha);
      await HomeWidget.saveWidgetData<String>('next_prayer', nextPrayer);
      await HomeWidget.saveWidgetData<String>('date', times.date);
      
      // Update widget
      await HomeWidget.updateWidget(
        androidName: 'PrayerTimesWidget',
        iOSName: 'PrayerTimesWidget',
      );
      
      if (kDebugMode) print('✅ Prayer times widget updated');
    } catch (e) {
      if (kDebugMode) print('❌ Widget update failed: $e');
    }
  }

  static Future<void> updateDailyQuoteWidget(String quote, String author) async {
    try {
      await HomeWidget.saveWidgetData<String>('quote', quote);
      await HomeWidget.saveWidgetData<String>('author', author);
      
      await HomeWidget.updateWidget(
        androidName: 'QuoteWidget',
        iOSName: 'QuoteWidget',
      );
      
      if (kDebugMode) print('✅ Quote widget updated');
    } catch (e) {
      if (kDebugMode) print('❌ Quote widget update failed: $e');
    }
  }

  static Future<void> registerInteractivity() async {
    try {
      await HomeWidget.registerInteractivityCallback(
        _backgroundCallback,
      );
      if (kDebugMode) print('✅ Widget interactivity registered');
    } catch (e) {
      if (kDebugMode) print('❌ Widget interactivity registration failed: $e');
    }
  }
}

@pragma('vm:entry-point')
void _backgroundCallback(Uri? uri) {
  if (uri != null) {
    // Handle widget tap - open specific screen
    // This is called when user taps widget
  }
}
