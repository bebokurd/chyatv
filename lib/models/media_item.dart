class EpisodeItem {
  final int season;
  final int number;
  final String name;
  final String streamUrl;

  const EpisodeItem({
    required this.season,
    required this.number,
    required this.name,
    required this.streamUrl,
  });

  factory EpisodeItem.fromJson(Map<String, dynamic> json) {
    return EpisodeItem(
      season: json['season'] is int ? json['season'] : int.tryParse(json['season']?.toString() ?? '1') ?? 1,
      number: json['number'] is int ? json['number'] : int.tryParse(json['number']?.toString() ?? '1') ?? 1,
      name: json['name']?.toString() ?? 'Episode',
      streamUrl: json['streamUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'season': season,
      'number': number,
      'name': name,
      'streamUrl': streamUrl,
    };
  }
}

class MediaItem {
  final int id;
  final String name;
  final String nameKurdish;
  final String type; // 'movie', 'series', 'kids', 'anime'
  final int year;
  final String? imdbId;
  final String? sourceName;
  final String posterUrl;
  final String? backdropUrl;
  final String streamUrl;
  final String? embedUrl;
  final String? overview;
  final double? voteAverage;
  final List<EpisodeItem> episodes;
  final bool isKurdishDubbed;

  const MediaItem({
    required this.id,
    required this.name,
    required this.nameKurdish,
    required this.type,
    required this.year,
    this.imdbId,
    this.sourceName,
    required this.posterUrl,
    this.backdropUrl,
    required this.streamUrl,
    this.embedUrl,
    this.overview,
    this.voteAverage,
    this.episodes = const [],
    this.isKurdishDubbed = true,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    final rawEpisodes = json['episodes'];
    List<EpisodeItem> parsedEpisodes = [];
    if (rawEpisodes is List) {
      parsedEpisodes = rawEpisodes
          .whereType<Map<String, dynamic>>()
          .map((e) => EpisodeItem.fromJson(e))
          .toList();
    }

    return MediaItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      nameKurdish: json['nameKurdish']?.toString() ?? json['name']?.toString() ?? '',
      type: (json['type']?.toString().toLowerCase()) ?? 'movie',
      year: json['year'] is int ? json['year'] : int.tryParse(json['year']?.toString() ?? '2024') ?? 2024,
      imdbId: json['imdbId']?.toString(),
      sourceName: json['sourceName']?.toString(),
      posterUrl: json['posterUrl']?.toString() ?? '',
      backdropUrl: json['backdropUrl']?.toString() ?? json['posterUrl']?.toString(),
      streamUrl: json['streamUrl']?.toString() ?? '',
      embedUrl: json['embedUrl']?.toString(),
      overview: json['overview']?.toString(),
      voteAverage: json['voteAverage'] != null
          ? double.tryParse(json['voteAverage'].toString())
          : null,
      episodes: parsedEpisodes,
      isKurdishDubbed: json['isKurdishDubbed'] as bool? ?? true,
    );
  }

  MediaItem copyWith({
    int? id,
    String? name,
    String? nameKurdish,
    String? type,
    int? year,
    String? imdbId,
    String? sourceName,
    String? posterUrl,
    String? backdropUrl,
    String? streamUrl,
    String? embedUrl,
    String? overview,
    double? voteAverage,
    List<EpisodeItem>? episodes,
    bool? isKurdishDubbed,
  }) {
    return MediaItem(
      id: id ?? this.id,
      name: name ?? this.name,
      nameKurdish: nameKurdish ?? this.nameKurdish,
      type: type ?? this.type,
      year: year ?? this.year,
      imdbId: imdbId ?? this.imdbId,
      sourceName: sourceName ?? this.sourceName,
      posterUrl: posterUrl ?? this.posterUrl,
      backdropUrl: backdropUrl ?? this.backdropUrl,
      streamUrl: streamUrl ?? this.streamUrl,
      embedUrl: embedUrl ?? this.embedUrl,
      overview: overview ?? this.overview,
      voteAverage: voteAverage ?? this.voteAverage,
      episodes: episodes ?? this.episodes,
      isKurdishDubbed: isKurdishDubbed ?? this.isKurdishDubbed,
    );
  }

  String get typeLabelKurdish {
    switch (type.toLowerCase()) {
      case 'movie':
        return 'فیلم';
      case 'series':
        return 'زنجیرە';
      case 'kids':
        return 'منداڵان';
      case 'anime':
        return 'ئەنیمێ';
      default:
        return 'تایبەت';
    }
  }

  bool get isSeries => type.toLowerCase() == 'series' || episodes.isNotEmpty;
}

