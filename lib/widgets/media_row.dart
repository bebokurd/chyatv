import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../theme/netflix_theme.dart';
import 'media_card.dart';

class MediaRow extends StatelessWidget {
  final String title;
  final List<MediaItem> items;
  final double cardWidth;
  final double cardHeight;
  final VoidCallback? onSeeAll;

  const MediaRow({
    super.key,
    required this.title,
    required this.items,
    this.cardWidth = 115,
    this.cardHeight = 165,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: NetflixTheme.netflixWhite,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                if (onSeeAll != null)
                  GestureDetector(
                    onTap: onSeeAll,
                    child: const Text(
                      'هەمووی',
                      style: TextStyle(
                        color: NetflixTheme.netflixRed,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: cardHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return MediaCard(
                  item: items[index],
                  width: cardWidth,
                  height: cardHeight,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

