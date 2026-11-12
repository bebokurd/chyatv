import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/media_item.dart';
import 'tmdb_service.dart';

class LalaService {
  static const String lalaUrl = 'https://bebokurd.github.io/lala.json';

  static final LalaService _instance = LalaService._internal();
  factory LalaService() => _instance;
  LalaService._internal();

  List<MediaItem> _cachedItems = [];
  bool _isLoading = false;

  List<MediaItem> get cachedItems => _cachedItems;

  Future<List<MediaItem>> fetchCatalog({bool forceRefresh = false}) async {
    if (_cachedItems.isNotEmpty && !forceRefresh) {
      return _cachedItems;
    }

    if (_isLoading) {
      return _cachedItems.isNotEmpty ? _cachedItems : _getFallbackItems();
    }

    _isLoading = true;

    try {
      final response = await http
          .get(Uri.parse(lalaUrl))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        _cachedItems = data
            .whereType<Map<String, dynamic>>()
            .map((item) => MediaItem.fromJson(item))
            .toList();
      } else {
        if (_cachedItems.isEmpty) {
          _cachedItems = _getFallbackItems();
        }
      }
    } catch (_) {
      if (_cachedItems.isEmpty) {
        _cachedItems = _getFallbackItems();
      }
    } finally {
      _isLoading = false;
    }

    // Background enrich with TMDB
    _enrichItemsWithTMDB();

    return _cachedItems;
  }

  void _enrichItemsWithTMDB() async {
    final tmdb = TMDBService();
    bool updated = false;

    for (int i = 0; i < _cachedItems.length; i++) {
      final item = _cachedItems[i];
      if (item.imdbId != null && item.imdbId!.isNotEmpty && (item.overview == null || item.backdropUrl == item.posterUrl)) {
        final details = await tmdb.getDetailsByImdbId(item.imdbId!);
        if (details != null) {
          final backdropPath = details['backdrop_path']?.toString();
          final overview = details['overview']?.toString();
          final voteAverage = details['vote_average'] != null
              ? double.tryParse(details['vote_average'].toString())
              : null;

          _cachedItems[i] = item.copyWith(
            backdropUrl: backdropPath != null
                ? '${TMDBService.imageBaseOriginal}$backdropPath'
                : item.backdropUrl,
            overview: overview ?? item.overview,
            voteAverage: voteAverage ?? item.voteAverage,
          );
          updated = true;
        }
      }
    }
  }

  List<MediaItem> getMovies() {
    return _cachedItems
        .where((item) => item.type.toLowerCase() == 'movie')
        .toList();
  }

  List<MediaItem> getSeries() {
    return _cachedItems
        .where((item) => item.isSeries)
        .toList();
  }

  List<MediaItem> getKids() {
    return _cachedItems
        .where((item) => item.type.toLowerCase() == 'kids')
        .toList();
  }

  List<MediaItem> getAnime() {
    return _cachedItems
        .where((item) => item.type.toLowerCase() == 'anime')
        .toList();
  }

  List<MediaItem> search(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.trim().toLowerCase();
    return _cachedItems.where((item) {
      return item.name.toLowerCase().contains(q) ||
          item.nameKurdish.toLowerCase().contains(q) ||
          item.year.toString().contains(q);
    }).toList();
  }

  List<MediaItem> _getFallbackItems() {
    return [
      MediaItem(
        id: 24,
        name: "Sinbad: Legend of the Seven Seas",
        nameKurdish: "سینباد ئەفسانەی حەوت دەریاکە",
        type: "kids",
        year: 2003,
        imdbId: "tt0165982",
        posterUrl: "https://image.tmdb.org/t/p/w500/yiW2L1fDiBT7AeWXrykhTNtPrr8.jpg",
        backdropUrl: "https://image.tmdb.org/t/p/original/j8isWEPL3PmmVh8ap3jm75qVF4p.jpg",
        streamUrl: "https://archive.org/download/sinbad-legend-of-the-seven-seas-2003_202608/%D9%81%DB%8C%D9%84%D9%85%20%DA%A9%D8%A7%D8%B1%D8%AA%DB%86%D9%86%DB%8C%20%D8%AF%DB%86%D8%A8%D9%84%D8%A7%DA%98%DA%A9%D8%B1%D8%A7%D9%88%DB%8C%20%DA%A9%D9%88%D8%B1%D8%AF%DB%8C%20%D8%B3%DB%8C%D9%86%D8%A8%D8%A7%D8%AF%20%D8%A6%DB%95%D9%81%D8%B3%D8%A7%D9%86%DB%95%DB%8C%20%D8%AD%DB%95%D9%88%D8%AA%20%D8%AF%DB%95%D8%B1%DB%8C%D8%A7%DA%A9%DB%95%20.%20Sinbad-%20Legend%20of%20the%20Seven%20Seas%202003%20-%20%D8%B1%DB%95%D8%B4%DB%95%D8%A8%D8%A7.mp4",
        overview: "The sailor of legend is framed by the goddess Eris for the theft of the Book of Peace, and must travel to her realm at the end of the world to retrieve it and save the life of his childhood friend Prince Proteus.",
        voteAverage: 7.1,
      ),
      MediaItem(
        id: 23,
        name: "Evim Sensin",
        nameKurdish: "ماڵەکەم تۆی",
        type: "movie",
        year: 2012,
        imdbId: "tt2261505",
        posterUrl: "https://image.tmdb.org/t/p/w500/iTcQK4nPROXM0S20WiBYV7OVu7y.jpg",
        streamUrl: "https://dn721603.ca.archive.org/0/items/evim-sensin-2012/Evim%20Sensin%20%282012%29.ia.mp4",
      ),
      MediaItem(
        id: 19,
        name: "From Up on Poppy Hill",
        nameKurdish: "لە بەرزاییەکانی گردی پۆپی",
        type: "anime",
        year: 2011,
        imdbId: "tt1798188",
        posterUrl: "https://image.tmdb.org/t/p/w500/rRLYX4RZIyloHSJwvZKAhphAjiB.jpg",
        streamUrl: "https://archive.org/download/index492/index.m3u8",
        embedUrl: "https://chatytyoik09-streamu.vercel.app/embed?url=https://archive.org/download/index492/index.m3u8",
      ),
      MediaItem(
        id: 16,
        name: "What's Wrong with Secretary Kim",
        nameKurdish: "کێشەی سکرتێر کیم چییە",
        year: 2018,
        type: "series",
        posterUrl: "https://image.tmdb.org/t/p/w500/qmq7vKRPoK2VHOTeaUdwwe3l5bB.jpg",
        streamUrl: "https://archive.org/download/whats.-wrong.-with.-secretary.-kim.-s-01-e-01-3/.What%27s.Wrong.With.Secretary.Kim.S01E01%20-%20%D8%B1%DB%95%D8%B4%DB%95%D8%A8%D8%A7_3.mp4",
        episodes: const [
          EpisodeItem(
            season: 1,
            number: 1,
            name: "Episode 1",
            streamUrl: "https://archive.org/download/whats.-wrong.-with.-secretary.-kim.-s-01-e-01-3/.What%27s.Wrong.With.Secretary.Kim.S01E01%20-%20%D8%B1%DB%95%D8%B4%DB%95%D8%A8%D8%A7_3.mp4",
          ),
          EpisodeItem(
            season: 1,
            number: 2,
            name: "Episode 2",
            streamUrl: "https://archive.org/download/whats.-wrong.-with.-secretary.-kim.-s-01-e-02-2/.What%27s.Wrong.With.Secretary.Kim.S01E02%20-%20%D8%B1%DB%95%D8%B4%DB%95%D8%A8%D8%A7_2.mp4",
          ),
          EpisodeItem(
            season: 1,
            number: 3,
            name: "Episode 3",
            streamUrl: "https://archive.org/download/whats.-wrong.-with.-secretary.-kim.-s-01-e-03-2/.What%27s.Wrong.With.Secretary.Kim.S01E03%20-%20%D8%B1%DB%95%D8%B4%DB%95%D8%A8%D8%A7_2.mp4",
          ),
        ],
      ),
      MediaItem(
        id: 17,
        name: "The Nun",
        nameKurdish: "ڕاهیبەکە",
        year: 2018,
        type: "movie",
        posterUrl: "https://image.tmdb.org/t/p/w500/sFC1ElvoKGdHJIWRpNB3xWJ9lJA.jpg",
        streamUrl: "https://archive.org/download/the-nun-kurdmovie/The%20Nun%20%E2%80%93%20kurdmovie.mp4",
      ),
      MediaItem(
        id: 15,
        name: "The Flash",
        nameKurdish: "فلاش",
        year: 2023,
        type: "movie",
        posterUrl: "https://image.tmdb.org/t/p/w500/rktDFPbfHfUbArZ6OOOKsXcv0Bm.jpg",
        streamUrl: "https://ia601902.us.archive.org/17/items/output116/output.m3u8",
      ),
      MediaItem(
        id: 20,
        name: "Ben 10: Alien Swarm",
        nameKurdish: "بن تێن",
        type: "movie",
        year: 2009,
        imdbId: "tt1327701",
        posterUrl: "https://image.tmdb.org/t/p/w500/4emrSFOwIlx35OawRcqlwH66TZD.jpg",
        streamUrl: "https://archive.org/download/ben-10-alien-swarm-bluray-hd/Ben%2010%20Alien%20Swarm%20Bluray%20HD.mp4",
      ),
      MediaItem(
        id: 12,
        name: "The Nut Job 2: Nutty by Nature",
        nameKurdish: "دەستەی بەڕووەکان ۲",
        year: 2017,
        type: "kids",
        posterUrl: "https://image.tmdb.org/t/p/w500/xOfdQHNF9TlrdujyAjiKfUhxSXy.jpg",
        streamUrl: "https://archive.org/download/azadedarstan_hd/azadedarstan_hd.mp4",
      ),
      MediaItem(
        id: 13,
        name: "Sahara Hare",
        nameKurdish: "کەروێشکی سەحرا",
        year: 1955,
        type: "kids",
        posterUrl: "https://image.tmdb.org/t/p/w500/uYwlVE4y2yW32H3yjBlY9apiXh2.jpg",
        streamUrl: "https://archive.org/download/output55/output.m3u8",
      ),
      MediaItem(
        id: 18,
        name: "3abo Taxi",
        nameKurdish: "عەبۆ تاکسی",
        type: "movie",
        year: 2010,
        sourceName: "CHYA TV",
        posterUrl: "https://i.ibb.co/gLdyfgcb/Chat-GPT-Image-Aug-1-2026-07-35-17-AM.png",
        streamUrl: "https://archive.org/download/flimi-kurdi-comedy-3abo-taxi/Flimi%20Kurdi%20Comedy%203abo%20Taxi.mp4",
      ),
    ];
  }
}

