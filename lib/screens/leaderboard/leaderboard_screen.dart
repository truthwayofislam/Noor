import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../widgets/error_view.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  List<LeaderboardEntry> _globalLeaderboard = [];
  List<LeaderboardEntry> _countryLeaderboard = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCountry = 'Pakistan';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user != null) _selectedCountry = user.country;
    _loadLeaderboards();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboards() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final global = await _apiService.getGlobalLeaderboard(limit: 100);
      final country = await _apiService.getCountryLeaderboard(
        country: _selectedCountry, limit: 100,
      );
      setState(() {
        _globalLeaderboard = global.map((e) => LeaderboardEntry.fromJson(e)).toList();
        _countryLeaderboard = country.map((e) => LeaderboardEntry.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = Provider.of<UserProvider>(context).currentUser;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xFF2E7D32),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadLeaderboards,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      const Icon(Icons.emoji_events, color: Colors.amber, size: 40),
                      const SizedBox(height: 8),
                      const Text(
                        'Leaderboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (currentUser != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                '${currentUser.username}  •  ${currentUser.points} pts',
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.amber,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: const [
                Tab(text: 'Global', icon: Icon(Icons.public, size: 18)),
                Tab(text: 'Country', icon: Icon(Icons.flag, size: 18)),
              ],
            ),
          ),
        ],
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ErrorView(
                    error: _error,
                    onRetry: _loadLeaderboards,
                    title: 'Could not load Leaderboard',
                    icon: Icons.leaderboard_outlined,
                  )
                : TabBarView(
                controller: _tabController,
                children: [
                  _buildList(_globalLeaderboard, currentUser, isDark),
                  _buildList(_countryLeaderboard, currentUser, isDark),
                ],
              ),
      ),
    );
  }

  Widget _buildList(List<LeaderboardEntry> entries, User? currentUser, bool isDark) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No entries yet', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isMe = currentUser?.username == entry.username;
        return _LeaderboardCard(entry: entry, isMe: isMe, isDark: isDark);
      },
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isMe;
  final bool isDark;

  const _LeaderboardCard({required this.entry, required this.isMe, required this.isDark});

  Color get _rankColor {
    switch (entry.rank) {
      case 1: return const Color(0xFFFFD700);
      case 2: return const Color(0xFFC0C0C0);
      case 3: return const Color(0xFFCD7F32);
      default: return const Color(0xFF2E7D32);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTop3 = entry.rank <= 3;
    final cardColor = isMe
        ? const Color(0xFF2E7D32).withOpacity(isDark ? 0.3 : 0.1)
        : isDark
            ? const Color(0xFF1E1E1E)
            : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isMe
            ? Border.all(color: const Color(0xFF2E7D32), width: 2)
            : isTop3
                ? Border.all(color: _rankColor.withOpacity(0.5), width: 1.5)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _rankColor.withOpacity(isTop3 ? 1.0 : 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isTop3
                    ? Icon(
                        entry.rank == 1
                            ? Icons.emoji_events
                            : entry.rank == 2
                                ? Icons.military_tech
                                : Icons.workspace_premium,
                        color: isTop3 ? Colors.white : _rankColor,
                        size: 22,
                      )
                    : Text(
                        '${entry.rank}',
                        style: TextStyle(
                          color: _rankColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),

            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: _rankColor.withOpacity(0.2),
              child: Text(
                entry.username[0].toUpperCase(),
                style: TextStyle(
                  color: _rankColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name & Country
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        entry.username,
                        style: TextStyle(
                          fontWeight: isTop3 ? FontWeight.bold : FontWeight.w600,
                          fontSize: isTop3 ? 17 : 15,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('You', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 13, color: Colors.grey[500]),
                      const SizedBox(width: 3),
                      Text(entry.country, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),

            // Points
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.points}',
                      style: TextStyle(
                        fontSize: isTop3 ? 20 : 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                Text('points', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
