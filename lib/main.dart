import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/root_screen.dart';
import 'theme/netflix_theme.dart';
import 'services/lala_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Dark Netflix System Overlay Style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: NetflixTheme.netflixBlack,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Pre-fetch catalog
  LalaService().fetchCatalog();

  runApp(const NetflixKurdApp());
}

class NetflixKurdApp extends StatelessWidget {
  const NetflixKurdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CHYA TV',
      debugShowCheckedModeBanner: false,
      theme: NetflixTheme.darkTheme,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const RootScreen(),
    );
  }
}
