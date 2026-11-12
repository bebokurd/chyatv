import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/lala_service.dart';
import '../services/tmdb_service.dart';
import '../widgets/media_card.dart';
import '../widgets/media_row.dart';
import '../theme/netflix_theme.dart';

class AnimeScreen extends StatefulWidget {
  const AnimeScreen({super.key});

  @override
  State<AnimeScreen> createState() => _AnimeScreenState();
}

class _AnimeScreenState extends State<AnimeScreen> {
  final LalaService _lala = LalaService();
  final TMDBService _tmdb = TMDBService();

  List<MediaItem> _kurdishAnime = [];
  List<MediaItem> _tmdbAnime = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnime();
  }

  Future<void> _loadAnime() async {
    setState(() => _isLoading = true);
    final all = await _lala.fetchCatalog();
    final anime = all.where((m) => m.type.toLowerCase() == 'anime').toList();
    final tmdbAnimeList = await _tmdb.getAnime();

    if (mounted) {
      setState(() {
        _kurdishAnime = anime;
        _tmdbAnime = tmdbAnimeList;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _kurdishAnime.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: NetflixTheme.netflixRed),
      );
    }

    return Scaffold(
      backgroundColor: NetflixTheme.netflixBlack,
      appBar: AppBar(
        title: const Text(
          'ئەنیمێ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: NetflixTheme.netflixBlack,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kurdish Dubbed Anime
            MediaRow(
              title: 'ئەنیمێ بە کوردی',
              items: _kurdishAnime,
              cardWidth: 125,
              cardHeight: 180,
            ),

            // TMDB Anime Series Row
            if (_tmdbAnime.isNotEmpty)
              MediaRow(
                title: 'بەناوبانگترین زنجیرە ئەنیمێکان (TMDB)',
                items: _tmdbAnime,
                cardWidth: 125,
                cardHeight: 180,
              ),

            // All Anime Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: const Text(
                'تەواوی ئەنیمێیەکان',
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
                itemCount: _kurdishAnime.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return MediaCard(
                    item: _kurdishAnime[index],
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

