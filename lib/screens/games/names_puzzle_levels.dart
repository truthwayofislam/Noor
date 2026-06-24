import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'names_puzzle_play.dart';

class NamesPuzzleLevels extends StatefulWidget {
  const NamesPuzzleLevels({super.key});

  @override
  State<NamesPuzzleLevels> createState() => _NamesPuzzleLevelsState();
}

class _NamesPuzzleLevelsState extends State<NamesPuzzleLevels> {
  int _unlockedLevel = 1;
  final List<int> _completedLevels = [];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _unlockedLevel = prefs.getInt('names_game_unlocked') ?? 1;
      final completed = prefs.getStringList('names_game_completed') ?? [];
      _completedLevels.addAll(completed.map((e) => int.parse(e)));
    });
  }

  Future<void> _unlockNextLevel(int currentLevel) async {
    if (currentLevel >= _unlockedLevel) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('names_game_unlocked', currentLevel + 1);
      
      if (!_completedLevels.contains(currentLevel)) {
        _completedLevels.add(currentLevel);
        await prefs.setStringList(
          'names_game_completed',
          _completedLevels.map((e) => e.toString()).toList(),
        );
      }
      
      setState(() {
        _unlockedLevel = currentLevel + 1;
      });
    }
  }

  String _getGameMode(int level) {
    if (level <= 33) return 'Word Scramble';
    if (level <= 66) return 'Memory Match';
    return 'Type Challenge';
  }

  Color _getModeColor(int level) {
    if (level <= 33) return Colors.purple;
    if (level <= 66) return Colors.orange;
    return Colors.teal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.amber.shade400, Colors.orange.shade300],
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
                            '99 Names of Allah',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_completedLevels.length}/99 Names Learned',
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
                          const Icon(Icons.emoji_events, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${_completedLevels.length}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Mode Legend
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ModeBadge(color: Colors.purple, label: '1-33\nScramble'),
                    _ModeBadge(color: Colors.orange, label: '34-66\nMatch'),
                    _ModeBadge(color: Colors.teal, label: '67-99\nType'),
                  ],
                ),
              ),

              // Levels List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 99,
                  itemBuilder: (context, index) {
                    final level = index + 1;
                    final isUnlocked = level <= _unlockedLevel;
                    final isCompleted = _completedLevels.contains(level);

                    return _LevelCard(
                      level: level,
                      gameMode: _getGameMode(level),
                      modeColor: _getModeColor(level),
                      isUnlocked: isUnlocked,
                      isCompleted: isCompleted,
                      onTap: isUnlocked
                          ? () async {
                              final completed = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NamesPuzzlePlay(level: level),
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

class _ModeBadge extends StatelessWidget {
  final Color color;
  final String label;

  const _ModeBadge({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final String gameMode;
  final Color modeColor;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.level,
    required this.gameMode,
    required this.modeColor,
    required this.isUnlocked,
    required this.isCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: isUnlocked ? 3 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isUnlocked ? Colors.white : Colors.grey.shade300,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Level Number
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green : modeColor.withOpacity(isUnlocked ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check_circle, color: Colors.white, size: 28)
                      : Text(
                          '$level',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? modeColor : Colors.grey,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Name Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name #$level',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gameMode,
                      style: TextStyle(
                        fontSize: 13,
                        color: isUnlocked ? modeColor : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Lock/Arrow Icon
              Icon(
                isUnlocked ? Icons.arrow_forward_ios : Icons.lock,
                color: isUnlocked ? modeColor : Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
