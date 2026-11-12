import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/media_item.dart';
import '../theme/netflix_theme.dart';
import '../screens/detail_screen.dart';
import '../screens/player_screen.dart';

class HeroBanner extends StatelessWidget {
  final MediaItem item;

  const HeroBanner({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = screenHeight * 0.52;

    final imageSrc = item.backdropUrl?.isNotEmpty == true
        ? item.backdropUrl!
        : item.posterUrl;

    return Stack(
      children: [
        // Background Hero Poster
        SizedBox(
          height: heroHeight,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: imageSrc,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            placeholder: (context, url) => Container(
              color: NetflixTheme.netflixDarkGray,
            ),
            errorWidget: (context, url, error) => Container(
              color: NetflixTheme.netflixCardBg,
              child: const Icon(Icons.movie, size: 60, color: Colors.white24),
            ),
          ),
        ),

        // Gradient Mask for Netflix Fade
        Container(
          height: heroHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.transparent,
                NetflixTheme.netflixBlack.withOpacity(0.8),
                NetflixTheme.netflixBlack,
              ],
              stops: const [0.0, 0.35, 0.75, 1.0],
            ),
          ),
        ),

        // Content on Hero
        Positioned(
          left: 16,
          right: 16,
          bottom: 12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Badge Tags
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: NetflixTheme.netflixRed,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      'دۆبلاژکراوی کوردی',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${item.year}',
                    style: const TextStyle(
                      color: NetflixTheme.netflixLightGray,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('•', style: TextStyle(color: Colors.white38)),
                  const SizedBox(width: 6),
                  Text(
                    item.typeLabelKurdish,
                    style: const TextStyle(
                      color: NetflixTheme.netflixLightGray,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Title in Kurdish
              Text(
                item.nameKurdish,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: NetflixTheme.netflixWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 2)),
                  ],
                ),
              ),

              if (item.name != item.nameKurdish) ...[
                const SizedBox(height: 2),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 14),

              // Buttons: My List | Play | Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // My List Button
                  _buildIconBtn(
                    icon: Icons.add,
                    label: 'لیستەکەم',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item.nameKurdish} بۆ لیستەکەت زیادکرا'),
                          duration: const Duration(seconds: 1),
                          backgroundColor: NetflixTheme.netflixDarkGray,
                        ),
                      );
                    },
                  ),

                  // Play Button (Primary White)
                  ElevatedButton.icon(
                    onPressed: () {
                      if (item.streamUrl.isNotEmpty) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PlayerScreen(item: item),
                          ),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(item: item),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.play_arrow, color: Colors.black, size: 24),
                    label: const Text(
                      'پەخشکردن',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  // Info Button
                  _buildIconBtn(
                    icon: Icons.info_outline,
                    label: 'زانیاری',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(item: item),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: NetflixTheme.netflixWhite,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

