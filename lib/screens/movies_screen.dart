import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/lala_service.dart';
import '../services/tmdb_service.dart';
import '../widgets/media_card.dart';
import '../widgets/media_row.dart';
import '../theme/netflix_theme.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  final LalaService _lala = LalaService();
  final TMDBService _tmdb = TMDBService();

  List<MediaItem> _kurdishMovies = [];
  List<MediaItem> _popularTmdb = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() => _isLoading = true);
    final all = await _lala.fetchCatalog();
    final kurdMovies = all.where((m) => m.type.toLowerCase() == 'movie').toList();
    final tmdbMovies = await _tmdb.getTrendingMovies();

    if (mounted) {
      setState(() {
        _kurdishMovies = kurdMovies;
        _popularTmdb = tmdbMovies;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _kurdishMovies.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: NetflixTheme.netflixRed),
      );
    }

    return Scaffold(
      backgroundColor: NetflixTheme.netflixBlack,
      appBar: AppBar(
        title: const Text(
          'فیلمەکان',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: NetflixTheme.netflixBlack,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row of Kurdish Dubbed Movies
            MediaRow(
              title: 'فیلمە دۆبلاژکراوەکانی کوردی',
              items: _kurdishMovies,
              cardWidth: 125,
              cardHeight: 180,
            ),

            // TMDB Popular Movies Row
            if (_popularTmdb.isNotEmpty)
              MediaRow(
                title: 'فیلمە بەناوبانگەکانی جیهان (TMDB)',
                items: _popularTmdb,
                cardWidth: 125,
                cardHeight: 180,
              ),

            // Grid of All Kurdish Movies
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: const Text(
                'تەواوی فیلمە کوردییەکان',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _kurdishMovies.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return MediaCard(
                    item: _kurdishMovies[index],
                    showTitle: true,
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

