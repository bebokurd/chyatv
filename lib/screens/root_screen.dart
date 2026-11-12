import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/netflix_top_bar.dart';
import '../theme/netflix_theme.dart';
import 'home_screen.dart';
import 'movies_screen.dart';
import 'series_screen.dart';
import 'kids_screen.dart';
import 'anime_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;
  final ScrollController _homeScrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _homeScrollController.addListener(() {
      if (mounted) {
        setState(() {
          _scrollOffset = _homeScrollController.offset;
        });
      }
    });
  }

  @override
  void dispose() {
    _homeScrollController.dispose();
    super.dispose();
  }

  void _onCategorySelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NetflixTheme.netflixBlack,
      body: Stack(
        children: [
          // Current Tab Page
          IndexedStack(
            index: _currentIndex,
            children: [
              HomeScreen(
                onSwitchToMovies: () => _onCategorySelected(1),
                onSwitchToSeries: () => _onCategorySelected(2),
                onSwitchToKids: () => _onCategorySelected(3),
                onSwitchToAnime: () => _onCategorySelected(4),
              ),
              const MoviesScreen(),
              const SeriesScreen(),
              const KidsScreen(),
              const AnimeScreen(),
            ],
          ),

          // Floating Netflix Top Bar (Visible on Home Tab)
          if (_currentIndex == 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: NetflixTopBar(
                selectedIndex: _currentIndex,
                scrollOffset: _scrollOffset,
                onCategorySelected: _onCategorySelected,
              ),
            ),
        ],
      ),

      // Bottom Navigation Bar (iOS / Netflix Style)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onCategorySelected,
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house_fill),
            label: 'سەرەکی',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.film_fill),
            label: 'فیلم',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.tv_fill),
            label: 'زنجیرە',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.sparkles),
            label: 'منداڵان',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.animation),
            label: 'ئەنیمێ',
          ),
        ],
      ),
    );
  }
}

