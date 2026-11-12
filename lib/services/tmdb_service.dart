import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/media_item.dart';

class TMDBService {
  static const String apiKey = '8639372f4a9255120794124116c6e93f';
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseW500 = 'https://image.tmdb.org/t/p/w500';
  static const String imageBaseOriginal = 'https://image.tmdb.org/t/p/original';

  static final TMDBService _instance = TMDBService._internal();
  factory TMDBService() => _instance;
  TMDBService._internal();

  final Map<String, Map<String, dynamic>> _imdbCache = {};

  Future<Map<String, dynamic>?> getDetailsByImdbId(String imdbId) async {
    if (_imdbCache.containsKey(imdbId)) {
      return _imdbCache[imdbId];
    }
    try {
      final url = Uri.parse(
          '$baseUrl/find/$imdbId?external_source=imdb_id&api_key=$apiKey');
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final movieResults = data['movie_results'] as List?;
        final tvResults = data['tv_results'] as List?;

        Map<String, dynamic>? match;
        if (movieResults != null && movieResults.isNotEmpty) {
          match = movieResults.first as Map<String, dynamic>;
        } else if (tvResults != null && tvResults.isNotEmpty) {
          match = tvResults.first as Map<String, dynamic>;
        }

        if (match != null) {
          _imdbCache[imdbId] = match;
          return match;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<List<MediaItem>> getTrendingMovies() async {
    return _fetchFromUrl('$baseUrl/trending/movie/week?api_key=$apiKey', 'movie');
  }

  Future<List<MediaItem>> getTrendingTV() async {
    return _fetchFromUrl('$baseUrl/trending/tv/week?api_key=$apiKey', 'series');
  }

  Future<List<MediaItem>> getKidsAndAnimation() async {
    return _fetchFromUrl(
        '$baseUrl/discover/movie?with_genres=16,10751&sort_by=popularity.desc&api_key=$apiKey',
        'kids');
  }

  Future<List<MediaItem>> getAnime() async {
    return _fetchFromUrl(
        '$baseUrl/discover/tv?with_genres=16&with_original_language=ja&sort_by=popularity.desc&api_key=$apiKey',
        'anime');
  }

  Future<List<MediaItem>> searchTMDB(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final encoded = Uri.encodeComponent(query.trim());
      final url = Uri.parse('$baseUrl/search/multi?query=$encoded&api_key=$apiKey');
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List?;
        if (results != null) {
          return results
              .whereType<Map<String, dynamic>>()
              .where((item) =>
                  item['poster_path'] != null &&
                  (item['media_type'] == 'movie' || item['media_type'] == 'tv'))
              .map((item) => _mapTmdbToMediaItem(
                  item, item['media_type'] == 'tv' ? 'series' : 'movie'))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  Future<List<MediaItem>> _fetchFromUrl(String urlString, String defaultType) async {
    try {
      final url = Uri.parse(urlString);
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List?;
        if (results != null) {
          return results
              .whereType<Map<String, dynamic>>()
              .where((item) => item['poster_path'] != null)
              .map((item) => _mapTmdbToMediaItem(item, defaultType))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  MediaItem _mapTmdbToMediaItem(Map<String, dynamic> item, String defaultType) {
    final title = item['title']?.toString() ?? item['name']?.toString() ?? 'Featured';
    final posterPath = item['poster_path']?.toString() ?? '';
    final backdropPath = item['backdrop_path']?.toString();
    final releaseDate = item['release_date']?.toString() ?? item['first_air_date']?.toString() ?? '';
    int year = 2024;
    if (releaseDate.length >= 4) {
      year = int.tryParse(releaseDate.substring(0, 4)) ?? 2024;
    }
    final overview = item['overview']?.toString();
    final voteAverage = item['vote_average'] != null
        ? double.tryParse(item['vote_average'].toString())
        : null;

    final posterUrl = posterPath.isNotEmpty ? '$imageBaseW500$posterPath' : '';
    final backdropUrl = backdropPath != null && backdropPath.isNotEmpty
        ? '$imageBaseOriginal$backdropPath'
        : posterUrl;

    return MediaItem(
      id: item['id'] is int ? item['id'] : int.tryParse(item['id']?.toString() ?? '0') ?? 0,
      name: title,
      nameKurdish: title,
      type: defaultType,
      year: year,
      posterUrl: posterUrl,
      backdropUrl: backdropUrl,
      streamUrl: '',
      overview: overview,
      voteAverage: voteAverage,
      isKurdishDubbed: false,
    );
  }
}

