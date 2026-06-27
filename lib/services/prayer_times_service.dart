import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import '../models/prayer_times_model.dart';

class PrayerTimesService {

  Future<PrayerTimes?> getPrayerTimes({
    required double latitude,
    required double longitude,
  }) async {
    if (kDebugMode) print('🌍 Lat: $latitude, Lng: $longitude');
    
    // Try Aladhan API
    try {
      final url = 'https://api.aladhan.com/v1/timings?latitude=$latitude&longitude=$longitude&method=2';
      if (kDebugMode) print('📡 API: $url');
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );

      if (kDebugMode) print('📡 Status: ${response.statusCode}');
      if (kDebugMode) print('📡 Body length: ${response.body.length}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (kDebugMode) print('✅ JSON parsed');
        if (kDebugMode) print('📊 Data keys: ${data.keys}');
        
        final times = PrayerTimes.fromJson(data);
        if (kDebugMode) print('✅ Prayer times: Fajr=${times.fajr}, Dhuhr=${times.dhuhr}, Asr=${times.asr}');
        return times;
      } else {
        if (kDebugMode) print('❌ Bad status code: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) print('❌ API Error: $e');
      if (kDebugMode) print('❌ StackTrace: $stackTrace');
    }

    if (kDebugMode) print('❌ API failed');
    return null;
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
