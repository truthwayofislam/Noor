import 'dart:convert';
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
      print('Error loading Quran: $e');
    }
  }

  /// Get specific page (1-604)
  static List<Map<String, dynamic>> getPage(int pageNumber) {
    if (!_isLoaded || _quranData == null) return [];
    
    try {
      final ayahs = _quranData!['data']['ayahs'] as List;
      return ayahs
          .where((ayah) => ayah['page'] == pageNumber)
          .map((ayah) => {
                'text': ayah['text'],
                'surah': ayah['surah']['number'],
                'ayah': ayah['numberInSurah'],
                'juz': ayah['juz'],
              })
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get Surah info
  static Map<String, dynamic>? getSurahInfo(int surahNumber) {
    if (!_isLoaded || _quranData == null) return null;
    
    try {
      final ayahs = _quranData!['data']['ayahs'] as List;
      final firstAyah = ayahs.firstWhere(
        (ayah) => ayah['surah']['number'] == surahNumber,
      );
      return {
        'number': firstAyah['surah']['number'],
        'name': firstAyah['surah']['name'],
        'englishName': firstAyah['surah']['englishName'],
        'englishNameTranslation': firstAyah['surah']['englishNameTranslation'],
        'numberOfAyahs': firstAyah['surah']['numberOfAyahs'],
        'revelationType': firstAyah['surah']['revelationType'],
      };
    } catch (e) {
      return null;
    }
  }

  /// Get all ayahs of a Surah
  static List<Map<String, dynamic>> getSurah(int surahNumber) {
    if (!_isLoaded || _quranData == null) return [];
    
    try {
      final ayahs = _quranData!['data']['ayahs'] as List;
      return ayahs
          .where((ayah) => ayah['surah']['number'] == surahNumber)
          .map((ayah) => {
                'text': ayah['text'],
                'numberInSurah': ayah['numberInSurah'],
                'page': ayah['page'],
                'juz': ayah['juz'],
              })
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get page number for a Surah
  static int getPageForSurah(int surahNumber) {
    if (!_isLoaded || _quranData == null) return 1;
    
    try {
      final ayahs = _quranData!['data']['ayahs'] as List;
      final firstAyah = ayahs.firstWhere(
        (ayah) => ayah['surah']['number'] == surahNumber,
      );
      return firstAyah['page'] ?? 1;
    } catch (e) {
      return 1;
    }
  }

  /// Check if data is loaded
  static bool get isLoaded => _isLoaded;
}
