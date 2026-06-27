import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:convert';
import '../../models/prayer_times_model.dart';
import '../../services/prayer_times_service.dart';
import '../../services/prayer_notification_service.dart';
import '../../services/prayer_refresh_service.dart';
import '../../services/home_widget_service.dart';
import '../../providers/user_provider.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final PrayerTimesService _service = PrayerTimesService();
  PrayerTimes? _prayerTimes;
  bool _isLoading = true;
  Timer? _timer;
  Duration _timeUntilNext = Duration.zero;
  String _nextPrayer = '';
  List<PrayerLog> _todayLogs = [];

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
    _loadTodayLogs();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadPrayerTimes() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      // First try cached prayer times without needing location
      final cached = await _service.getCachedPrayerTimes();
      if (cached != null && mounted) {
        setState(() {
          _prayerTimes = cached;
          _nextPrayer = _service.getNextPrayer(cached);
          _timeUntilNext = _service.getTimeUntilNext(cached);
          _isLoading = false;
        });
        return;
      }

      final position = await _service.getCurrentLocation();

      if (position == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      
      if (kDebugMode) print('✅ Location: ${position.latitude}, ${position.longitude}');
      if (kDebugMode) print('🔍 Fetching prayer times...');
      
      final times = await _service.getPrayerTimes(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      
      if (times != null) {
        if (kDebugMode) print('✅ Prayer times received');
        
        // Save location for automatic refresh
        await PrayerRefreshService.saveLocation(
          position.latitude,
          position.longitude,
        );
        
        await PrayerNotificationService.schedulePrayerNotifications(times);
        
        // Update home widget
        final nextPrayer = _service.getNextPrayer(times);
        await HomeWidgetService.updatePrayerTimesWidget(times, nextPrayer);
        
        if (mounted) {
          setState(() {
            _prayerTimes = times;
            _nextPrayer = nextPrayer;
            _timeUntilNext = _service.getTimeUntilNext(times);
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Prayer times updated successfully'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (kDebugMode) print('❌ Prayer times API returned null');
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.cloud_off, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Network error. Please check internet connection.'),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: _loadPrayerTimes,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Error: ${_getErrorMessage(e)}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadPrayerTimes,
            ),
          ),
        );
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else if (errorStr.contains('socket') || errorStr.contains('network')) {
      return 'Network error. Check your internet connection.';
    } else if (errorStr.contains('location')) {
      return 'Location error. Enable location services.';
    }
    return 'Something went wrong. Please try again.';
  }

  void _updateCountdown() {
    if (_prayerTimes != null) {
      setState(() {
        _timeUntilNext = _service.getTimeUntilNext(_prayerTimes!);
        _nextPrayer = _service.getNextPrayer(_prayerTimes!);
      });
    }
  }

  Future<void> _loadTodayLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final logsJson = prefs.getString('prayer_logs_$today');
    
    if (logsJson != null) {
      final List<dynamic> decoded = json.decode(logsJson);
      setState(() {
        _todayLogs = decoded.map((e) => PrayerLog.fromJson(e)).toList();
      });
    }
  }

  Future<void> _logPrayer(String prayer) async {
    final log = PrayerLog(
      prayer: prayer,
      timestamp: DateTime.now(),
      onTime: true,
    );
    
    _todayLogs.add(log);
    
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString(
      'prayer_logs_$today',
      json.encode(_todayLogs.map((e) => e.toJson()).toList()),
    );
    
    setState(() {});
    
    if (mounted) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.isAuthenticated) {
        await userProvider.logActivity(
          activityType: 'prayer_logged',
          points: 5,
          metadata: {'prayer': prayer, 'time': DateTime.now().toIso8601String()},
        );
      }
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$prayer logged! +5 points'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  bool _isPrayerLogged(String prayer) {
    return _todayLogs.any((log) => log.prayer == prayer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Times'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPrayerTimes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _prayerTimes == null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _loadPrayerTimes,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildNextPrayerCard(),
                        const SizedBox(height: 24),
                        _buildPrayersList(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_rounded,
                size: 60,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Location Access Required',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'To show accurate prayer times for your location, we need access to your device location.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _loadPrayerTimes,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    side: const BorderSide(color: Color(0xFF2E7D32)),
                    foregroundColor: const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Geolocator.openLocationSettings();
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Settings'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    backgroundColor: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your location is only used to calculate prayer times and is never stored or shared.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextPrayerCard() {
    final hours = _timeUntilNext.inHours;
    final minutes = _timeUntilNext.inMinutes % 60;
    final seconds = _timeUntilNext.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Next Prayer',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _nextPrayer,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TimeBox(value: hours, label: 'Hours'),
              const SizedBox(width: 8),
              const Text(':', style: TextStyle(color: Colors.white, fontSize: 24)),
              const SizedBox(width: 8),
              _TimeBox(value: minutes, label: 'Min'),
              const SizedBox(width: 8),
              const Text(':', style: TextStyle(color: Colors.white, fontSize: 24)),
              const SizedBox(width: 8),
              _TimeBox(value: seconds, label: 'Sec'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayersList() {
    final prayers = [
      {'name': 'Fajr', 'time': _prayerTimes!.fajr, 'icon': Icons.wb_twilight},
      {'name': 'Sunrise', 'time': _prayerTimes!.sunrise, 'icon': Icons.wb_sunny, 'noLog': true},
      {'name': 'Dhuhr', 'time': _prayerTimes!.dhuhr, 'icon': Icons.wb_sunny},
      {'name': 'Asr', 'time': _prayerTimes!.asr, 'icon': Icons.wb_cloudy},
      {'name': 'Maghrib', 'time': _prayerTimes!.maghrib, 'icon': Icons.nights_stay},
      {'name': 'Isha', 'time': _prayerTimes!.isha, 'icon': Icons.bedtime},
    ];

    return Column(
      children: prayers.map((prayer) {
        final isLogged = _isPrayerLogged(prayer['name'] as String);
        final noLog = prayer['noLog'] == true;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isLogged ? Colors.green.withOpacity(0.2) : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                prayer['icon'] as IconData,
                color: isLogged ? Colors.green : Colors.grey[700],
              ),
            ),
            title: Text(
              prayer['name'] as String,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(prayer['time'] as String),
            trailing: noLog
                ? null
                : isLogged
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        color: const Color(0xFF2E7D32),
                        onPressed: () => _logPrayer(prayer['name'] as String),
                      ),
          ),
        );
      }).toList(),
    );
  }
}

class _TimeBox extends StatelessWidget {
  final int value;
  final String label;

  const _TimeBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
