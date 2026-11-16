import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/tmdb_details.dart';
import '../theme/netflix_theme.dart';

class MediaSection extends StatefulWidget {
  final List<MediaVideo> videos;
  final List<MediaImageItem> backdrops;
  final List<MediaImageItem> posters;

  const MediaSection({
    super.key,
    required this.videos,
    required this.backdrops,
    required this.posters,
  });

  @override
  State<MediaSection> createState() => _MediaSectionState();
}

class _MediaSectionState extends State<MediaSection> {
  int _selectedTab = 0; // 0: Most Popular, 1: Videos, 2: Backdrops, 3: Posters

  Future<void> _launchYoutube(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openImageViewer(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(color: NetflixTheme.netflixRed),
                ),
                errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white30, size: 48),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasVideos = widget.videos.isNotEmpty;
    final hasBackdrops = widget.backdrops.isNotEmpty;
    final hasPosters = widget.posters.isNotEmpty;

    if (!hasVideos && !hasBackdrops && !hasPosters) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'میدیا و ڤیدیۆکان (Media)',
            style: TextStyle(
              color: NetflixTheme.netflixWhite,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Tabs Header
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _buildTabChip(0, 'Most Popular (باوترین)'),
              if (hasVideos) _buildTabChip(1, 'Videos ${widget.videos.length}'),
              if (hasBackdrops) _buildTabChip(2, 'Backdrops ${widget.backdrops.length}'),
              if (hasPosters) _buildTabChip(3, 'Posters ${widget.posters.length}'),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Tab Content
        if (_selectedTab == 0) _buildMostPopularView(),
        if (_selectedTab == 1) _buildVideosView(),
        if (_selectedTab == 2) _buildBackdropsView(),
        if (_selectedTab == 3) _buildPostersView(),
      ],
    );
  }

  Widget _buildTabChip(int index, String label) {
    final isSelected = _selectedTab == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedColor: NetflixTheme.netflixDarkGray,
        backgroundColor: Colors.transparent,
        side: BorderSide(
          color: isSelected ? NetflixTheme.netflixRed : Colors.white24,
          width: isSelected ? 1.5 : 0.8,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onSelected: (_) => setState(() => _selectedTab = index),
      ),
    );
  }

  // Most Popular Tab (Featured Video + Top Backdrops)
  Widget _buildMostPopularView() {
    final topVideo = widget.videos.isNotEmpty ? widget.videos.first : null;
    final topBackdrops = widget.backdrops.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (topVideo != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => _launchYoutube(topVideo.youtubeUrl),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 170,
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: topVideo.youtubeThumbnail,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: NetflixTheme.netflixCardBg),
                        errorWidget: (_, __, ___) => Container(color: NetflixTheme.netflixCardBg),
                      ),
                    ),
                    Container(color: Colors.black38),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: NetflixTheme.netflixRed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 12,
                      left: 12,
                      child: Text(
                        topVideo.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (topBackdrops.isNotEmpty) ...[
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: topBackdrops.length,
              itemBuilder: (context, index) {
                final b = topBackdrops[index];
                return GestureDetector(
                  onTap: () => _openImageViewer(b.originalUrl),
                  child: Container(
                    width: 180,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        imageUrl: b.w500Url,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: NetflixTheme.netflixCardBg),
                        errorWidget: (_, __, ___) => Container(color: NetflixTheme.netflixCardBg),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  // Videos Tab
  Widget _buildVideosView() {
    return SizedBox(
      height: 145,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: widget.videos.length,
        itemBuilder: (context, index) {
          final v = widget.videos[index];
          return GestureDetector(
            onTap: () => _launchYoutube(v.youtubeUrl),
            child: Container(
              width: 190,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 105,
                          width: double.infinity,
                          child: CachedNetworkImage(
                            imageUrl: v.youtubeThumbnail,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: NetflixTheme.netflixCardBg),
                            errorWidget: (_, __, ___) => Container(color: NetflixTheme.netflixCardBg),
                          ),
                        ),
                        Container(color: Colors.black26),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: NetflixTheme.netflixRed,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                        ),
                        Positioned(
                          top: 5,
                          left: 5,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              v.type,
                              style: const TextStyle(color: Colors.white, fontSize: 9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    v.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Backdrops Tab
  Widget _buildBackdropsView() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: widget.backdrops.length,
        itemBuilder: (context, index) {
          final b = widget.backdrops[index];
          return GestureDetector(
            onTap: () => _openImageViewer(b.originalUrl),
            child: Container(
              width: 200,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: b.w500Url,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: NetflixTheme.netflixCardBg),
                  errorWidget: (_, __, ___) => Container(color: NetflixTheme.netflixCardBg),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Posters Tab
  Widget _buildPostersView() {
    return SizedBox(
      height: 175,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: widget.posters.length,
        itemBuilder: (context, index) {
          final p = widget.posters[index];
          return GestureDetector(
            onTap: () => _openImageViewer(p.originalUrl),
            child: Container(
              width: 115,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: p.w500Url,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: NetflixTheme.netflixCardBg),
                  errorWidget: (_, __, ___) => Container(color: NetflixTheme.netflixCardBg),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

