import 'package:flutter/material.dart';
import '../theme/netflix_theme.dart';
import '../screens/search_screen.dart';

class NetflixTopBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onCategorySelected;
  final double scrollOffset;

  const NetflixTopBar({
    super.key,
    required this.selectedIndex,
    required this.onCategorySelected,
    this.scrollOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    // Opacity increases as user scrolls down
    final double opacity = (scrollOffset / 120).clamp(0.0, 0.95);

    final categories = [
      'سەرەکی',
      'فیلم',
      'زنجیرە',
      'منداڵان',
      'ئەنیمێ',
    ];

    return Container(
      color: NetflixTheme.netflixBlack.withOpacity(opacity),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row: Logo, Search, Cast/Profile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                children: [
                  // Netflix "N" Logo / Brand
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: const Text(
                      'NETFLIX',
                      style: TextStyle(
                        color: NetflixTheme.netflixRed,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Search Icon
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white, size: 24),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SearchScreen(),
                        ),
                      );
                    },
                  ),

                  // Kurdish flag or User Avatar
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: NetflixTheme.netflixRed,
                    ),
                    child: const Center(
                      child: Icon(Icons.person, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Category Bar Row (سەرەکی, فیلم, زنجیرە, منداڵان, ئەنیمێ)
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedIndex == index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        categories[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: NetflixTheme.netflixDarkGray,
                      backgroundColor: Colors.transparent,
                      side: BorderSide(
                        color: isSelected ? NetflixTheme.netflixRed : Colors.white24,
                        width: isSelected ? 1.5 : 0.8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onSelected: (_) => onCategorySelected(index),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

