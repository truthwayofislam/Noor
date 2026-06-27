import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  double? _qiblaAngle; // angle from North to Qibla
  bool _isLoading = true;
  String? _error;
  String? _coords;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _getLocationAndCalculate();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _getLocationAndCalculate() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services disabled');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }

      // Try last known first
      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(const Duration(seconds: 30));

      final qibla = _calculateQibla(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          _qiblaAngle = qibla;
          _coords =
              '${position!.latitude.toStringAsFixed(3)}°, ${position.longitude.toStringAsFixed(3)}°';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  double _calculateQibla(double lat, double lon) {
    const kaabaLat = 21.4225;
    const kaabaLon = 39.8262;
    final dLon = (kaabaLon - lon) * pi / 180;
    final lat1 = lat * pi / 180;
    const lat2 = kaabaLat * pi / 180;
    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    return (atan2(y, x) * 180 / pi + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        title: const Text('Qibla - قبلہ',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _getLocationAndCalculate,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF4CAF50)),
                  SizedBox(height: 16),
                  Text('Getting your location...',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            )
          : _error != null
              ? _buildError()
              : _buildCompass(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off_rounded, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            const Text('Location Required',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 12),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _getLocationAndCalculate,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        double deviceHeading = 0;
        bool hasCompass = true;

        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.heading == null) {
          hasCompass = false;
        } else {
          deviceHeading = snapshot.data!.heading!;
        }

        // Arrow should point to qibla relative to current device heading
        // qiblaAngle is from North, deviceHeading is current North direction
        final arrowAngle =
            ((_qiblaAngle! - deviceHeading) * pi / 180);

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Kaaba label
              const Text(
                'الكعبة المشرفة',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Holy Kaaba, Makkah',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),

              const SizedBox(height: 40),

              // Compass widget
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow ring
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) => Container(
                      width: 300 + (_pulseController.value * 10),
                      height: 300 + (_pulseController.value * 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF4CAF50)
                              .withOpacity(0.2 - (_pulseController.value * 0.1)),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  // Compass rose background
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF1A3A2A),
                          const Color(0xFF0D1B2A),
                        ],
                      ),
                      border: Border.all(
                          color: const Color(0xFF2E7D32), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Compass markings — rotate opposite to device heading to stay fixed
                        Transform.rotate(
                          angle: -deviceHeading * pi / 180,
                          child: CustomPaint(
                            size: const Size(260, 260),
                            painter: _CompassPainter(),
                          ),
                        ),

                        // Qibla arrow — always points to Qibla
                        Transform.rotate(
                          angle: arrowAngle,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 90,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFFFD700),
                                      Color(0xFFFFA000),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          const Color(0xFFFFD700).withOpacity(0.5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 12,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Kaaba icon at top of arrow tip
                        Transform.translate(
                          offset: Offset(
                            90 * sin(arrowAngle),
                            -90 * cos(arrowAngle),
                          ),
                          child: const Icon(
                            Icons.mosque,
                            color: Color(0xFFFFD700),
                            size: 24,
                          ),
                        ),

                        // Center circle
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF2E7D32),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              if (!hasCompass)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.orange.withOpacity(0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Compass sensor not available. Arrow shows calculated direction only.',
                          style:
                              TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Info cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _InfoTile(
                        label: 'Qibla Angle',
                        value: '${_qiblaAngle!.toStringAsFixed(1)}°',
                        icon: Icons.explore,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoTile(
                        label: 'Direction',
                        value: _compassLabel(_qiblaAngle!),
                        icon: Icons.navigation,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _InfoTile(
                  label: 'Your Location',
                  value: _coords ?? '',
                  icon: Icons.location_on,
                  fullWidth: true,
                ),
              ),

              const SizedBox(height: 24),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3A2A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF2E7D32).withOpacity(0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Color(0xFF4CAF50), size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Face the golden arrow direction to pray towards the Holy Kaaba in Makkah',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  String _compassLabel(double angle) {
    if (angle >= 337.5 || angle < 22.5) return 'North';
    if (angle < 67.5) return 'North-East';
    if (angle < 112.5) return 'East';
    if (angle < 157.5) return 'South-East';
    if (angle < 202.5) return 'South';
    if (angle < 247.5) return 'South-West';
    if (angle < 292.5) return 'West';
    return 'North-West';
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool fullWidth;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3A2A),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFF2E7D32).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4CAF50), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final tickPaint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 1.5;

    final majorTickPaint = Paint()
      ..color = Colors.white60
      ..strokeWidth = 2;

    // Draw tick marks every 30 degrees
    for (int i = 0; i < 360; i += 10) {
      final angle = i * pi / 180;
      final isMajor = i % 30 == 0;
      final tickLen = isMajor ? 14.0 : 7.0;
      final outer = Offset(
        center.dx + (radius - 6) * cos(angle - pi / 2),
        center.dy + (radius - 6) * sin(angle - pi / 2),
      );
      final inner = Offset(
        center.dx + (radius - 6 - tickLen) * cos(angle - pi / 2),
        center.dy + (radius - 6 - tickLen) * sin(angle - pi / 2),
      );
      canvas.drawLine(outer, inner, isMajor ? majorTickPaint : tickPaint);
    }

    // Draw N S E W labels
    final labels = {'N': 0.0, 'E': 90.0, 'S': 180.0, 'W': 270.0};
    for (final entry in labels.entries) {
      final angle = entry.value * pi / 180;
      final pos = Offset(
        center.dx + (radius - 30) * cos(angle - pi / 2),
        center.dy + (radius - 30) * sin(angle - pi / 2),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: entry.key,
          style: TextStyle(
            color: entry.key == 'N' ? Colors.red : Colors.white,
            fontSize: entry.key == 'N' ? 18 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
          canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
