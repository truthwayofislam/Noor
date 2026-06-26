import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import '../models/prayer_times_model.dart';

class PrayerTimesService {
  // Multiple API endpoints for fallback
  static const List<String> _apiEndpoints = [
    'https://api.aladhan.com/v1',
    'https://api.pray.zone/v2',
    'https://muslimsalat.com',
  ];

  Future<PrayerTimes?> getPrayerTimes({
    required double latitude,
    required double longitude,
  }) async {
    // Try Aladhan API first
    try {
      final url = '${_apiEndpoints[0]}/timings?latitude=$latitude&longitude=$longitude&method=2';
      if (kDebugMode) print('📡 Trying Aladhan API: $url');
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Aladhan API timeout');
        },
      );

      if (kDebugMode) print('📡 Aladhan Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (kDebugMode) print('✅ Aladhan API success');
        return PrayerTimes.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) print('❌ Aladhan API failed: $e');
    }

    // Fallback to PrayZone API
    try {
      final url = '${_apiEndpoints[1]}/times/today.json?latitude=$latitude&longitude=$longitude';
      if (kDebugMode) print('📡 Trying PrayZone API: $url');
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('PrayZone API timeout');
        },
      );

      if (kDebugMode) print('📡 PrayZone Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (kDebugMode) print('✅ PrayZone API success');
        return _parsePrayZone(data);
      }
    } catch (e) {
      if (kDebugMode) print('❌ PrayZone API failed: $e');
    }

    // Fallback to MuslimSalat API
    try {
      final url = '${_apiEndpoints[2]}/$latitude/$longitude/daily.json?key=free';
      if (kDebugMode) print('📡 Trying MuslimSalat API: $url');
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('MuslimSalat API timeout');
        },
      );

      if (kDebugMode) print('📡 MuslimSalat Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (kDebugMode) print('✅ MuslimSalat API success');
        return _parseMuslimSalat(data);
      }
    } catch (e) {
      if (kDebugMode) print('❌ MuslimSalat API failed: $e');
    }

    if (kDebugMode) print('❌ All APIs failed');
    return null;
  }

  PrayerTimes _parsePrayZone(Map<String, dynamic> json) {
    final results = json['results'];
    final datetime = results['datetime'];
    final times = datetime[0]['times'];
    
    return PrayerTimes(
      fajr: times['Fajr'],
      sunrise: times['Sunrise'],
      dhuhr: times['Dhuhr'],
      asr: times['Asr'],
      maghrib: times['Maghrib'],
      isha: times['Isha'],
      date: datetime[0]['date']['gregorian'],
    );
  }

  PrayerTimes _parseMuslimSalat(Map<String, dynamic> json) {
    final items = json['items'];
    final today = items[0];
    
    return PrayerTimes(
      fajr: today['fajr'],
      sunrise: today['shurooq'],
      dhuhr: today['dhuhr'],
      asr: today['asr'],
      maghrib: today['maghrib'],
      isha: today['isha'],
      date: today['date_for'],
    );
  }

  Future<Position?> getCurrentLocation() async {
    try {
      if (kDebugMode) print('🔍 Checking location service...');
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) print('❌ Location service disabled');
        return null;
      }
      if (kDebugMode) print('✅ Location service enabled');

      if (kDebugMode) print('🔍 Checking location permission...');
      LocationPermission permission = await Geolocator.checkPermission();
      if (kDebugMode) print('📍 Current permission: $permission');
      
      if (permission == LocationPermission.denied) {
        if (kDebugMode) print('⚠️ Permission denied, requesting...');
        permission = await Geolocator.requestPermission();
        if (kDebugMode) print('📍 Permission after request: $permission');
        
        if (permission == LocationPermission.denied) {
          if (kDebugMode) print('❌ Permission still denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) print('❌ Permission denied forever');
        return null;
      }

      if (kDebugMode) print('✅ Permission granted, getting location...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(const Duration(seconds: 10));
      
      if (kDebugMode) print('✅ Location obtained: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      if (kDebugMode) print('❌ Error getting location: $e');
      return null;
    }
  }

  String getNextPrayer(PrayerTimes times) {
    final now = DateTime.now();
    final prayers = {
      'Fajr': _parseTime(times.fajr),
      'Dhuhr': _parseTime(times.dhuhr),
      'Asr': _parseTime(times.asr),
      'Maghrib': _parseTime(times.maghrib),
      'Isha': _parseTime(times.isha),
    };

    for (var entry in prayers.entries) {
      if (entry.value.isAfter(now)) {
        return entry.key;
      }
    }
    return 'Fajr';
  }

  Duration getTimeUntilNext(PrayerTimes times) {
    final now = DateTime.now();
    final nextPrayer = getNextPrayer(times);
    
    DateTime nextTime;
    switch (nextPrayer) {
      case 'Fajr':
        nextTime = _parseTime(times.fajr);
        if (nextTime.isBefore(now)) {
          nextTime = nextTime.add(const Duration(days: 1));
        }
        break;
      case 'Dhuhr':
        nextTime = _parseTime(times.dhuhr);
        break;
      case 'Asr':
        nextTime = _parseTime(times.asr);
        break;
      case 'Maghrib':
        nextTime = _parseTime(times.maghrib);
        break;
      case 'Isha':
        nextTime = _parseTime(times.isha);
        break;
      default:
        nextTime = now;
    }

    return nextTime.difference(now);
  }

  DateTime _parseTime(String time) {
    // Remove timezone suffix e.g. "04:32 (PKT)" -> "04:32"
    final clean = time.split(' ')[0].trim();
    final parts = clean.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}
