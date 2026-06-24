import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/theme_provider.dart';
import '../../services/daily_reminder_service.dart';
import '../../services/notification_service.dart';
import '../../services/prayer_notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dailyReminderEnabled = false;
  bool _prayerNotifEnabled = true;
  bool _hasNotifPermission = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  String _quranEdition = 'ur.jalandhry';

  final Map<String, String> _quranEditions = {
    'ur.jalandhry': 'Urdu - Jalandhry',
    'ur.ahmedali': 'Urdu - Ahmed Ali',
    'en.sahih': 'English - Sahih',
    'en.pickthall': 'English - Pickthall',
    'ar.muyassar': 'Arabic - Muyassar',
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final hasPermission = await NotificationService().hasPermission();
    setState(() {
      _dailyReminderEnabled = prefs.getBool('daily_reminder_enabled') ?? false;
      _prayerNotifEnabled = prefs.getBool('prayer_notifications_enabled') ?? true;
      _hasNotifPermission = hasPermission;
      final hour = prefs.getInt('daily_reminder_hour') ?? 9;
      final minute = prefs.getInt('daily_reminder_minute') ?? 0;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
      _quranEdition = prefs.getString('quran_edition') ?? 'ur.jalandhry';
    });
  }

  Future<void> _saveQuranEdition(String edition) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quran_edition', edition);
    setState(() => _quranEdition = edition);
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all saved data except your login. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final onboarding = prefs.getBool('onboarding_complete');
      await prefs.clear();
      if (token != null) await prefs.setString('auth_token', token);
      if (onboarding != null) await prefs.setBool('onboarding_complete', onboarding);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache cleared!'), backgroundColor: Colors.green),
        );
        _loadSettings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings - ترتیبات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // --- APPEARANCE ---
          _sectionHeader('Appearance', Icons.palette_outlined),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode,
                      color: const Color(0xFF2E7D32)),
                  title: const Text('Dark Mode'),
                  subtitle: Text(isDark ? 'Dark theme active' : 'Light theme active'),
                  value: isDark,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --- QURAN ---
          _sectionHeader('Quran', Icons.menu_book_outlined),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.translate, color: Color(0xFF2E7D32)),
                  title: const Text('Translation Language'),
                  subtitle: Text(_quranEditions[_quranEdition] ?? _quranEdition),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showEditionPicker(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --- NOTIFICATIONS ---
          _sectionHeader('Notifications', Icons.notifications_outlined),
          Card(
            child: Column(
              children: [
                if (!_hasNotifPermission) ...[
                  ListTile(
                    leading: const Icon(Icons.warning_amber, color: Colors.orange),
                    title: const Text('Notifications Disabled'),
                    subtitle: const Text('Tap to enable notification permission'),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        await NotificationService().init();
                        await _loadSettings();
                      },
                      child: const Text('Enable'),
                    ),
                  ),
                  const Divider(height: 1),
                ],

                // Prayer notifications
                SwitchListTile(
                  secondary: const Icon(Icons.mosque, color: Color(0xFF2E7D32)),
                  title: const Text('Prayer Time Alerts'),
                  subtitle: const Text('Get notified at each prayer time'),
                  value: _prayerNotifEnabled,
                  onChanged: (val) async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('prayer_notifications_enabled', val);
                    setState(() => _prayerNotifEnabled = val);
                    if (!val) await PrayerNotificationService.cancelAll();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(val ? 'Prayer alerts enabled!' : 'Prayer alerts disabled'),
                        ),
                      );
                    }
                  },
                ),

                const Divider(height: 1),

                // Daily reminder
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active, color: Color(0xFF2E7D32)),
                  title: const Text('Daily Islamic Reminder'),
                  subtitle: const Text('Daily dua reminder notification'),
                  value: _dailyReminderEnabled,
                  onChanged: (val) async {
                    setState(() => _dailyReminderEnabled = val);
                    if (val) {
                      await DailyReminderService.enableReminder(
                          _reminderTime.hour, _reminderTime.minute);
                    } else {
                      await DailyReminderService.disableReminder();
                    }
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(val ? 'Reminder enabled!' : 'Reminder disabled')),
                      );
                    }
                  },
                ),

                if (_dailyReminderEnabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.access_time, color: Color(0xFF2E7D32)),
                    title: const Text('Reminder Time'),
                    subtitle: Text(_reminderTime.format(context)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _reminderTime,
                      );
                      if (time != null) {
                        setState(() => _reminderTime = time);
                        await DailyReminderService.enableReminder(time.hour, time.minute);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Reminder set to ${time.format(context)}')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --- DATA ---
          _sectionHeader('Data', Icons.storage_outlined),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_sweep, color: Colors.orange),
                  title: const Text('Clear Cache'),
                  subtitle: const Text('Clear saved scroll positions & temp data'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _clearCache,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --- ABOUT ---
          _sectionHeader('About', Icons.info_outlined),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.mosque, color: Color(0xFF2E7D32)),
                  title: const Text('Noor - نور'),
                  subtitle: const Text('Islamic Companion App'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('v1.0.0',
                        style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.api, color: Color(0xFF2E7D32)),
                  title: Text('Quran API'),
                  subtitle: Text('AlQuran Cloud - api.alquran.cloud'),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.schedule, color: Color(0xFF2E7D32)),
                  title: Text('Prayer Times API'),
                  subtitle: Text('Aladhan - api.aladhan.com'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Center(
            child: Text(
              'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditionPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Translation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._quranEditions.entries.map((e) => ListTile(
                  title: Text(e.value),
                  leading: Radio<String>(
                    value: e.key,
                    groupValue: _quranEdition,
                    activeColor: const Color(0xFF2E7D32),
                    onChanged: (val) {
                      _saveQuranEdition(val!);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Translation changed to ${e.value}')),
                      );
                    },
                  ),
                  trailing: _quranEdition == e.key
                      ? const Icon(Icons.check_circle, color: Color(0xFF2E7D32))
                      : null,
                  onTap: () {
                    _saveQuranEdition(e.key);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
