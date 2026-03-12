import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/offline_quran_service.dart';

class MushafQuranScreen extends StatefulWidget {
  const MushafQuranScreen({super.key});

  @override
  State<MushafQuranScreen> createState() => _MushafQuranScreenState();
}

class _MushafQuranScreenState extends State<MushafQuranScreen> {
  int _currentPage = 1;
  late PageController _pageController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initQuran();
  }

  Future<void> _initQuran() async {
    await OfflineQuranService.loadQuran();
    await _loadLastRead();
    setState(() => _isLoading = false);
  }

  Future<void> _loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPage = prefs.getInt('mushaf_last_page') ?? 1;
    _pageController = PageController(initialPage: lastPage - 1);
    setState(() => _currentPage = lastPage);
  }

  Future<void> _saveLastRead(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('mushaf_last_page', page);
  }

  List<Map<String, dynamic>> _getPageData(int page) {
    return OfflineQuranService.getPage(page);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mushaf - Page $_currentPage/604'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showPageSelector,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.brown.shade50, Colors.amber.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            final page = index + 1;
            setState(() => _currentPage = page);
            _saveLastRead(page);
          },
          itemCount: 604,
          itemBuilder: (context, index) {
            final page = index + 1;
            final ayahs = _getPageData(page);
            
            if (ayahs.isEmpty) {
              return Center(
                child: Text(
                  'Page data not available',
                  style: TextStyle(fontSize: 18, color: Colors.brown.shade700),
                ),
              );
            }
            
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: RichText(
                          textAlign: TextAlign.justify,
                          textDirection: TextDirection.rtl,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 24,
                              height: 2.0,
                              fontFamily: 'Amiri',
                              letterSpacing: 0.5,
                              color: Colors.black87,
                            ),
                            children: ayahs.map((ayah) {
                              return TextSpan(
                                text: '${ayah['text']} ۝${ayah['ayah']}۞ ',
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.brown.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'صفحہ $page',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.brown.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.first_page),
              onPressed: _currentPage > 1 ? () => _pageController.jumpToPage(0) : null,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              iconSize: 32,
              onPressed: _currentPage > 1
                  ? () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      )
                  : null,
            ),
            Text('$_currentPage / 604', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              iconSize: 32,
              onPressed: _currentPage < 604
                  ? () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      )
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: _currentPage < 604 ? () => _pageController.jumpToPage(603) : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showPageSelector() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Go to Page'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Page Number (1-604)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final page = int.tryParse(controller.text);
              if (page != null && page >= 1 && page <= 604) {
                _pageController.jumpToPage(page - 1);
                Navigator.pop(context);
              }
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
