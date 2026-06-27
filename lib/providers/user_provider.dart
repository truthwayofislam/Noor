import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class UserProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(user.toJson()));
  }

  Future<User?> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      return User.fromJson(json.decode(userData));
    }
    return null;
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  Future<bool> tryAutoLogin() async {
    // First try loading from local storage
    _currentUser = await _loadUserData();
    if (_currentUser != null) {
      notifyListeners();
    }
    
    // Then try to refresh from API
    try {
      final response = await _apiService.getProfile();
      _currentUser = User.fromJson(response);
      await _saveUserData(_currentUser!);
      notifyListeners();
      return true;
    } catch (e) {
      // If API fails but we have local data, still return true
      if (_currentUser != null) {
        return true;
      }
      await _apiService.clearToken();
      await _clearUserData();
      return false;
    }
  }
  
  Future<bool> register({
    required String email,
    required String password,
    required String username,
    required String country,
    required String level,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.register(
        email: email,
        password: password,
        username: username,
        country: country,
        level: level,
      );
      
      _currentUser = User.fromJson(response['user']);
      await _saveUserData(_currentUser!);
      
      // Send welcome notification
      await _sendWelcomeNotification(_currentUser!.username, _currentUser!.id);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );
      
      _currentUser = User.fromJson(response['user']);
      await _saveUserData(_currentUser!);
      
      // Check if first login and send welcome notification
      final prefs = await SharedPreferences.getInstance();
      final hasSeenWelcome = prefs.getBool('has_seen_welcome_${_currentUser!.id}') ?? false;
      if (!hasSeenWelcome) {
        await _sendWelcomeNotification(_currentUser!.username, _currentUser!.id);
        await prefs.setBool('has_seen_welcome_${_currentUser!.id}', true);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiService.getProfile();
      _currentUser = User.fromJson(response);
      await _saveUserData(_currentUser!);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updateProfile({
    String? username,
    String? country,
    String? level,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiService.updateProfile(
        username: username,
        country: country,
        level: level,
      );
      
      _currentUser = User.fromJson(response);
      await _saveUserData(_currentUser!);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> logActivity({
    required String activityType,
    required int points,
    Map<String, dynamic>? metadata,
  }) async {
    if (_currentUser == null) return;
    
    try {
      final response = await _apiService.logActivity(
        userId: _currentUser!.id,
        activityType: activityType,
        points: points,
        metadata: metadata,
      );
      
      // Update points locally immediately without waiting for full profile reload
      final newPoints = response['total_points'] as int? ?? (_currentUser!.points + points);
      _currentUser = User(
        id: _currentUser!.id,
        email: _currentUser!.email,
        username: _currentUser!.username,
        country: _currentUser!.country,
        level: _currentUser!.level,
        points: newPoints,
        streakDays: _currentUser!.streakDays,
        quranProgress: _currentUser!.quranProgress,
        prayersLogged: activityType == 'prayer_logged'
            ? _currentUser!.prayersLogged + 1
            : _currentUser!.prayersLogged,
        lessonsCompleted: activityType == 'lesson_completed'
            ? _currentUser!.lessonsCompleted + 1
            : _currentUser!.lessonsCompleted,
        avatar: _currentUser!.avatar,
        createdAt: _currentUser!.createdAt,
        updatedAt: DateTime.now(),
      );
      await _saveUserData(_currentUser!);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> logout() async {
    await _apiService.clearToken();
    await _clearUserData();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> _sendWelcomeNotification(String username, String userId) async {
    try {
      // Generate unique ID based on user ID
      final notificationId = 1000 + userId.hashCode.abs() % 9000; // Range: 1000-9999
      
      await NotificationService().showInstantNotification(
        id: notificationId,
        title: '🌙 Assalamu Alaikum, $username!',
        body: 'Welcome to Noor! May Allah bless your journey. Start by reading Quran, tracking prayers, and earning rewards. جزاك الله خيرا',
      );
    } catch (e) {
      // Silently fail if notification fails
    }
  }
}
