import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/media_item.dart';
import '../services/lala_service.dart';
import '../services/tmdb_service.dart';
import '../widgets/media_card.dart';
import '../widgets/media_row.dart';
import '../theme/netflix_theme.dart';
import 'detail_screen.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  final LalaService _lala = LalaService();
  final TMDBService _tmdb = TMDBService();

  List<MediaItem> _kurdishSeries = [];
  List<MediaItem> _tmdbSeries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSeries();
  }

  Future<void> _loadSeries() async {
    setState(() => _isLoading = true);
    final all = await _lala.fetchCatalog();
    final kurdSeries = all.where((m) => m.isSeries).toList();
    final tmdbTv = await _tmdb.getTrendingTV();

    if (mounted) {
      setState(() {
        _kurdishSeries = kurdSeries;
        _tmdbSeries = tmdbTv;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _kurdishSeries.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: NetflixTheme.netflixRed),
      );
    }

    return Scaffold(
      backgroundColor: NetflixTheme.netflixBlack,
      appBar: AppBar(
        title: const Text(
          'زنجیرەکان',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: NetflixTheme.netflixBlack,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kurdish Dubbed Series Row
            MediaRow(
              title: 'زنجیرە دۆبلاژکراوەکان',
              items: _kurdishSeries,
              cardWidth: 130,
              cardHeight: 190,
            ),

            // Featured Series Cards with Episode info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: const Text(
                'زنجیرە کوردییەکان لەگەڵ ئەڵقەکان',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _kurdishSeries.length,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemBuilder: (context, index) {
                final item = _kurdishSeries[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(item: item),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: NetflixTheme.netflixDarkGray,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(
                            width: 70,
                            height: 100,
                            child: CachedNetworkImage(
                              imageUrl: item.posterUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: NetflixTheme.netflixCardBg,
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: NetflixTheme.netflixCardBg,
                                child: const Icon(Icons.tv, color: Colors.white54),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.nameKurdish,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.name,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: NetflixTheme.netflixRed,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      item.episodes.isNotEmpty
                                          ? '${item.episodes.length} ئەڵقە'
                                          : 'تەواوی وەرز',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${item.year}',
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            color: Colors.white38, size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),

            // TMDB Trending TV Shows
            if (_tmdbSeries.isNotEmpty) ...[
              const SizedBox(height: 10),
              MediaRow(
                title: 'زنجیرە بەناوبانگەکانی جیهان (TMDB)',
                items: _tmdbSeries,
                cardWidth: 120,
                cardHeight: 175,
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
