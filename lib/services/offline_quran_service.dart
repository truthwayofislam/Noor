import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class OfflineQuranService {
  static Map<String, dynamic>? _quranData;
  static bool _isLoaded = false;

  /// Load Quran data once
  static Future<void> loadQuran() async {
    if (_isLoaded) return;
    
    try {
      final String jsonString = await rootBundle.loadString('assets/quran/quran_uthmani.json');
      _quranData = json.decode(jsonString);
      _isLoaded = true;
    } catch (e) {
      if (kDebugMode) print('Error loading Quran: $e');
    }
  }

  /// Get specific page (1-604)
  static List<Map<String, dynamic>> getPage(int pageNumber) {
    if (!_isLoaded || _quranData == null) return [];
    
    try {
      final surahs = _quranData!['data']['surahs'] as List;
      List<Map<String, dynamic>> pageAyahs = [];
      
      for (var surah in surahs) {
        final ayahs = surah['ayahs'] as List;
        for (var ayah in ayahs) {
          if (ayah['page'] == pageNumber) {
            pageAyahs.add({
              'text': ayah['text'],
              'surah': surah['number'],
              'ayah': ayah['numberInSurah'],
              'juz': ayah['juz'],
            });
          }
        }
      }
      
      return pageAyahs;
    } catch (e) {
      if (kDebugMode) print('Error getting page: $e');
      return [];
    }
  }

  /// Get Surah info
  static Map<String, dynamic>? getSurahInfo(int surahNumber) {
    if (!_isLoaded || _quranData == null) return null;
    
    try {
      final surahs = _quranData!['data']['surahs'] as List;
      final surah = surahs.firstWhere(
        (s) => s['number'] == surahNumber,
      );
      return {
        'number': surah['number'],
        'name': surah['name'],
        'englishName': surah['englishName'],
        'englishNameTranslation': surah['englishNameTranslation'],
        'numberOfAyahs': surah['ayahs'].length,
        'revelationType': surah['revelationType'],
      };
    } catch (e) {
      if (kDebugMode) print('Error getting surah info: $e');
      return null;
    }
  }

  /// Get all ayahs of a Surah
  static List<Map<String, dynamic>> getSurah(int surahNumber) {
    if (!_isLoaded || _quranData == null) return [];
    
    try {
      final surahs = _quranData!['data']['surahs'] as List;
      final surah = surahs.firstWhere(
        (s) => s['number'] == surahNumber,
      );
      final ayahs = surah['ayahs'] as List;
      return ayahs
          .map((ayah) => {
                'text': ayah['text'],
                'numberInSurah': ayah['numberInSurah'],
                'page': ayah['page'],
                'juz': ayah['juz'],
              })
          .toList();
    } catch (e) {
      if (kDebugMode) print('Error getting surah: $e');
      return [];
    }
  }

  /// Get page number for a Surah
  static int getPageForSurah(int surahNumber) {
    if (!_isLoaded || _quranData == null) return 1;
    
    try {
      final surahs = _quranData!['data']['surahs'] as List;
      final surah = surahs.firstWhere(
        (s) => s['number'] == surahNumber,
      );
      final ayahs = surah['ayahs'] as List;
      return ayahs.isNotEmpty ? ayahs[0]['page'] ?? 1 : 1;
    } catch (e) {
      if (kDebugMode) print('Error getting page for surah: $e');
      return 1;
    }
  }

  /// Check if data is loaded
  static bool get isLoaded => _isLoaded;
}
