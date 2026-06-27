import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class IslamicRemindersService {
  // ID ranges — 200-299 reserved for Islamic reminders
  static const int _morningAdhkarId = 200;
  static const int _eveningAdhkarId = 201;
  static const int _sleepDuaId = 202;
  static const int _mondayId = 210;
  static const int _tuesdayId = 211;
  static const int _wednesdayId = 212;
  static const int _thursdayId = 213;
  static const int _fridayKahfId = 214;
  static const int _fridayJumaId = 215;
  static const int _saturdayId = 216;
  static const int _sundayId = 217;

  // ── Daily Fixed Reminders ──────────────────────────────────────────────────

  static const _dailyReminders = [
    {
      'id': _morningAdhkarId,
      'title': '🌅 Morning Adhkar',
      'body': 'Start your day with morning supplications. Say: أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ',
      'hour': 6,
      'minute': 30,
    },
    {
      'id': _eveningAdhkarId,
      'title': '🌆 Evening Adhkar',
      'body': 'Time for evening supplications. Say: أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ',
      'hour': 17,
      'minute': 30,
    },
    {
      'id': _sleepDuaId,
      'title': '🌙 Bedtime Dua',
      'body': 'Before sleeping recite: بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا — Allahumma bismika amutu wa ahya',
      'hour': 22,
      'minute': 0,
    },
  ];

  // ── Weekly Day-Specific Reminders ─────────────────────────────────────────

  // weekday: 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun
  static const _weeklyReminders = [
    {
      'id': _mondayId,
      'weekday': 1,
      'title': '🤲 Monday — Durood Shareef',
      'body': 'Start the week by sending blessings on the Prophet ﷺ.\nAllahuma salli ala Muhammad wa ala ali Muhammad.',
      'hour': 8,
      'minute': 0,
    },
    {
      'id': _tuesdayId,
      'weekday': 2,
      'title': '🙏 Tuesday — Istighfar Day',
      'body': 'Make Istighfar abundantly today.\nاسْتَغْفِرُ اللَّهَ الْعَظِيمَ — Astaghfirullah al-Azeem',
      'hour': 8,
      'minute': 0,
    },
    {
      'id': _wednesdayId,
      'weekday': 3,
      'title': '💝 Wednesday — Give Sadqa',
      'body': 'Give charity today, even a little.\n"Sadqa extinguishes the wrath of the Lord." — Tirmidhi',
      'hour': 8,
      'minute': 0,
    },
    {
      'id': _thursdayId,
      'weekday': 4,
      'title': '✨ Thursday — Night of Juma begins',
      'body': 'Thursday night is the beginning of Juma. Increase Durood & Dua tonight.',
      'hour': 20,
      'minute': 0,
    },
    {
      'id': _fridayKahfId,
      'weekday': 5,
      'title': '📖 Juma Mubarak! Read Surah Kahf',
      'body': 'Today is Friday — recite Surah Al-Kahf.\n"Whoever reads Surah Kahf on Friday will have light between the two Fridays." — Al-Hakim',
      'hour': 7,
      'minute': 0,
    },
    {
      'id': _fridayJumaId,
      'weekday': 5,
      'title': '🕌 Juma Prayer Reminder',
      'body': 'Don\'t forget Juma prayer today! Go early and recite abundant Durood on the Prophet ﷺ.',
      'hour': 12,
      'minute': 0,
    },
    {
      'id': _saturdayId,
      'weekday': 6,
      'title': '📚 Saturday — Quran Time',
      'body': 'Dedicate time to Quran today.\n"The best of you are those who learn the Quran and teach it." — Bukhari',
      'hour': 9,
      'minute': 0,
    },
    {
      'id': _sundayId,
      'weekday': 7,
      'title': '❤️ Sunday — Silah Rehmi',
      'body': 'Call or visit your family today. Silah Rehmi brings barakah in rizq & life.',
      'hour': 10,
      'minute': 0,
    },
  ];

  static Future<void> scheduleAll() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('islamic_reminders_enabled') ?? true)) return;

    await cancelAll();

    // Schedule daily reminders
    for (final r in _dailyReminders) {
      await NotificationService().scheduleIslamicReminder(
        id: r['id'] as int,
        title: r['title'] as String,
        body: r['body'] as String,
        hour: r['hour'] as int,
        minute: r['minute'] as int,
      );
    }

    // Friday Surah Kahf — with payload to open surah 18
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _fridayKahfId,
        channelKey: 'islamic_reminders',
        title: '📖 Juma Mubarak! Read Surah Kahf',
        body: 'Today is Friday — recite Surah Al-Kahf. "Whoever reads Surah Kahf on Friday will have light between the two Fridays." — Al-Hakim',
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: false,
        payload: {'action': 'open_surah', 'surah': '18'},
      ),
      schedule: NotificationCalendar(
        weekday: 5,
        hour: 7,
        minute: 0,
        second: 0,
        repeats: true,
        allowWhileIdle: true,
        preciseAlarm: true,
      ),
    );

    // All other weekly reminders
    for (final r in _weeklyReminders) {
      if (r['id'] == _fridayKahfId) continue; // already scheduled above
      await NotificationService().scheduleIslamicReminder(
        id: r['id'] as int,
        title: r['title'] as String,
        body: r['body'] as String,
        hour: r['hour'] as int,
        minute: r['minute'] as int,
        weekday: r['weekday'] as int,
      );
    }

    await prefs.setBool('islamic_reminders_scheduled', true);
  }

  static Future<void> cancelAll() async {
    final ids = [
      _morningAdhkarId, _eveningAdhkarId, _sleepDuaId,
      _mondayId, _tuesdayId, _wednesdayId, _thursdayId,
      _fridayKahfId, _fridayJumaId, _saturdayId, _sundayId,
    ];
    await NotificationService().cancelMultipleNotifications(ids);
  }

  static Future<void> enable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('islamic_reminders_enabled', true);
    await scheduleAll();
  }

  static Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('islamic_reminders_enabled', false);
    await cancelAll();
  }

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('islamic_reminders_enabled') ?? true;
  }
}
