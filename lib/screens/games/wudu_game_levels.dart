import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'wudu_game_play.dart';

class WuduGameLevels extends StatefulWidget {
  const WuduGameLevels({super.key});

  @override
  State<WuduGameLevels> createState() => _WuduGameLevelsState();
}

class _WuduGameLevelsState extends State<WuduGameLevels> {
  int _unlockedLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _unlockedLevel = prefs.getInt('wudu_game_unlocked') ?? 1;
    });
  }

  Future<void> _unlockNextLevel(int currentLevel) async {
    if (currentLevel >= _unlockedLevel) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('wudu_game_unlocked', currentLevel + 1);
      setState(() {
        _unlockedLevel = currentLevel + 1;
      });
    }
  }

  String _getLevelTitle(int level) {
    if (level <= 10) return 'Drag & Drop - Level $level';
    return 'Quick Tap - Level $level';
  }

  String _getLevelSubtitle(int level) {
    if (level <= 10) return 'Arrange steps in correct order';
    return 'Tap steps quickly in sequence';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade400, Colors.cyan.shade300],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Perfect Wudu Challenge',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Level ${_unlockedLevel - 1}/20 Completed',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.water_drop, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${_unlockedLevel - 1}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Info Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Learn the correct steps of Wudu while playing!',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

              // Levels Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: 20,
                  itemBuilder: (context, index) {
                    final level = index + 1;
                    final isUnlocked = level <= _unlockedLevel;
                    final isCompleted = level < _unlockedLevel;

                    return _LevelCard(
                      level: level,
                      title: _getLevelTitle(level),
                      subtitle: _getLevelSubtitle(level),
                      isUnlocked: isUnlocked,
                      isCompleted: isCompleted,
                      onTap: isUnlocked
                          ? () async {
                              final completed = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WuduGamePlay(level: level),
                                ),
                              );
                              if (completed == true) {
                                _unlockNextLevel(level);
                              }
                            }
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final String title;
  final String subtitle;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.isUnlocked,
    required this.isCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isUnlocked ? 4 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isUnlocked ? Colors.white : Colors.grey.shade300,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isCompleted)
                const Icon(Icons.check_circle, color: Colors.green, size: 28)
              else if (isUnlocked)
                const Icon(Icons.water_drop, color: Colors.blue, size: 28)
              else
                const Icon(Icons.lock, color: Colors.grey, size: 28),
              const SizedBox(height: 8),
              Text(
                'Level $level',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? Colors.blue : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: isUnlocked ? Colors.grey.shade700 : Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
