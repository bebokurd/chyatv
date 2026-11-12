import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/media_item.dart';
import '../theme/netflix_theme.dart';
import '../services/tmdb_service.dart';
import '../services/lala_service.dart';
import '../widgets/media_card.dart';
import 'player_screen.dart';

class DetailScreen extends StatefulWidget {
  final MediaItem item;

  const DetailScreen({
    super.key,
    required this.item,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late MediaItem _item;
  bool _isLoadingOverview = false;
  List<MediaItem> _similarItems = [];

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _fetchExtraDetails();
    _loadSimilar();
  }

  void _loadSimilar() {
    final all = LalaService().cachedItems;
    _similarItems = all
        .where((m) => m.id != _item.id && m.type == _item.type)
        .take(6)
        .toList();
    if (_similarItems.isEmpty) {
      _similarItems = all.where((m) => m.id != _item.id).take(6).toList();
    }
  }

  Future<void> _fetchExtraDetails() async {
    if (_item.overview != null && _item.overview!.isNotEmpty) return;

    if (_item.imdbId != null && _item.imdbId!.isNotEmpty) {
      setState(() => _isLoadingOverview = true);
      final details = await TMDBService().getDetailsByImdbId(_item.imdbId!);
      if (details != null && mounted) {
        final overview = details['overview']?.toString();
        final backdrop = details['backdrop_path']?.toString();
        final vote = details['vote_average'] != null
            ? double.tryParse(details['vote_average'].toString())
            : null;

        setState(() {
          _item = _item.copyWith(
            overview: overview,
            backdropUrl: backdrop != null
                ? '${TMDBService.imageBaseOriginal}$backdrop'
                : _item.backdropUrl,
            voteAverage: vote ?? _item.voteAverage,
          );
          _isLoadingOverview = false;
        });
      } else if (mounted) {
        setState(() => _isLoadingOverview = false);
      }
    }
  }

  Future<void> _openImdb() async {
    if (_item.imdbId == null) return;
    final url = Uri.parse('https://www.imdb.com/title/${_item.imdbId}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _playStream({EpisodeItem? episode}) {
    if (_item.streamUrl.isEmpty && episode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لینکی پەخش بەردەست نییە بۆ ئەم فیلمە'),
          backgroundColor: NetflixTheme.netflixDarkGray,
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          item: _item,
          episode: episode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageSrc = _item.backdropUrl?.isNotEmpty == true
        ? _item.backdropUrl!
        : _item.posterUrl;

    return Scaffold(
      backgroundColor: NetflixTheme.netflixBlack,
      body: CustomScrollView(
        slivers: [
          // Collapsible Backdrop App Bar
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: NetflixTheme.netflixBlack,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('هاوبەشکردنی ${_item.nameKurdish}'),
                      backgroundColor: NetflixTheme.netflixDarkGray,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: imageSrc,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: NetflixTheme.netflixDarkGray,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: NetflixTheme.netflixCardBg,
                      child: const Icon(Icons.movie, size: 60, color: Colors.white24),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          NetflixTheme.netflixBlack.withOpacity(0.8),
                          NetflixTheme.netflixBlack,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kurdish Title
                  Text(
                    _item.nameKurdish,
                    style: const TextStyle(
                      color: NetflixTheme.netflixWhite,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (_item.name != _item.nameKurdish) ...[
                    const SizedBox(height: 2),
                    Text(
                      _item.name,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Metadata Badges (Year, Type, Dubbed, IMDb)
                  Row(
                    children: [
                      if (_item.isKurdishDubbed) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: NetflixTheme.netflixRed,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            'دۆبلاژکراوی کوردی',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '${_item.year}',
                        style: const TextStyle(
                          color: NetflixTheme.netflixLightGray,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white38),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          _item.typeLabelKurdish,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_item.voteAverage != null && _item.voteAverage! > 0) ...[
                        const Icon(Icons.star, color: NetflixTheme.netflixGold, size: 14),
                        const SizedBox(width: 3),
                        Text(
                          _item.voteAverage!.toStringAsFixed(1),
                          style: const TextStyle(
                            color: NetflixTheme.netflixGold,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (_item.imdbId != null)
                        GestureDetector(
                          onTap: _openImdb,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2B616),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Text(
                              'IMDb',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Main Big Red Play Button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => _playStream(),
                      icon: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
                      label: const Text(
                        'پەخشکردن',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NetflixTheme.netflixRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Overview / Synopsis
                  const Text(
                    'کورتەی چیرۆک',
                    style: TextStyle(
                      color: NetflixTheme.netflixWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (_isLoadingOverview)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: NetflixTheme.netflixRed,
                        ),
                      ),
                    )
                  else
                    Text(
                      _item.overview?.isNotEmpty == true
                          ? _item.overview!
                          : 'چێژ لە بینینی ${_item.nameKurdish} بە کوالیتی بەرز و دۆبلاژی کوردی وەربگرە لەسەر نێتفلیکس کوردی.',
                      style: const TextStyle(
                        color: NetflixTheme.netflixLightGray,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Action Buttons Row (My List, Rate, Share)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionItem(
                        icon: Icons.check,
                        label: 'لە لیستەکەمە',
                        onTap: () {},
                      ),
                      _buildActionItem(
                        icon: Icons.thumb_up_alt_outlined,
                        label: 'بەدڵمە',
                        onTap: () {},
                      ),
                      _buildActionItem(
                        icon: Icons.share_outlined,
                        label: 'هاوبەشی',
                        onTap: () {},
                      ),
                    ],
                  ),

                  const Divider(color: Colors.white12, height: 36),

                  // Episodes Section (for Series)
                  if (_item.isSeries && _item.episodes.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ئەڵقەکان',
                          style: TextStyle(
                            color: NetflixTheme.netflixWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: NetflixTheme.netflixDarkGray,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'وەرزی ۱',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _item.episodes.length,
                      itemBuilder: (context, index) {
                        final ep = _item.episodes[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: NetflixTheme.netflixDarkGray,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: NetflixTheme.netflixCardBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.play_circle_fill,
                                  color: NetflixTheme.netflixRed, size: 28),
                            ),
                            title: Text(
                              'ئەڵقەی ${ep.number}: ${ep.name}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'وەرزی ${ep.season}',
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                            trailing: const Icon(Icons.file_download_outlined,
                                color: Colors.white60, size: 22),
                            onTap: () => _playStream(episode: ep),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],

                  // More Like This Section
                  if (_similarItems.isNotEmpty) ...[
                    const Text(
                      'بەرهەمی هاوشێوە',
                      style: TextStyle(
                        color: NetflixTheme.netflixWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 165,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _similarItems.length,
                        itemBuilder: (context, index) {
                          return MediaCard(
                            item: _similarItems[index],
                            width: 110,
                            height: 165,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

