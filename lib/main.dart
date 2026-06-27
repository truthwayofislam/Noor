import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'screens/splash_screen.dart';
import 'screens/quran/quran_reader_screen.dart';
import 'models/quran_model.dart';
import 'providers/theme_provider.dart';
import 'providers/quran_provider.dart';
import 'providers/tasbih_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/user_provider.dart';
import 'services/notification_service.dart';
import 'services/daily_reminder_service.dart';
import 'services/prayer_refresh_service.dart';
import 'services/islamic_reminders_service.dart';
import 'models/schedule_model.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Hive
    try {
      await Hive.initFlutter();
      Hive.registerAdapter(ScheduleAdapter());
    } catch (e) {
      debugPrint('Hive init error: $e');
    }
    
    // Initialize notifications
    try {
      final notificationService = NotificationService();
      await notificationService.init();

      AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      );
    } catch (e) {
      debugPrint('Notification init error: $e');
    }
    
    // Initialize services with error handling
    try {
      await DailyReminderService.init();
      await DailyReminderService.scheduleDailyReminder();
    } catch (e) {
      debugPrint('DailyReminder init error: $e');
    }

    try {
      await IslamicRemindersService.scheduleAll();
    } catch (e) {
      debugPrint('IslamicReminders init error: $e');
    }
    
    try {
      await PrayerRefreshService.init();
      await PrayerRefreshService.checkAndRefresh();
    } catch (e) {
      debugPrint('PrayerRefresh init error: $e');
    }
    
    runApp(const NoorApp());
  } catch (e, stackTrace) {
    debugPrint('Error in main: $e');
    debugPrint('StackTrace: $stackTrace');
    runApp(const ErrorApp());
  }
}

class NoorApp extends StatelessWidget {
  const NoorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => QuranProvider()),
        ChangeNotifierProvider(create: (_) => TasbihProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          if (themeProvider.isLoading) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: themeProvider.lightTheme,
              home: const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                ),
              ),
            );
          }
          
          return MaterialApp(
            title: 'Noor - نور',
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

class NotificationController {
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction action) async {
    final payload = action.payload;
    if (payload != null && payload['action'] == 'open_surah') {
      final surahNumber = int.tryParse(payload['surah'] ?? '') ?? 18;
      final context = navigatorKey.currentContext;
      if (context != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuranReaderScreen(
              surah: Surah(
                number: surahNumber,
                name: surahNumber == 18 ? 'سُورَةُ الْكَهْف' : 'Surah $surahNumber',
                englishName: surahNumber == 18 ? 'Al-Kahf' : 'Surah $surahNumber',
                englishNameTranslation: surahNumber == 18 ? 'The Cave' : '',
                numberOfAyahs: surahNumber == 18 ? 110 : 0,
                revelationType: 'Meccan',
              ),
            ),
          ),
        );
      }
    }
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
            ),
          ),
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Failed to start Noor',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please restart the app or clear app data',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
