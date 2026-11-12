import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/lala_service.dart';
import '../services/tmdb_service.dart';
import '../widgets/media_card.dart';
import '../widgets/media_row.dart';
import '../theme/netflix_theme.dart';

class KidsScreen extends StatefulWidget {
  const KidsScreen({super.key});

  @override
  State<KidsScreen> createState() => _KidsScreenState();
}

class _KidsScreenState extends State<KidsScreen> {
  final LalaService _lala = LalaService();
  final TMDBService _tmdb = TMDBService();

  List<MediaItem> _kurdishKids = [];
  List<MediaItem> _tmdbKids = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKids();
  }

  Future<void> _loadKids() async {
    setState(() => _isLoading = true);
    final all = await _lala.fetchCatalog();
    final kids = all.where((m) => m.type.toLowerCase() == 'kids').toList();
    final tmdbAnim = await _tmdb.getKidsAndAnimation();

    if (mounted) {
      setState(() {
        _kurdishKids = kids;
        _tmdbKids = tmdbAnim;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _kurdishKids.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: NetflixTheme.netflixRed),
      );
    }

    return Scaffold(
      backgroundColor: NetflixTheme.netflixBlack,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.amber[700],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'KIDS',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'بەشی منداڵان',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: NetflixTheme.netflixBlack,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kurdish Dubbed Kids
            MediaRow(
              title: 'کارتۆنی دۆبلاژکراوی کوردی',
              items: _kurdishKids,
              cardWidth: 125,
              cardHeight: 180,
            ),

            // TMDB Animation Row
            if (_tmdbKids.isNotEmpty)
              MediaRow(
                title: 'ئەنیمەیشن و کارتۆنی جیهانی (TMDB)',
                items: _tmdbKids,
                cardWidth: 125,
                cardHeight: 180,
              ),

            // All Kids Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: const Text(
                'هەموو بەرهەمەکانی منداڵان',
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
                itemCount: _kurdishKids.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return MediaCard(
                    item: _kurdishKids[index],
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

