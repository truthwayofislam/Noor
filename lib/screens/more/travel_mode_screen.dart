import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import '../../services/prayer_times_service.dart';
import '../../services/prayer_notification_service.dart';
import '../../services/prayer_refresh_service.dart';
import '../../models/prayer_times_model.dart';
import '../prayer/prayer_times_screen.dart';
import '../qibla/qibla_screen.dart';

class TravelModeScreen extends StatefulWidget {
  const TravelModeScreen({super.key});

  @override
  State<TravelModeScreen> createState() => _TravelModeScreenState();
}

class _TravelModeScreenState extends State<TravelModeScreen> {
  final PrayerTimesService _prayerService = PrayerTimesService();
  bool _isLoading = true;
  bool _travelModeActive = false;
  PrayerTimes? _prayerTimes;
  String? _locationInfo;
  String? _error;
  double? _lat, _lng;

  // Travel duas list
  final List<Map<String, String>> _travelDuas = [
    {
      'title': 'Dua Before Journey',
      'arabic': 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنقَلِبُونَ',
      'translation':
          'Glory to Him Who has subjected this to us, and we could not have subdued it. And to our Lord we will return.',
    },
    {
      'title': 'Dua When Entering a New Place',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَهَا وَخَيْرَ أَهْلِهَا وَأَعُوذُ بِكَ مِنْ شَرِّهَا وَشَرِّ أَهْلِهَا',
      'translation':
          'O Allah, I ask You for its goodness and the goodness of its people, and I seek refuge in You from its evil and the evil of its people.',
    },
    {
      'title': 'Dua for Safe Return',
      'arabic': 'آيِبُونَ تَائِبُونَ عَابِدُونَ لِرَبِّنَا حَامِدُونَ',
      'translation':
          'We return, repent, worship and praise our Lord.',
    },
    {
      'title': 'Dua When Boarding',
      'arabic': 'بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      'translation':
          'In the name of Allah, I place my trust in Allah, and there is no power or strength except with Allah.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadTravelData();
  }

  Future<void> _loadTravelData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final position = await _prayerService.getCurrentLocation();
      if (position == null) {
        setState(() {
          _error = 'Location access required for travel mode';
          _isLoading = false;
        });
        return;
      }

      _lat = position.latitude;
      _lng = position.longitude;

      final times = await _prayerService.getPrayerTimes(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // Get timezone offset as human-readable string
      final offset = DateTime.now().timeZoneOffset;
      final sign = offset.isNegative ? '-' : '+';
      final hours = offset.inHours.abs();
      final minutes = (offset.inMinutes.abs() % 60);
      final tzStr =
          'UTC$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

      setState(() {
        _prayerTimes = times;
        _locationInfo =
            '${position.latitude.toStringAsFixed(3)}°, ${position.longitude.toStringAsFixed(3)}° • $tzStr';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not load travel data';
        _isLoading = false;
      });
    }
  }

  Future<void> _activateTravelMode() async {
    if (_prayerTimes == null || _lat == null || _lng == null) return;

    await PrayerRefreshService.saveLocation(_lat!, _lng!);
    await PrayerNotificationService.schedulePrayerNotifications(_prayerTimes!);

    setState(() => _travelModeActive = true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Travel mode active! Prayer times updated for your current location.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Qasr calculation — distance from home
  double _getQasrDistance() => 80.0; // km threshold for qasr

  String _getDistanceInfo() {
    // Just show the threshold info
    return '80+ km from home → Qasr (shorten prayers)';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Mode - سفر'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTravelData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTravelHeader(),
                      const SizedBox(height: 16),
                      _buildQuickActions(context),
                      const SizedBox(height: 20),
                      _buildPrayerCard(context),
                      const SizedBox(height: 16),
                      _buildQasrCard(),
                      const SizedBox(height: 20),
                      _buildTravelDuas(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off_rounded,
                size: 72, color: Colors.orange),
            const SizedBox(height: 20),
            const Text('Location Required',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadTravelData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade700,
            Colors.indigo.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flight_takeoff, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Muslim Travel Mode',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _travelModeActive
                      ? Colors.green
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _travelModeActive ? 'Active' : 'Inactive',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (_locationInfo != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on,
                    color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Text(
                  _locationInfo!,
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  _travelModeActive ? null : _activateTravelMode,
              icon: Icon(_travelModeActive
                  ? Icons.check_circle
                  : Icons.my_location),
              label: Text(_travelModeActive
                  ? 'Prayer Times Updated'
                  : 'Update Prayer Times for This Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _travelModeActive
                    ? Colors.green.withOpacity(0.7)
                    : Colors.white,
                foregroundColor: _travelModeActive
                    ? Colors.white
                    : Colors.indigo.shade700,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.access_time,
            label: 'Prayer Times',
            color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const PrayerTimesScreen()),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.explore,
            label: 'Qibla',
            color: Colors.green,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QiblaScreen()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerCard(BuildContext context) {
    if (_prayerTimes == null) return const SizedBox.shrink();

    final prayers = [
      {'name': 'Fajr', 'time': _prayerTimes!.fajr, 'icon': Icons.wb_twilight},
      {'name': 'Dhuhr', 'time': _prayerTimes!.dhuhr, 'icon': Icons.wb_sunny},
      {'name': 'Asr', 'time': _prayerTimes!.asr, 'icon': Icons.wb_cloudy},
      {'name': 'Maghrib', 'time': _prayerTimes!.maghrib, 'icon': Icons.nights_stay},
      {'name': 'Isha', 'time': _prayerTimes!.isha, 'icon': Icons.bedtime},
    ];

    final nextPrayer = _prayerService.getNextPrayer(_prayerTimes!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prayer Times at Your Location',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: prayers.map((p) {
              final isNext = p['name'] == nextPrayer;
              return Container(
                decoration: BoxDecoration(
                  color: isNext
                      ? Theme.of(context).primaryColor.withOpacity(0.08)
                      : null,
                  borderRadius: prayers.indexOf(p) == 0
                      ? const BorderRadius.vertical(top: Radius.circular(16))
                      : prayers.indexOf(p) == prayers.length - 1
                          ? const BorderRadius.vertical(
                              bottom: Radius.circular(16))
                          : null,
                ),
                child: ListTile(
                  leading: Icon(
                    p['icon'] as IconData,
                    color: isNext
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                  title: Text(
                    p['name'] as String,
                    style: TextStyle(
                      fontWeight: isNext
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isNext
                          ? Theme.of(context).primaryColor
                          : null,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        p['time'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isNext
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                      ),
                      if (isNext) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Next',
                            style: TextStyle(
                                color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQasrCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text(
                'Qasr Prayer Rule',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getDistanceInfo(),
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            'While traveling you may shorten 4-rakat prayers (Dhuhr, Asr, Isha) to 2 rakats.',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelDuas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Travel Duas - سفر کی دعائیں',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ..._travelDuas.map((dua) => _DuaCard(dua: dua)),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DuaCard extends StatefulWidget {
  final Map<String, String> dua;
  const _DuaCard({required this.dua});

  @override
  State<_DuaCard> createState() => _DuaCardState();
}

class _DuaCardState extends State<_DuaCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.volunteer_activism,
                        color: Colors.indigo, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.dua['title']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.dua['arabic']!,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontSize: 20, height: 1.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.dua['translation']!,
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      height: 1.5),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
