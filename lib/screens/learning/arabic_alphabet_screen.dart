import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/arabic_alphabet_model.dart';
import '../../providers/user_provider.dart';

class ArabicAlphabetScreen extends StatefulWidget {
  const ArabicAlphabetScreen({super.key});

  @override
  State<ArabicAlphabetScreen> createState() => _ArabicAlphabetScreenState();
}

class _ArabicAlphabetScreenState extends State<ArabicAlphabetScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn Arabic - عربی سیکھیں'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Letters', icon: Icon(Icons.abc)),
            Tab(text: 'Harakat', icon: Icon(Icons.format_size)),
            Tab(text: 'Forms', icon: Icon(Icons.grid_view)),
            Tab(text: 'Al-Fatiha', icon: Icon(Icons.menu_book)),
            Tab(text: 'Short Surahs', icon: Icon(Icons.auto_stories)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _LettersTab(),
          const _HarakatTab(),
          const _LetterFormsTab(),
          _LessonTab(
            lessons: ArabicAlphabetData.fatihaLessons,
            surahName: 'Surah Al-Fatiha',
            surahNameArabic: 'سُورَةُ الْفَاتِحَة',
            color: Colors.green,
          ),
          _LessonTab(
            lessons: ArabicAlphabetData.shortSurahLessons,
            surahName: 'Short Surahs',
            surahNameArabic: 'قِصَار السُّوَر',
            color: Colors.purple,
          ),
        ],
      ),
    );
  }
}

// ── Tab 1: Letters ────────────────────────────────────────────────────────────

class _LettersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: ArabicAlphabetData.letters.length,
      itemBuilder: (context, index) {
        final letter = ArabicAlphabetData.letters[index];
        return Card(
          elevation: 2,
          child: InkWell(
            onTap: () => _showLetterDetails(context, letter),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(letter.arabic,
                      style: const TextStyle(
                          fontSize: 44, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(letter.name,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(letter.transliteration,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLetterDetails(BuildContext context, ArabicLetter letter) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(letter.arabic,
                      style: const TextStyle(
                          fontSize: 72, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              Text(letter.name,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              Text('${letter.transliteration} — ${letter.pronunciation}',
                  style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 16),
              const Text('Examples:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: letter.examples
                    .map((e) => Text(e,
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w500)))
                    .toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tab 2: Harakat ────────────────────────────────────────────────────────────

class _HarakatTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ArabicAlphabetData.harakat.length,
      itemBuilder: (context, index) {
        final h = ArabicAlphabetData.harakat[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(h.example,
                        style: const TextStyle(
                            fontSize: 44, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(h.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(h.description,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey[700])),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Sound: ${h.sound}',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Tab 3: Letter Forms ───────────────────────────────────────────────────────

class _LetterFormsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Arabic letters change shape depending on their position in a word.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        // Header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Expanded(
                  flex: 2,
                  child: Text('Letter',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              ...[
                'Isolated\nاَلَف',
                'Initial\nشروع',
                'Middle\nدرمیان',
                'End\nآخر'
              ].map((h) => Expanded(
                    child: Text(h,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                  )),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: ArabicAlphabetData.letterForms.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final lf = ArabicAlphabetData.letterForms[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lf.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                          Text(lf.transliteration,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[600])),
                          if (!lf.joinsNext)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('non-joining',
                                  style: TextStyle(
                                      fontSize: 9, color: Colors.orange)),
                            ),
                        ],
                      ),
                    ),
                    ...[lf.isolated, lf.initial, lf.medial, lf.final_]
                        .map((form) => Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 2),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(form,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 26)),
                              ),
                            )),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Tab 4 & 5: Quranic Lessons ────────────────────────────────────────────────

class _LessonTab extends StatefulWidget {
  final List<QuranicLesson> lessons;
  final String surahName;
  final String surahNameArabic;
  final Color color;

  const _LessonTab({
    required this.lessons,
    required this.surahName,
    required this.surahNameArabic,
    required this.color,
  });

  @override
  State<_LessonTab> createState() => _LessonTabState();
}

class _LessonTabState extends State<_LessonTab> {
  int _currentIndex = 0;
  bool _showWordBreakdown = false;

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lessons[_currentIndex];
    final total = widget.lessons.length;

    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.color, widget.color.withOpacity(0.7)],
            ),
          ),
          child: Column(
            children: [
              Text(widget.surahNameArabic,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14)),
              Text(widget.surahName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Ayah ${lesson.ayahNumber}  •  ${_currentIndex + 1} of $total',
                  style: const TextStyle(
                      color: Colors.white60, fontSize: 12)),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Full Arabic ayah
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        widget.color.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: widget.color.withOpacity(0.2)),
                  ),
                  child: Text(
                    lesson.fullArabic,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                        fontSize: 28, height: 1.8),
                  ),
                ),
                const SizedBox(height: 12),

                // Transliteration
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    lesson.transliteration,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700]),
                  ),
                ),
                const SizedBox(height: 8),

                // Translation
                Text(
                  lesson.translation,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 4),
                // Urdu
                Text(
                  lesson.urdu,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5),
                ),

                const SizedBox(height: 16),

                // Word breakdown toggle
                OutlinedButton.icon(
                  onPressed: () => setState(
                      () => _showWordBreakdown = !_showWordBreakdown),
                  icon: Icon(_showWordBreakdown
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down),
                  label: Text(_showWordBreakdown
                      ? 'Hide Word Breakdown'
                      : 'Show Word by Word'),
                ),

                if (_showWordBreakdown) ...[
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Word by Word:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: lesson.words
                        .map((w) => _WordCard(word: w, color: widget.color))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Navigation
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2)),
            ],
          ),
          child: Row(
            children: [
              IconButton.outlined(
                onPressed: _currentIndex > 0
                    ? () => setState(() {
                          _currentIndex--;
                          _showWordBreakdown = false;
                        })
                    : null,
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / total,
                  color: widget.color,
                  backgroundColor: widget.color.withOpacity(0.15),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              IconButton.outlined(
                onPressed: _currentIndex < total - 1
                    ? () => setState(() {
                          _currentIndex++;
                          _showWordBreakdown = false;
                        })
                    : () => _onComplete(context),
                icon: Icon(_currentIndex < total - 1
                    ? Icons.arrow_forward
                    : Icons.check_circle),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onComplete(BuildContext context) {
    final userProvider =
        Provider.of<UserProvider>(context, listen: false);
    if (userProvider.isAuthenticated) {
      userProvider.logActivity(
        activityType: 'lesson_completed',
        points: 20,
        metadata: {'lesson': widget.surahName},
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.surahName} completed! +20 points 🎉'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  final QuranicWord word;
  final Color color;

  const _WordCard({required this.word, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(word.arabic,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(word.transliteration,
              style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600])),
          Text(word.meaning,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          Text(word.urdu,
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
