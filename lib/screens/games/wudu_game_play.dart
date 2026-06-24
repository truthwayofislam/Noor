import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../services/sound_service.dart';
import '../../providers/user_provider.dart';

class WuduGamePlay extends StatefulWidget {
  final int level;
  const WuduGamePlay({super.key, required this.level});

  @override
  State<WuduGamePlay> createState() => _WuduGamePlayState();
}

class _WuduGamePlayState extends State<WuduGamePlay> {
  List<Map<String, dynamic>> _correctSteps = [];
  List<Map<String, dynamic>> _userSteps = [];
  List<Map<String, dynamic>> _availableSteps = [];
  int _currentTapIndex = 0;
  int _mistakes = 0;
  Timer? _timer;
  int _secondsElapsed = 0;

  final List<Map<String, dynamic>> _allWuduSteps = [
    {'id': 1, 'arabic': 'نِيَّة', 'english': 'Intention (Niyyah)', 'urdu': 'نیت کرنا', 'icon': Icons.favorite},
    {'id': 2, 'arabic': 'بِسْمِ اللَّهِ', 'english': 'Say Bismillah', 'urdu': 'بسم اللہ کہنا', 'icon': Icons.record_voice_over},
    {'id': 3, 'arabic': 'غَسْلُ الْكَفَّيْنِ', 'english': 'Wash both hands', 'urdu': 'دونوں ہاتھ دھونا', 'icon': Icons.back_hand},
    {'id': 4, 'arabic': 'الْمَضْمَضَةُ', 'english': 'Rinse mouth', 'urdu': 'کلی کرنا', 'icon': Icons.water_drop},
    {'id': 5, 'arabic': 'الْاِسْتِنْشَاقُ', 'english': 'Sniff water into nose', 'urdu': 'ناک میں پانی ڈالنا', 'icon': Icons.air},
    {'id': 6, 'arabic': 'غَسْلُ الْوَجْهِ', 'english': 'Wash face', 'urdu': 'چہرہ دھونا', 'icon': Icons.face},
    {'id': 7, 'arabic': 'غَسْلُ الْيَدَيْنِ', 'english': 'Wash arms to elbows', 'urdu': 'کہنیوں تک ہاتھ دھونا', 'icon': Icons.waving_hand},
    {'id': 8, 'arabic': 'مَسْحُ الرَّأْسِ', 'english': 'Wipe head', 'urdu': 'سر کا مسح کرنا', 'icon': Icons.emoji_people},
    {'id': 9, 'arabic': 'مَسْحُ الْأُذُنَيْنِ', 'english': 'Wipe ears', 'urdu': 'کانوں کا مسح کرنا', 'icon': Icons.hearing},
    {'id': 10, 'arabic': 'غَسْلُ الْقَدَمَيْنِ', 'english': 'Wash feet', 'urdu': 'پاؤں دھونا', 'icon': Icons.directions_walk},
  ];

  @override
  void initState() {
    super.initState();
    _initGame();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsElapsed++);
    });
  }

  void _initGame() {
    final stepsCount = widget.level <= 5 ? 4 : widget.level <= 10 ? 6 : widget.level <= 15 ? 8 : 10;
    _correctSteps = _allWuduSteps.take(stepsCount).toList();
    
    if (widget.level <= 10) {
      // Drag & Drop mode
      _availableSteps = List.from(_correctSteps)..shuffle();
      _userSteps = List.filled(_correctSteps.length, {});
    } else {
      // Quick Tap mode
      _availableSteps = List.from(_correctSteps)..shuffle();
    }
  }

  bool _isDragDropMode() => widget.level <= 10;

  void _onStepTapped(Map<String, dynamic> step) {
    if (!_isDragDropMode()) {
      if (step['id'] == _correctSteps[_currentTapIndex]['id']) {
        SoundService.playCorrect();
        setState(() {
          _availableSteps.remove(step);
          _currentTapIndex++;
        });
        
        if (_currentTapIndex == _correctSteps.length) {
          _timer?.cancel();
          _showWinDialog();
        }
      } else {
        SoundService.playWrong();
        setState(() => _mistakes++);
      }
    }
  }

  void _showWinDialog() {
    final stars = _mistakes == 0 && _secondsElapsed < 30 ? 3 
                : _mistakes <= 2 ? 2 : 1;
    final points = stars == 3 ? 30 : stars == 2 ? 20 : 15;
    
    // Award points
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.isAuthenticated) {
        userProvider.logActivity(
          activityType: 'game_completed',
          points: points,
          metadata: {
            'game': 'wudu_game',
            'level': widget.level,
            'mistakes': _mistakes,
            'time': _secondsElapsed,
            'stars': stars,
          },
        );
      }
    });

    SoundService.playLevelComplete();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Perfect Wudu!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Icon(
                  i < stars ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Time: ${_secondsElapsed}s', style: const TextStyle(fontSize: 16)),
            Text('Mistakes: $_mistakes', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('+$points points', style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          if (widget.level < 20)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: const Text('Next Level'),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentTapIndex = 0;
                _mistakes = 0;
                _secondsElapsed = 0;
                _initGame();
                _startTimer();
              });
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, widget.level < 20);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${widget.level} - ${_isDragDropMode() ? "Drag & Drop" : "Quick Tap"}'),
        backgroundColor: Colors.blue,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Icon(Icons.timer, size: 18),
                  const SizedBox(width: 4),
                  Text('${_secondsElapsed}s', style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 16),
                  const Icon(Icons.close, size: 18, color: Colors.red),
                  const SizedBox(width: 4),
                  Text('$_mistakes', style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.cyan.shade50],
          ),
        ),
        child: _isDragDropMode() ? _buildDragDropMode() : _buildQuickTapMode(),
      ),
    );
  }

  Widget _buildDragDropMode() {
    return Column(
      children: [
        // Drop Zones
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Arrange in correct order:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _userSteps.length,
                    itemBuilder: (context, index) {
                      return DragTarget<Map<String, dynamic>>(
                        onAccept: (step) {
                          SoundService.playCardFlip();
                          setState(() {
                            _userSteps[index] = step;
                            _availableSteps.remove(step);
                          });
                          
                          // Check if all filled correctly
                          if (!_userSteps.any((s) => s.isEmpty)) {
                            bool allCorrect = true;
                            for (int i = 0; i < _userSteps.length; i++) {
                              if (_userSteps[i]['id'] != _correctSteps[i]['id']) {
                                allCorrect = false;
                                _mistakes++;
                                break;
                              }
                            }
                            
                            if (allCorrect) {
                              _timer?.cancel();
                              _showWinDialog();
                            } else {
                              SoundService.playWrong();
                              // Reset
                              Future.delayed(const Duration(milliseconds: 500), () {
                                setState(() {
                                  _availableSteps.addAll(_userSteps.where((s) => s.isNotEmpty));
                                  _userSteps = List.filled(_correctSteps.length, {});
                                });
                              });
                            }
                          }
                        },
                        builder: (context, candidateData, rejectedData) {
                          final step = _userSteps[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: step.isEmpty ? Colors.grey.shade200 : Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: candidateData.isNotEmpty ? Colors.blue : Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(width: 12),
                                if (step.isEmpty)
                                  const Text('Drop step here', style: TextStyle(color: Colors.grey))
                                else
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(step['english'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text(step['urdu'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Available Steps
        Container(
          height: 140,
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Drag steps from here:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableSteps.length,
                  itemBuilder: (context, index) {
                    final step = _availableSteps[index];
                    return Draggable<Map<String, dynamic>>(
                      data: step,
                      feedback: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        child: _StepCard(step: step, isDragging: true),
                      ),
                      childWhenDragging: _StepCard(step: step, isGhost: true),
                      child: _StepCard(step: step),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickTapMode() {
    return Column(
      children: [
        // Progress
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              Text(
                'Tap step ${_currentTapIndex + 1}:',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _correctSteps[_currentTapIndex]['english'],
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _currentTapIndex / _correctSteps.length,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation(Colors.blue),
              ),
            ],
          ),
        ),

        // Available Steps
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _availableSteps.length,
            itemBuilder: (context, index) {
              final step = _availableSteps[index];
              return InkWell(
                onTap: () => _onStepTapped(step),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(step['icon'], size: 40, color: Colors.blue),
                        const SizedBox(height: 8),
                        Text(
                          step['english'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final Map<String, dynamic> step;
  final bool isDragging;
  final bool isGhost;

  const _StepCard({
    required this.step,
    this.isDragging = false,
    this.isGhost = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isGhost ? Colors.grey.shade200 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isGhost ? Colors.grey : Colors.blue, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(step['icon'], size: 32, color: isGhost ? Colors.grey : Colors.blue),
          const SizedBox(height: 8),
          Text(
            step['english'],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isGhost ? Colors.grey : Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
