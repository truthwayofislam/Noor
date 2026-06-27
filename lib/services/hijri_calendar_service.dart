class HijriDate {
  final int day;
  final int month;
  final int year;

  HijriDate({required this.day, required this.month, required this.year});

  static const List<String> monthNamesArabic = [
    'مُحَرَّم', 'صَفَر', 'رَبِيعُ الأَوَّل', 'رَبِيعُ الثَّانِي',
    'جُمَادَى الأُولَى', 'جُمَادَى الآخِرَة', 'رَجَب', 'شَعْبَان',
    'رَمَضَان', 'شَوَّال', 'ذُو القَعْدَة', 'ذُو الحِجَّة',
  ];

  static const List<String> monthNamesEnglish = [
    'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani',
    'Jumada al-Ula', 'Jumada al-Akhira', 'Rajab', 'Sha\'ban',
    'Ramadan', 'Shawwal', 'Dhul Qa\'dah', 'Dhul Hijjah',
  ];

  String get monthArabic => monthNamesArabic[month - 1];
  String get monthEnglish => monthNamesEnglish[month - 1];

  /// Format: "15 رَمَضَان 1446"
  String get fullArabic => '$day $monthArabic $year';

  /// Format: "15 Ramadan 1446"
  String get fullEnglish => '$day $monthEnglish $year';

  /// Convert Gregorian date to Hijri using Umm al-Qura algorithm
  static HijriDate fromGregorian(DateTime date) {
    final jd = _gregorianToJulian(date.year, date.month, date.day);
    return _julianToHijri(jd);
  }

  static HijriDate today() => fromGregorian(DateTime.now());

  static int _gregorianToJulian(int year, int month, int day) {
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    final a = (year / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        b -
        1524;
  }

  static HijriDate _julianToHijri(int jd) {
    final l = jd - 1948440 + 10632;
    final n = ((l - 1) / 10631).floor();
    final l2 = l - 10631 * n + 354;
    final j = (((10985 - l2) / 5316).floor()) * (((50 * l2) / 17719).floor()) +
        ((l2 / 5670).floor()) * (((43 * l2) / 15238).floor());
    final l3 = l2 -
        (((30 - j) / 15).floor()) * (((17719 * j) / 50).floor()) -
        (((j) / 16).floor()) * (((15238 * j) / 43).floor()) +
        29;
    final month = ((24 * l3) / 709).floor();
    final day = l3 - ((709 * month) / 24).floor();
    final year = 30 * n + j - 30;

    return HijriDate(day: day, month: month, year: year);
  }

  /// Check if current Hijri month is Ramadan
  bool get isRamadan => month == 9;

  /// Check if today is a special Islamic day
  String? get specialDay {
    if (month == 1 && day == 1) return 'Islamic New Year - رأس السنة الهجرية';
    if (month == 1 && day == 10) return 'Day of Ashura - يوم عاشوراء';
    if (month == 3 && day == 12) return 'Mawlid al-Nabi - مولد النبي ﷺ';
    if (month == 7 && day == 27) return 'Isra\' and Mi\'raj - الإسراء والمعراج';
    if (month == 8 && day == 15) return 'Shab-e-Barat - شب برات';
    if (month == 9 && day == 1) return 'First day of Ramadan - أول رمضان';
    if (month == 9 && day == 27) return 'Laylat al-Qadr - ليلة القدر';
    if (month == 10 && day == 1) return 'Eid al-Fitr - عيد الفطر';
    if (month == 12 && day == 9) return 'Day of Arafah - يوم عرفة';
    if (month == 12 && day == 10) return 'Eid al-Adha - عيد الأضحى';
    return null;
  }
}
