# Notification System Documentation

## 🔔 Overview

Noor app uses three types of notifications:
1. **Schedule Notifications** (Custom routines)
2. **Prayer Time Notifications** (5 daily prayers)
3. **Daily Reminders** (Morning Islamic reminder)

---

## 📋 Notification ID System

### ID Ranges (No Conflicts)
- **100-104**: Prayer notifications (Fajr, Dhuhr, Asr, Maghrib, Isha)
- **105**: Midnight prayer refresh trigger
- **106**: Prayer refresh service
- **999**: Daily reminder (morning dua)
- **9999**: Test notification
- **Dynamic IDs**: Schedule notifications (hash-based unique IDs)

---

## 🕌 Prayer Notifications

### Features
✅ **Automatic Daily Refresh**: Prayer times update at midnight
✅ **Location Caching**: Saves location for auto-refresh
✅ **Offline Support**: Uses cached times if API fails
✅ **Smart Scheduling**: Skips past prayer times

### How It Works
1. User opens Prayer Times screen
2. App requests location permission
3. Fetches prayer times from Aladhan API
4. Caches times locally
5. Schedules 5 prayer notifications
6. Saves location for next day auto-refresh
7. At midnight, app auto-refreshes prayer times

### IDs Used
- Fajr: 100
- Dhuhr: 101
- Asr: 102
- Maghrib: 103
- Isha: 104
- Midnight Refresh: 105

---

## 📅 Schedule Notifications

### Features
✅ **Unique Hash-Based IDs**: No conflicts
✅ **Recurring Support**: Weekly schedules
✅ **Multiple Days**: Select Mon-Sun
✅ **Auto Cleanup**: Deletes notifications when schedule deleted
✅ **Permission Flow**: Requests permission before scheduling

### How It Works
1. User creates a schedule
2. App checks/requests notification permission
3. Generates unique ID using: `title.hashCode + time + dayOffset`
4. Schedules notification(s)
5. Stores notification IDs in provider
6. On delete/update, cancels old notifications first

### Recurring Logic
- User selects days (1=Mon, 7=Sun)
- App calculates next occurrence for each day
- Creates separate notification per day
- Each gets unique ID (base + day offset)
- Uses `DateTimeComponents.time` for daily repeat

---

## 🌙 Daily Reminder

### Features
✅ **Custom Time**: User sets preferred time
✅ **Random Duas**: Different dua each day
✅ **Daily Repeat**: Automatic daily trigger

### ID Used
- Daily Reminder: 999

---

## 🔧 Technical Details

### Unique ID Generation
```dart
static int generateUniqueId(String title, DateTime time, {int? dayOffset}) {
  final baseHash = title.hashCode;
  final timeHash = time.millisecondsSinceEpoch ~/ 1000;
  final offset = dayOffset ?? 0;
  return (baseHash + timeHash + offset).abs() % 2147483647;
}
```

### Caching System
- Prayer times cached with date stamp
- Auto-invalidates at midnight
- Fallback to cache if API fails
- Stored in SharedPreferences

### Permission Flow
1. Check if permission exists
2. If not, request permission
3. If denied, show warning and exit
4. If granted, schedule notification
5. Store notification IDs for cleanup

---

## 🐛 Fixed Issues

### ✅ Issue #1: Schedule ID Collision
**Problem**: Multiple schedules could have same notification ID
**Fix**: Hash-based unique IDs per schedule + day

### ✅ Issue #2: No Notification Cleanup
**Problem**: Deleted schedules left zombie notifications
**Fix**: Store IDs in provider, cancel on delete/update

### ✅ Issue #3: Prayer Times No Daily Reset
**Problem**: Prayer times scheduled once, never refreshed
**Fix**: Midnight auto-refresh + location caching

### ✅ Issue #4: No Offline Support
**Problem**: API failure = no prayer times
**Fix**: Local caching with date validation

### ✅ Issue #5: Recurring Schedule Wrong Logic
**Problem**: Weekday calculation incorrect
**Fix**: Proper modulo math with Flutter's weekday system

### ✅ Issue #6: Test Notification ID Conflict
**Problem**: Test used ID 999 (same as daily reminder)
**Fix**: Changed to 9999

### ✅ Issue #7: Missing Sound File
**Problem**: Referenced non-existent notification_sound
**Fix**: Removed custom sound, using default

---

## 🎯 Best Practices

### For Developers
1. **Always generate unique IDs** for notifications
2. **Store notification IDs** when creating schedules
3. **Cancel old notifications** before updating
4. **Check permissions** before scheduling
5. **Cache important data** (prayer times, location)
6. **Handle errors gracefully** with user feedback
7. **Use try-catch** for all notification operations

### For Users
1. Grant notification permission when prompted
2. Enable location for prayer times
3. Keep location services on for auto-refresh
4. Don't force-stop app (breaks background refresh)

---

## 📱 Permissions Required

### Android
- `POST_NOTIFICATIONS` (Android 13+)
- `SCHEDULE_EXACT_ALARM`
- `USE_EXACT_ALARM`
- `VIBRATE`
- `WAKE_LOCK`
- `ACCESS_FINE_LOCATION`

### iOS
- Notification permission
- Location permission

---

## 🔮 Future Enhancements

- [ ] WorkManager for guaranteed background refresh
- [ ] Multiple notification sounds
- [ ] Custom notification styles
- [ ] Notification history
- [ ] Silent mode respect
- [ ] Notification groups

---

## 🆘 Troubleshooting

### Notifications Not Working?
1. Check notification permission in system settings
2. Verify exact alarm permission (Android 12+)
3. Check battery optimization (should be disabled)
4. Ensure app not force-stopped
5. Check notification channels enabled

### Prayer Times Not Updating?
1. Verify location permission
2. Check internet connection
3. Open Prayer Times screen to force refresh
4. Check cached times in SharedPreferences

### Schedule Alarms Not Firing?
1. Verify notification permission
2. Check schedule time is in future
3. For recurring, verify days selected
4. Check system clock is accurate

---

**Last Updated**: December 2024
**Version**: 1.0.0
