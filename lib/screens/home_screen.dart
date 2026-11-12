import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/lala_service.dart';
import '../services/tmdb_service.dart';
import '../widgets/hero_banner.dart';
import '../widgets/media_row.dart';
import '../theme/netflix_theme.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onSwitchToMovies;
  final VoidCallback? onSwitchToSeries;
  final VoidCallback? onSwitchToKids;
  final VoidCallback? onSwitchToAnime;

  const HomeScreen({
    super.key,
    this.onSwitchToMovies,
    this.onSwitchToSeries,
    this.onSwitchToKids,
    this.onSwitchToAnime,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LalaService _lalaService = LalaService();
  final TMDBService _tmdbService = TMDBService();

  List<MediaItem> _kurdishItems = [];
  List<MediaItem> _tmdbTrending = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final items = await _lalaService.fetchCatalog();
    final trending = await _tmdbService.getTrendingMovies();
    if (mounted) {
      setState(() {
        _kurdishItems = items;
        _tmdbTrending = trending;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _kurdishItems.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: NetflixTheme.netflixRed,
        ),
      );
    }

    final heroItem = _kurdishItems.isNotEmpty ? _kurdishItems.first : null;
    final movies = _lalaService.getMovies();
    final series = _lalaService.getSeries();
    final kids = _lalaService.getKids();
    final anime = _lalaService.getAnime();

    return RefreshIndicator(
      color: NetflixTheme.netflixRed,
      backgroundColor: NetflixTheme.netflixDarkGray,
      onRefresh: () async {
        await _lalaService.fetchCatalog(forceRefresh: true);
        await _loadData();
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Banner
            if (heroItem != null) HeroBanner(item: heroItem),

            const SizedBox(height: 10),

            // Kurdish Dubbed Latest
            MediaRow(
              title: 'دۆبلاژکراوی کوردی',
              items: _kurdishItems,
            ),

            // Movies Row
            MediaRow(
              title: 'فیلمە تایبەتەکان',
              items: movies,
              onSeeAll: widget.onSwitchToMovies,
            ),

            // Series Row
            MediaRow(
              title: 'زنجیرەکان',
              items: series,
              onSeeAll: widget.onSwitchToSeries,
            ),

            // Kids Row
            MediaRow(
              title: 'کارتۆن و منداڵان',
              items: kids,
              onSeeAll: widget.onSwitchToKids,
            ),

            // Anime Row
            MediaRow(
              title: 'ئەنیمێی هەڵبژێردراو',
              items: anime,
              onSeeAll: widget.onSwitchToAnime,
            ),

            // TMDB Trending Row
            if (_tmdbTrending.isNotEmpty)
              MediaRow(
                title: 'پێشنیازکراوی جیهانی (TMDB)',
                items: _tmdbTrending,
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

