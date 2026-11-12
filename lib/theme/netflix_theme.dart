import 'package:flutter/material.dart';

class NetflixTheme {
  static const Color netflixBlack = Color(0xFF141414);
  static const Color netflixDarkGray = Color(0xFF1F1F1F);
  static const Color netflixCardBg = Color(0xFF262626);
  static const Color netflixRed = Color(0xFFE50914);
  static const Color netflixWhite = Color(0xFFFFFFFF);
  static const Color netflixLightGray = Color(0xFFB3B3B3);
  static const Color netflixMutedGray = Color(0xFF757575);
  static const Color netflixGold = Color(0xFFFFC107);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: netflixRed,
      scaffoldBackgroundColor: netflixBlack,
      canvasColor: netflixBlack,
      cardColor: netflixDarkGray,
      colorScheme: const ColorScheme.dark(
        primary: netflixRed,
        secondary: netflixRed,
        surface: netflixDarkGray,
        onPrimary: netflixWhite,
        onSecondary: netflixWhite,
        onSurface: netflixWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: netflixWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: netflixWhite),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF121212),
        selectedItemColor: netflixWhite,
        unselectedItemColor: netflixMutedGray,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 10),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: netflixWhite,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: netflixWhite,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: netflixWhite,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: netflixWhite,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: netflixLightGray,
          fontSize: 14,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          color: netflixMutedGray,
          fontSize: 12,
        ),
      ),
    );
  }
}
