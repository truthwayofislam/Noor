# 📱 Home Screen Widget Guide

## 🕌 Prayer Times Widget

Display prayer times directly on your Android home screen!

### ✨ Features
- Shows all 5 daily prayer times (Fajr, Dhuhr, Asr, Maghrib, Isha)
- Highlights next prayer
- Beautiful green gradient design
- Updates automatically
- Tap to open app

### 📲 How to Add Widget

**Android:**
1. Long press on home screen
2. Tap "Widgets"
3. Find "Noor" app widgets
4. Drag "Prayer Times" widget to home screen
5. Widget will auto-update when you open Prayer Times in app

### 🔄 Update Widget

Widget updates automatically when:
- You load prayer times in the app
- Location changes
- Every 30 minutes (background update)

### 🎨 Widget Design

**Size:** 4x3 cells (250dp × 180dp)
**Colors:**
- Background: Green gradient (#2E7D32 → #1B5E20)
- Text: White
- Next prayer: Gold (#FFD700)

### ⚙️ Technical Details

**Files:**
- Service: `lib/services/home_widget_service.dart`
- Layout: `android/app/src/main/res/layout/prayer_times_widget.xml`
- Provider: `android/app/src/main/kotlin/com/noor/app/PrayerTimesWidget.kt`
- Config: `android/app/src/main/res/xml/prayer_times_widget_info.xml`

**Dependencies:**
```yaml
home_widget: ^0.4.1
```

### 🔧 Troubleshooting

**Widget not showing prayer times?**
1. Open Noor app
2. Go to Prayer Times screen
3. Allow location permission
4. Wait for prayer times to load
5. Widget will update automatically

**Widget shows "---"?**
- Prayer times haven't been loaded yet
- Open app and refresh prayer times

### 📝 Developer Notes

Update widget manually:
```dart
await HomeWidgetService.updatePrayerTimesWidget(times, nextPrayer);
```

Widget updates are called in:
- `prayer_times_screen.dart` - when times load
- Automatically every 30 mins via Android

---

بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ
