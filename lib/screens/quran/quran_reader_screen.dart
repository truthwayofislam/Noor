import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/quran_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranReaderScreen extends StatefulWidget {
  final Surah surah;
  
  const QuranReaderScreen({super.key, required this.surah});

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await Provider.of<QuranProvider>(context, listen: false)
          .loadVerses(widget.surah.number);
      _loadScrollPosition();
    });
    _scrollController.addListener(_saveScrollPosition);
  }

  Future<void> _loadScrollPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final position = prefs.getDouble('quran_scroll_${widget.surah.number}') ?? 0.0;
    if (position > 0 && _scrollController.hasClients) {
      _scrollController.jumpTo(position);
    }
  }

  void _saveScrollPosition() {
    if (_scrollController.hasClients) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setDouble('quran_scroll_${widget.surah.number}', _scrollController.offset);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surah.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle),
            tooltip: 'Mark as completed',
            onPressed: () => _markAsCompleted(context),
          ),
        ],
      ),
      body: Consumer<QuranProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }
          
          if (provider.verses.isEmpty) {
            return const Center(
              child: Text('No verses found'),
            );
          }
          
          return ListView.builder(
            controller: _scrollController,
            itemCount: provider.verses.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemBuilder: (context, index) {
              final verse = provider.verses[index];
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Verse number
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'آیت ${verse.number}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Arabic text
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            verse.text,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontSize: 28,
                              height: 2.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        
                        // Urdu translation
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            verse.translation,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.8,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _markAsCompleted(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.isAuthenticated) {
      await userProvider.logActivity(
        activityType: 'quran_read',
        points: 10,
        metadata: {
          'surah_number': widget.surah.number,
          'surah_name': widget.surah.englishName,
        },
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Surah completed! +10 points'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login to earn points!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}
