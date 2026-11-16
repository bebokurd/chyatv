import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/tmdb_details.dart';
import '../theme/netflix_theme.dart';

class CastList extends StatelessWidget {
  final List<CastMember> cast;

  const CastList({super.key, required this.cast});

  @override
  Widget build(BuildContext context) {
    if (cast.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'ئەکتەرە سەرەکییەکان (Top Billed Cast)',
            style: TextStyle(
              color: NetflixTheme.netflixWhite,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 155,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: cast.length > 20 ? 20 : cast.length,
            itemBuilder: (context, index) {
              final member = cast[index];
              return Container(
                width: 95,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: NetflixTheme.netflixDarkGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      child: SizedBox(
                        height: 95,
                        width: double.infinity,
                        child: member.profileUrl != null
                            ? CachedNetworkImage(
                                imageUrl: member.profileUrl!,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  color: NetflixTheme.netflixCardBg,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: NetflixTheme.netflixRed,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  color: NetflixTheme.netflixCardBg,
                                  child: const Icon(Icons.person, color: Colors.white24, size: 40),
                                ),
                              )
                            : Container(
                                color: NetflixTheme.netflixCardBg,
                                child: const Icon(Icons.person, color: Colors.white24, size: 40),
                              ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Actor Name
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        member.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Character Name
                    if (member.character.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          member.character,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

