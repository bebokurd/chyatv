import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/lala_service.dart';
import '../services/tmdb_service.dart';
import '../widgets/media_card.dart';
import '../theme/netflix_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final LalaService _lala = LalaService();
  final TMDBService _tmdb = TMDBService();

  List<MediaItem> _results = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _results = _lala.cachedItems.take(12).toList();
  }

  void _onSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = _lala.cachedItems.take(12).toList();
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    // Search local Kurdish catalog first
    final localMatches = _lala.search(query);

    // Search TMDB in parallel
    final tmdbMatches = await _tmdb.searchTMDB(query);

    if (mounted) {
      setState(() {
        // Kurdish matches on top, then TMDB
        _results = [...localMatches, ...tmdbMatches];
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NetflixTheme.netflixBlack,
      appBar: AppBar(
        backgroundColor: NetflixTheme.netflixDarkGray,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'گەڕان بەدوای فیلم، زنجیرە، کارتۆن...',
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white54),
                    onPressed: () {
                      _searchController.clear();
                      _onSearch('');
                    },
                  )
                : null,
          ),
          onChanged: _onSearch,
        ),
      ),
      body: _isSearching
          ? const Center(
              child: CircularProgressIndicator(color: NetflixTheme.netflixRed),
            )
          : _results.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.white24),
                      SizedBox(height: 12),
                      Text(
                        'هیچ ئەنجامێک نەدۆزرایەوە',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        child: Text(
                          _searchController.text.isEmpty
                              ? 'پێشنیازکراوەکان'
                              : 'ئەنجامەکانی گەڕان (${_results.length})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          itemCount: _results.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.62,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 10,
                          ),
                          itemBuilder: (context, index) {
                            return MediaCard(
                              item: _results[index],
                              showTitle: true,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

