import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../../services/sound_service.dart';
import '../../providers/user_provider.dart';
import '../../data/allah_names_data.dart';

class NamesPuzzlePlay extends StatefulWidget {
  final int level;
  const NamesPuzzlePlay({super.key, required this.level});

  @override
  State<NamesPuzzlePlay> createState() => _NamesPuzzlePlayState();
}

class _NamesPuzzlePlayState extends State<NamesPuzzlePlay> {
  late Map<String, String> _currentName;
  String _gameMode = '';
  int _mistakes = 0;
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _showHint = false;

  // Word Scramble variables
  List<String> _scrambledLetters = [];
  String _userAnswer = '';

  // Memory Match variables
  List<Map<String, String>> _cards = [];
  List<bool> _flipped = [];
  List<bool> _matched = [];
  int? _firstIndex;
  bool _isChecking = false;

  // Type Challenge variables
  final _typeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentName = AllahNamesData.getName(widget.level);
    _gameMode = _getGameMode();
    _initGame();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _typeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsElapsed++);
    });
  }

  String _getGameMode() {
    if (widget.level <= 33) return 'scramble';
    if (widget.level <= 66) return 'match';
    return 'type';
  }

  void _initGame() {
    if (_gameMode == 'scramble') {
      _initScrambleGame();
    } else if (_gameMode == 'match') {
      _initMatchGame();
    }
  }

  void _initScrambleGame() {
    final letters = _currentName['transliteration']!.split('');
    _scrambledLetters = List.from(letters)..shuffle();
    _userAnswer = '';
  }

  void _initMatchGame() {
    _cards = [
      {'type': 'arabic', 'value': _currentName['arabic']!},
      {'type': 'meaning', 'value': _currentName['meaning']!},
      {'type': 'transliteration', 'value': _currentName['transliteration']!},
      {'type': 'urdu', 'value': _currentName['urdu']!},
    ];
    
    // Add some random cards
    final allNames = AllahNamesData.getAllNames();
    final random = Random();
    while (_cards.length < 8) {
      final randomName = allNames[random.nextInt(allNames.length)];
      if (randomName['number'] != _currentName['number']) {
        final types = ['arabic', 'meaning', 'transliteration', 'urdu'];
        final randomType = types[random.nextInt(types.length)];
        final card = {'type': randomType, 'value': randomName[randomType]!};
        if (!_cards.any((c) => c['value'] == card['value'])) {
          _cards.add(card);
          if (_cards.length >= 8) break;
        }
      }
    }
    
    _cards.shuffle();
    _flipped = List.filled(_cards.length, false);
    _matched = List.filled(_cards.length, false);
  }

  void _checkScrambleAnswer() {
    if (_userAnswer.toLowerCase() == _currentName['transliteration']!.toLowerCase()) {
      _timer?.cancel();
      SoundService.playCorrect();
      _showWinDialog();
    } else {
      SoundService.playWrong();
      setState(() {
        _mistakes++;
        _userAnswer = '';
      });
      
      if (_mistakes >= 3) {
        _showHint = true;
      }
    }
  }

  void _onCardTap(int index) {
    if (_isChecking || _flipped[index] || _matched[index]) return;

    SoundService.playCardFlip();
    setState(() {
      _flipped[index] = true;
    });

    if (_firstIndex == null) {
      _firstIndex = index;
    } else {
      _isChecking = true;
      
      // Check if both cards belong to current name
      final firstCard = _cards[_firstIndex!];
      final secondCard = _cards[index];
      
      bool isMatch = false;
      if (firstCard['type'] == 'arabic' && secondCard['value'] == _currentName['arabic']) isMatch = true;
      if (firstCard['type'] == 'meaning' && secondCard['value'] == _currentName['meaning']) isMatch = true;
      if (firstCard['type'] == 'transliteration' && secondCard['value'] == _currentName['transliteration']) isMatch = true;
      if (firstCard['type'] == 'urdu' && secondCard['value'] == _currentName['urdu']) isMatch = true;
      if (secondCard['type'] == 'arabic' && firstCard['value'] == _currentName['arabic']) isMatch = true;
      if (secondCard['type'] == 'meaning' && firstCard['value'] == _currentName['meaning']) isMatch = true;
      if (secondCard['type'] == 'transliteration' && firstCard['value'] == _currentName['transliteration']) isMatch = true;
      if (secondCard['type'] == 'urdu' && firstCard['value'] == _currentName['urdu']) isMatch = true;

      if (isMatch && firstCard['value'] != secondCard['value']) {
        SoundService.playCorrect();
        setState(() {
          _matched[_firstIndex!] = true;
          _matched[index] = true;
        });
        _firstIndex = null;
        _isChecking = false;

        // Check if all pairs of current name are matched
        int matchedCount = 0;
        for (int i = 0; i < _cards.length; i++) {
          if (_matched[i]) {
            final cardValue = _cards[i]['value'];
            if (cardValue == _currentName['arabic'] ||
                cardValue == _currentName['meaning'] ||
                cardValue == _currentName['transliteration'] ||
                cardValue == _currentName['urdu']) {
              matchedCount++;
            }
          }
        }

        if (matchedCount == 4) {
          _timer?.cancel();
          _showWinDialog();
        }
      } else {
        SoundService.playWrong();
        _mistakes++;
        Timer(const Duration(milliseconds: 800), () {
          setState(() {
            _flipped[_firstIndex!] = false;
            _flipped[index] = false;
            _firstIndex = null;
            _isChecking = false;
          });
        });
      }
    }
  }

  void _checkTypeAnswer() {
    final userInput = _typeController.text.trim().toLowerCase();
    final correctAnswer = _currentName['transliteration']!.toLowerCase();
    
    if (userInput == correctAnswer) {
      _timer?.cancel();
      SoundService.playCorrect();
      _showWinDialog();
    } else {
      SoundService.playWrong();
      setState(() => _mistakes++);
      _typeController.clear();
    }
  }

  void _showWinDialog() {
    final stars = _mistakes == 0 && _secondsElapsed < 20 ? 3
                : _mistakes <= 2 && _secondsElapsed < 40 ? 2 : 1;
    final points = stars == 3 ? 40 : stars == 2 ? 30 : 20;
    
    // Award points
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.isAuthenticated) {
        userProvider.logActivity(
          activityType: 'game_completed',
          points: points,
          metadata: {
            'game': 'names_puzzle',
            'level': widget.level,
            'name': _currentName['transliteration'],
            'mode': _gameMode,
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
        title: const Text('🎉 Name Learned!'),
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
            Text(
              _currentName['arabic']!,
              style: const TextStyle(fontSize: 28),
            ),
            Text(
              _currentName['transliteration']!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              _currentName['meaning']!,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text('Time: ${_secondsElapsed}s', style: const TextStyle(fontSize: 14)),
            Text('Mistakes: $_mistakes', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text('+$points points', style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          if (widget.level < 99)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: const Text('Next Name'),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _mistakes = 0;
                _secondsElapsed = 0;
                _showHint = false;
                _initGame();
                _startTimer();
              });
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, widget.level < 99);
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
        title: Text('Name #${widget.level} - ${_getModeTitle()}'),
        backgroundColor: _getModeColor(),
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
            colors: [_getModeColor().shade50, _getModeColor().shade100],
          ),
        ),
        child: _buildGameMode(),
      ),
    );
  }

  String _getModeTitle() {
    if (_gameMode == 'scramble') return 'Word Scramble';
    if (_gameMode == 'match') return 'Memory Match';
    return 'Type Challenge';
  }

  MaterialColor _getModeColor() {
    if (_gameMode == 'scramble') return Colors.purple;
    if (_gameMode == 'match') return Colors.orange;
    return Colors.teal;
  }

  Widget _buildGameMode() {
    if (_gameMode == 'scramble') return _buildScrambleMode();
    if (_gameMode == 'match') return _buildMatchMode();
    return _buildTypeMode();
  }

  Widget _buildScrambleMode() {
    return Column(
      children: [
        // Name Info
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
          ),
          child: Column(
            children: [
              const Text('Unscramble the name:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(_currentName['meaning']!, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              if (_showHint) ...[
                const SizedBox(height: 8),
                Text(
                  'Hint: ${_currentName['urdu']}',
                  style: const TextStyle(fontSize: 14, color: Colors.orange, fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
        ),

        // User Answer
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple, width: 2),
          ),
          child: Text(
            _userAnswer.isEmpty ? 'Tap letters below' : _userAnswer,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _userAnswer.isEmpty ? Colors.grey : Colors.purple,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 24),

        // Scrambled Letters
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _scrambledLetters.asMap().entries.map((entry) {
              final letter = entry.value;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _userAnswer += letter;
                    _scrambledLetters.removeAt(entry.key);
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)],
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const Spacer(),

        // Action Buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _userAnswer.isEmpty ? null : () {
                    setState(() {
                      _scrambledLetters.addAll(_userAnswer.split(''));
                      _userAnswer = '';
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Clear'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _userAnswer.length >= 4 ? _checkScrambleAnswer : null,
                  icon: const Icon(Icons.check),
                  label: const Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMatchMode() {
    return Column(
      children: [
        // Info
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text('Match all cards of:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_currentName['arabic']!, style: const TextStyle(fontSize: 24)),
            ],
          ),
        ),

        // Cards Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _cards.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _onCardTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: _matched[index]
                          ? [Colors.green, Colors.green.shade700]
                          : _flipped[index]
                              ? [Colors.white, Colors.grey.shade100]
                              : [Colors.orange, Colors.orange.shade700],
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)],
                  ),
                  child: Center(
                    child: _flipped[index] || _matched[index]
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              _cards[index]['value']!,
                              style: TextStyle(
                                fontSize: _cards[index]['type'] == 'arabic' ? 20 : 14,
                                fontWeight: FontWeight.bold,
                                color: _matched[index] ? Colors.white : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        : const Icon(Icons.question_mark, size: 40, color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTypeMode() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Name Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
            ),
            child: Column(
              children: [
                Text(_currentName['arabic']!, style: const TextStyle(fontSize: 36)),
                const SizedBox(height: 12),
                Text(_currentName['meaning']!, style: const TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 8),
                Text(_currentName['urdu']!, style: const TextStyle(fontSize: 16, color: Colors.teal)),
              ],
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'Type the transliteration:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          // Input Field
          TextField(
            controller: _typeController,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: 'e.g., Ar-Rahman',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.teal, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.teal, width: 3),
              ),
            ),
            onSubmitted: (_) => _checkTypeAnswer(),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _checkTypeAnswer,
              icon: const Icon(Icons.check_circle),
              label: const Text('Submit Answer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ),

          const Spacer(),

          if (_mistakes >= 2) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Hint: Starts with "${_currentName['transliteration']![0]}"',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
