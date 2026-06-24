class PrayerTimes {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String date;

  PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    final timings = json['data']['timings'];
    // Strip timezone suffix e.g. "04:32 (PKT)" -> "04:32"
    String clean(String t) => t.split(' ')[0].trim();
    return PrayerTimes(
      fajr: clean(timings['Fajr']),
      sunrise: clean(timings['Sunrise']),
      dhuhr: clean(timings['Dhuhr']),
      asr: clean(timings['Asr']),
      maghrib: clean(timings['Maghrib']),
      isha: clean(timings['Isha']),
      date: json['data']['date']['readable'],
    );
  }
}

class PrayerLog {
  final String prayer;
  final DateTime timestamp;
  final bool onTime;

  PrayerLog({
    required this.prayer,
    required this.timestamp,
    required this.onTime,
  });

  Map<String, dynamic> toJson() => {
    'prayer': prayer,
    'timestamp': timestamp.toIso8601String(),
    'onTime': onTime,
  };

  factory PrayerLog.fromJson(Map<String, dynamic> json) => PrayerLog(
    prayer: json['prayer'],
    timestamp: DateTime.parse(json['timestamp']),
    onTime: json['onTime'],
  );
}
