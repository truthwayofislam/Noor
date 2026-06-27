import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class DailyReminderService {
  static const int _notifId = 999;

  static const List<String> _duas = [
    'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً',
    'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ',
    'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
    'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ سُبْحَانَ اللَّهِ الْعَظِيمِ',
    'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
  ];

  static Future<void> init() async {
    // Handled by NotificationService
  }

  static Future<void> scheduleDailyReminder() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('daily_reminder_enabled') ?? false)) return;

    final hour = prefs.getInt('daily_reminder_hour') ?? 9;
    final minute = prefs.getInt('daily_reminder_minute') ?? 0;
    final dua = _duas[Random().nextInt(_duas.length)];

    await NotificationService().cancelNotification(_notifId);
    await NotificationService().scheduleDailyReminder(
      id: _notifId,
      title: '🌙 Daily Islamic Reminder',
      body: dua,
      hour: hour,
      minute: minute,
    );
  }

  static Future<void> enableReminder(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_reminder_enabled', true);
    await prefs.setInt('daily_reminder_hour', hour);
    await prefs.setInt('daily_reminder_minute', minute);
    await scheduleDailyReminder();
  }

  static Future<void> disableReminder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_reminder_enabled', false);
    await NotificationService().cancelNotification(_notifId);
  }
}
