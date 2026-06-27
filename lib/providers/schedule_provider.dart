import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/schedule_model.dart';
import '../services/notification_service.dart';

class ScheduleProvider extends ChangeNotifier {
  List<Schedule> _schedules = [];
  final Map<int, List<int>> _scheduleNotificationIds = {};
  
  List<Schedule> get schedules => _schedules;
  
  ScheduleProvider() {
    _loadSchedules();
  }
  
  Future<void> _loadSchedules() async {
    final box = await Hive.openBox<Schedule>('schedules');
    _schedules = box.values.toList();
    notifyListeners();
  }
  
  Future<void> addSchedule(Schedule schedule, List<int> notificationIds) async {
    final box = await Hive.openBox<Schedule>('schedules');
    final index = await box.add(schedule);
    _schedules.add(schedule);
    _scheduleNotificationIds[index] = notificationIds;
    notifyListeners();
  }
  
  Future<void> deleteSchedule(int index) async {
    // Cancel all notifications for this schedule
    final notificationIds = _scheduleNotificationIds[index];
    if (notificationIds != null && notificationIds.isNotEmpty) {
      try {
        for (final id in notificationIds) {
          await NotificationService().cancelNotification(id);
        }
      } catch (e) {
        debugPrint('Error canceling notifications: $e');
      }
    }
    
    final box = await Hive.openBox<Schedule>('schedules');
    await box.deleteAt(index);
    _schedules.removeAt(index);
    _scheduleNotificationIds.remove(index);
    
    // Re-index notification IDs
    final updatedMap = <int, List<int>>{};
    _scheduleNotificationIds.forEach((key, value) {
      if (key > index) {
        updatedMap[key - 1] = value;
      } else {
        updatedMap[key] = value;
      }
    });
    _scheduleNotificationIds.clear();
    _scheduleNotificationIds.addAll(updatedMap);
    
    notifyListeners();
  }
  
  Future<void> toggleComplete(int index) async {
    _schedules[index].isCompleted = !_schedules[index].isCompleted;
    if (_schedules[index].isCompleted) {
      _schedules[index].completionCount++;
    }
    final box = await Hive.openBox<Schedule>('schedules');
    await box.putAt(index, _schedules[index]);
    notifyListeners();
  }
  
  Future<void> updateSchedule(int index, Schedule schedule, List<int> notificationIds) async {
    // Cancel old notifications
    final oldNotificationIds = _scheduleNotificationIds[index];
    if (oldNotificationIds != null && oldNotificationIds.isNotEmpty) {
      try {
        for (final id in oldNotificationIds) {
          await NotificationService().cancelNotification(id);
        }
      } catch (e) {
        debugPrint('Error canceling old notifications: $e');
      }
    }
    
    final box = await Hive.openBox<Schedule>('schedules');
    await box.putAt(index, schedule);
    _schedules[index] = schedule;
    _scheduleNotificationIds[index] = notificationIds;
    notifyListeners();
  }
  
  int get totalSchedules => _schedules.length;
  int get completedToday => _schedules.where((s) => s.isCompleted).length;
  int get totalCompletions => _schedules.fold(0, (sum, s) => sum + s.completionCount);
}
