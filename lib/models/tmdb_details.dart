class CastMember {
  final int id;
  final String name;
  final String character;
  final String? profilePath;

  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  String? get profileUrl => profilePath != null && profilePath!.isNotEmpty
      ? 'https://image.tmdb.org/t/p/w185$profilePath'
      : null;

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      character: json['character']?.toString() ?? '',
      profilePath: json['profile_path']?.toString(),
    );
  }
}

class MediaVideo {
  final String id;
  final String name;
  final String key;
  final String site;
  final String type;

  const MediaVideo({
    required this.id,
    required this.name,
    required this.key,
    required this.site,
    required this.type,
  });

  String get youtubeThumbnail => 'https://img.youtube.com/vi/$key/hqdefault.jpg';
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$key';

  factory MediaVideo.fromJson(Map<String, dynamic> json) {
    return MediaVideo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      key: json['key']?.toString() ?? '',
      site: json['site']?.toString() ?? 'YouTube',
      type: json['type']?.toString() ?? 'Trailer',
    );
  }
}

class MediaImageItem {
  final String filePath;
  final double aspectRatio;
  final int width;
  final int height;

  const MediaImageItem({
    required this.filePath,
    required this.aspectRatio,
    required this.width,
    required this.height,
  });

  String get originalUrl => 'https://image.tmdb.org/t/p/original$filePath';
  String get w500Url => 'https://image.tmdb.org/t/p/w500$filePath';
  String get w780Url => 'https://image.tmdb.org/t/p/w780$filePath';

  factory MediaImageItem.fromJson(Map<String, dynamic> json) {
    return MediaImageItem(
      filePath: json['file_path']?.toString() ?? '',
      aspectRatio: double.tryParse(json['aspect_ratio']?.toString() ?? '1.77') ?? 1.77,
      width: json['width'] is int ? json['width'] : int.tryParse(json['width']?.toString() ?? '0') ?? 0,
      height: json['height'] is int ? json['height'] : int.tryParse(json['height']?.toString() ?? '0') ?? 0,
    );
  }
}

class TMDBExtendedDetails {
  final int id;
  final String title;
  final String? tagline;
  final String? overview;
  final String? releaseDate;
  final int? runtime;
  final String? status;
  final double? voteAverage;
  final int? voteCount;
  final List<String> genres;
  final List<CastMember> cast;
  final List<MediaVideo> videos;
  final List<MediaImageItem> backdrops;
  final List<MediaImageItem> posters;

  const TMDBExtendedDetails({
    required this.id,
    required this.title,
    this.tagline,
    this.overview,
    this.releaseDate,
    this.runtime,
    this.status,
    this.voteAverage,
    this.voteCount,
    this.genres = const [],
    this.cast = const [],
    this.videos = const [],
    this.backdrops = const [],
    this.posters = const [],
  });

  factory TMDBExtendedDetails.fromJson(Map<String, dynamic> json) {
    // Genres
    List<String> parsedGenres = [];
    if (json['genres'] is List) {
      parsedGenres = (json['genres'] as List)
          .whereType<Map<String, dynamic>>()
          .map((g) => g['name']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }

    // Credits / Cast
    List<CastMember> parsedCast = [];
    final credits = json['credits'];
    if (credits is Map<String, dynamic> && credits['cast'] is List) {
      parsedCast = (credits['cast'] as List)
          .whereType<Map<String, dynamic>>()
          .map((c) => CastMember.fromJson(c))
          .toList();
    }

    // Videos
    List<MediaVideo> parsedVideos = [];
    final videosObj = json['videos'];
    if (videosObj is Map<String, dynamic> && videosObj['results'] is List) {
      parsedVideos = (videosObj['results'] as List)
          .whereType<Map<String, dynamic>>()
          .map((v) => MediaVideo.fromJson(v))
          .where((v) => v.key.isNotEmpty && v.site.toLowerCase() == 'youtube')
          .toList();
    }

    // Images
    List<MediaImageItem> parsedBackdrops = [];
    List<MediaImageItem> parsedPosters = [];
    final imagesObj = json['images'];
    if (imagesObj is Map<String, dynamic>) {
      if (imagesObj['backdrops'] is List) {
        parsedBackdrops = (imagesObj['backdrops'] as List)
            .whereType<Map<String, dynamic>>()
            .map((b) => MediaImageItem.fromJson(b))
            .where((b) => b.filePath.isNotEmpty)
            .toList();
      }
      if (imagesObj['posters'] is List) {
        parsedPosters = (imagesObj['posters'] as List)
            .whereType<Map<String, dynamic>>()
            .map((p) => MediaImageItem.fromJson(p))
            .where((p) => p.filePath.isNotEmpty)
            .toList();
      }
    }

    return TMDBExtendedDetails(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      tagline: json['tagline']?.toString(),
      overview: json['overview']?.toString(),
      releaseDate: json['release_date']?.toString() ?? json['first_air_date']?.toString(),
      runtime: json['runtime'] is int ? json['runtime'] : int.tryParse(json['runtime']?.toString() ?? '0'),
      status: json['status']?.toString(),
      voteAverage: json['vote_average'] != null ? double.tryParse(json['vote_average'].toString()) : null,
      voteCount: json['vote_count'] is int ? json['vote_count'] : int.tryParse(json['vote_count']?.toString() ?? '0'),
      genres: parsedGenres,
      cast: parsedCast,
      videos: parsedVideos,
      backdrops: parsedBackdrops,
      posters: parsedPosters,
    );
  }
}

