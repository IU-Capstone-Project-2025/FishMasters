import 'package:flutter/material.dart';
import 'package:mobile_app/l10n/app_localizations.dart';
import 'package:mobile_app/models/leaderboard_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with TickerProviderStateMixin {
  List<LeaderboardItem> _allPlayers = [];
  List<LeaderboardItem> _filteredPlayers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? _currentUserPosition;
  String? _currentUserEmail;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _getCurrentUserEmail();
    _fetchLeaderboard();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _getCurrentUserEmail() {
    final settingsBox = Hive.box('settings');
    _currentUserEmail = settingsBox.get('email', defaultValue: '');
  }

  Future<void> _fetchLeaderboard() async {
    try {
      final response = await http.get(
        Uri.parse('https://capstone.aquaf1na.fun/api/leaderboard/all'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          _allPlayers = jsonData
              .map((item) => LeaderboardItem.fromJson(item))
              .toList();

          // Sort by score in descending order
          _allPlayers.sort((a, b) => b.score.compareTo(a.score));

          // Find current user position
          _currentUserPosition = _allPlayers.indexWhere(
            (player) => player.email == _currentUserEmail,
          );
          if (_currentUserPosition != -1) {
            _currentUserPosition =
                _currentUserPosition! + 1; // Convert to 1-based index
          }

          _filteredPlayers = List.from(_allPlayers);
          _isLoading = false;
        });
        _animationController.forward();

        // Auto-scroll to current user position after a short delay
        if (_currentUserPosition != null && _currentUserPosition! > 3) {
          Future.delayed(const Duration(seconds: 1), () {
            _scrollToCurrentUser();
          });
        }
      } else {
        throw Exception('Failed to load leaderboard');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading leaderboard: $e')),
        );
      }
    }
  }

  void _filterPlayers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredPlayers = List.from(_allPlayers);
      } else {
        _filteredPlayers = _allPlayers.where((player) {
          final fullName = '${player.name} ${player.surname}'.toLowerCase();
          final email = player.email.toLowerCase();
          final searchLower = query.toLowerCase();
          return fullName.contains(searchLower) || email.contains(searchLower);
        }).toList();
      }
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToCurrentUser() {
    if (_currentUserPosition == null) return;

    // Calculate approximate position (each item is roughly 80 pixels)
    final targetPosition = (_currentUserPosition! - 1) * 80.0;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final scrollPosition = (targetPosition > maxScroll)
        ? maxScroll
        : targetPosition;

    _scrollController.animateTo(
      scrollPosition,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  void _searchAndScrollToPlayer() {
    if (_searchQuery.isEmpty) return;

    final foundIndex = _allPlayers.indexWhere((player) {
      final fullName = '${player.name} ${player.surname}'.toLowerCase();
      final email = player.email.toLowerCase();
      final searchLower = _searchQuery.toLowerCase();
      return fullName.contains(searchLower) || email.contains(searchLower);
    });

    if (foundIndex != -1) {
      // Clear search to show full list
      _searchController.clear();
      _filterPlayers('');

      // Scroll to found player
      final targetPosition = foundIndex * 80.0;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final scrollPosition = (targetPosition > maxScroll)
          ? maxScroll
          : targetPosition;

      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.playerNotFound)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.leaderboardText,
          style: textTheme.displaySmall,
        ),
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        actions: [
          if (_currentUserPosition != null)
            IconButton(
              onPressed: _scrollToCurrentUser,
              icon: const Icon(Icons.person_pin_circle),
              tooltip: localizations.findMeButton,
            ),
          IconButton(
            onPressed: _scrollToTop,
            icon: const Icon(Icons.keyboard_arrow_up),
            tooltip: localizations.backToTopButton,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: localizations.searchPlayersPlaceholder,
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: colorScheme.onSurface,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: colorScheme.onSurface,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _filterPlayers('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: colorScheme.outline,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                      ),
                    ),
                    style: TextStyle(color: colorScheme.onSurface),
                    onChanged: _filterPlayers,
                    onSubmitted: (_) => _searchAndScrollToPlayer(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.search, color: colorScheme.onSurface),
                    onPressed: _searchAndScrollToPlayer,
                    tooltip: localizations.searchingLabel,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    localizations.loadingLeaderboard,
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8.0),
                itemCount: _filteredPlayers.length,
                itemBuilder: (context, index) {
                  final player = _filteredPlayers[index];
                  final originalPosition = _allPlayers.indexOf(player) + 1;
                  final isCurrentUser = player.email == _currentUserEmail;
                  final isTop3 = originalPosition <= 3;
                  final isTop10 = originalPosition <= 10;

                  return LeaderboardPlayerCard(
                    player: player,
                    position: originalPosition,
                    isCurrentUser: isCurrentUser,
                    isTop3: isTop3,
                    isTop10: isTop10,
                  );
                },
              ),
            ),
    );
  }
}

class LeaderboardPlayerCard extends StatelessWidget {
  final LeaderboardItem player;
  final int position;
  final bool isCurrentUser;
  final bool isTop3;
  final bool isTop10;

  const LeaderboardPlayerCard({
    super.key,
    required this.player,
    required this.position,
    required this.isCurrentUser,
    required this.isTop3,
    required this.isTop10,
  });

  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.black;
    }
  }

  ImageProvider _getProfileImage(String? photoData) {
    if (photoData == null || photoData.isEmpty) {
      return const AssetImage('assets/images/profile_picture.png');
    }

    try {
      // Check if it's a URL (starts with http)
      if (photoData.startsWith('http')) {
        return NetworkImage(photoData);
      }

      // Try to decode as base64
      final bytes = base64Decode(photoData);
      return MemoryImage(bytes);
    } catch (e) {
      debugPrint('Error loading profile photo: $e');
      return const AssetImage('assets/images/profile_picture.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    Color? cardColor;
    Color? borderColor;
    double elevation = 2;

    if (isTop3) {
      // Different colors for each top 3 position
      switch (position) {
        case 1:
          cardColor = const Color(0xFFFFFACD); // Solid light gold
          borderColor = const Color(0xFFFFD700);
          break;
        case 2:
          cardColor = const Color(0xFFE8E8E8); // Solid light silver
          borderColor = const Color(0xFFC0C0C0);
          break;
        case 3:
          cardColor = const Color(0xFFDDD0C0); // Solid light bronze
          borderColor = const Color(0xFFCD7F32);
          break;
      }
      elevation = 6;
    } else if (isTop10) {
      cardColor = colorScheme.surface;
      borderColor = colorScheme.secondary;
      elevation = 3;
    } else {
      cardColor = colorScheme.surface;
      borderColor = colorScheme.outline;
      elevation = 2;
    }
    if (isCurrentUser) {
      elevation = 4;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Card(
        elevation: elevation,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: borderColor ?? colorScheme.outline,
            width: isCurrentUser || isTop3 ? 2.0 : 1.0,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: position == 1 ? 24.0 : 12,
            horizontal: 16.0,
          ),
          child: Row(
            children: [
              // Position and badge
              SizedBox(
                width: 60,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTop3 ? 8 : 0,
                        vertical: isTop3 ? 4 : 0,
                      ),
                      decoration: isTop3
                          ? BoxDecoration(
                              color: _getPositionColor(position),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.onPrimary,
                                width: 2,
                              ),
                            )
                          : null,
                      child: Text(
                        '#$position',
                        style: TextStyle(
                          fontSize: isTop3 ? 20 : 18,
                          fontWeight: isTop3
                              ? FontWeight.w900
                              : FontWeight.bold,
                          color: isTop3
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (isTop10 && !isTop3)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorScheme.outline,
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          localizations.top10Badge,
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Profile picture
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isTop3
                        ? (borderColor ?? colorScheme.secondary)
                        : colorScheme.outline,
                    width: isCurrentUser || isTop3 ? 2.0 : 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: _getProfileImage(player.photo),
                  backgroundColor: colorScheme.surface,
                  onBackgroundImageError: (exception, stackTrace) {
                    debugPrint('Error loading profile image: $exception');
                  },
                  child: player.photo == null || player.photo!.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 24,
                          color: colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
              ),

              const SizedBox(width: 12),

              // Player info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${player.name} ${player.surname}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isCurrentUser
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      player.email,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Score
              Row(
                children: [
                  if (isCurrentUser)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 16,
                        color: colorScheme.onSecondary,
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isTop3
                          ? colorScheme.secondary
                          : colorScheme.surfaceBright,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isTop3
                            ? colorScheme.outline
                            : colorScheme.outline.withValues(alpha: 0.5),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${player.score}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isTop3
                                ? colorScheme.onSecondary
                                : colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          localizations.pointsLabel,
                          style: TextStyle(
                            fontSize: 10,
                            color: isTop3
                                ? colorScheme.onSecondary
                                : colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
