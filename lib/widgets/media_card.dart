import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/media_item.dart';
import '../theme/netflix_theme.dart';
import '../screens/detail_screen.dart';

class MediaCard extends StatelessWidget {
  final MediaItem item;
  final double width;
  final double height;
  final bool showTitle;

  const MediaCard({
    super.key,
    required this.item,
    this.width = 115,
    this.height = 165,
    this.showTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailScreen(item: item),
          ),
        );
      },
      child: Container(
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: item.posterUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: NetflixTheme.netflixDarkGray,
                        child: const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(NetflixTheme.netflixRed),
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: NetflixTheme.netflixCardBg,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.movie_creation_outlined,
                                color: NetflixTheme.netflixMutedGray, size: 28),
                            const SizedBox(height: 4),
                            Text(
                              item.nameKurdish,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Netflix subtle gradient overlay on card bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 45,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    // Kurdish Dubbed or HD Tag
                    if (item.isKurdishDubbed)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: NetflixTheme.netflixRed,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            'کوردی',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    else
                      Positioned(
                        top: 5,
                        left: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.white30, width: 0.5),
                          ),
                          child: const Text(
                            'HD',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (showTitle) ...[
              const SizedBox(height: 4),
              Text(
                item.nameKurdish,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: NetflixTheme.netflixWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${item.year} • ${item.typeLabelKurdish}',
                style: const TextStyle(
                  color: NetflixTheme.netflixMutedGray,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

