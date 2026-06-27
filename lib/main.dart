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
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(ScheduleAdapter());
  
  final notificationService = NotificationService();
  await notificationService.init();

  // Set notification listeners
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: NotificationController.onActionReceivedMethod,
  );
  
  await DailyReminderService.init();
  await DailyReminderService.scheduleDailyReminder();

  // Schedule Islamic daily & weekly reminders
  await IslamicRemindersService.scheduleAll();
  
  // Initialize prayer refresh service
  await PrayerRefreshService.init();
  
  // Check if prayer times need refresh on app start
  await PrayerRefreshService.checkAndRefresh();
  
  runApp(const NoorApp());
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
