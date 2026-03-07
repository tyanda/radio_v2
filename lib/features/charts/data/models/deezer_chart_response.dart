/// Модель ответа Deezer Chart API
/// https://api.deezer.com/chart/0/tracks
class DeezerChartResponse {
  final List<DeezerTrack> tracks;

  DeezerChartResponse({required this.tracks});

  factory DeezerChartResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List? ?? [];
    return DeezerChartResponse(
      tracks: data
          .map((track) => DeezerTrack.fromJson(track as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Модель трека из Deezer API
class DeezerTrack {
  final String id;
  final String title;
  final String artist;
  final String coverUrl;
  final String previewUrl;
  final int duration;
  final int rank;

  DeezerTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.previewUrl,
    required this.duration,
    required this.rank,
  });

  factory DeezerTrack.fromJson(Map<String, dynamic> json) {
    final artist = json['artist'] as Map<String, dynamic>? ?? {};
    final album = json['album'] as Map<String, dynamic>? ?? {};

    // Получаем обложку большего размера (640x640 вместо 250x250)
    String coverUrl =
        album['cover_xl'] as String? ??
        album['cover_big'] as String? ??
        album['cover_medium'] as String? ??
        album['cover_small'] as String? ??
        '';

    return DeezerTrack(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      artist: artist['name'] as String? ?? '',
      coverUrl: coverUrl,
      previewUrl: json['preview'] as String? ?? '',
      duration: json['duration'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
    );
  }
}
