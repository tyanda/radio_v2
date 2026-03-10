/// Модель данных для виджета главной станции
class WidgetStationData {
  final String stationName;
  final String? currentTrack;
  final String? albumArt;
  final bool isPlaying;
  final DateTime lastUpdated;

  const WidgetStationData({
    required this.stationName,
    this.currentTrack,
    this.albumArt,
    this.isPlaying = false,
    required this.lastUpdated,
  });

  WidgetStationData copyWith({
    String? stationName,
    String? currentTrack,
    String? albumArt,
    bool? isPlaying,
    DateTime? lastUpdated,
  }) {
    return WidgetStationData(
      stationName: stationName ?? this.stationName,
      currentTrack: currentTrack ?? this.currentTrack,
      albumArt: albumArt ?? this.albumArt,
      isPlaying: isPlaying ?? this.isPlaying,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stationName': stationName,
      'currentTrack': currentTrack ?? '',
      'albumArt': albumArt ?? '',
      'isPlaying': isPlaying ? '1' : '0',
      'lastUpdated': lastUpdated.millisecondsSinceEpoch.toString(),
    };
  }

  factory WidgetStationData.fromMap(Map<String, dynamic> map) {
    return WidgetStationData(
      stationName: map['stationName'] ?? 'SakhaLive',
      currentTrack: map['currentTrack'],
      albumArt: map['albumArt'],
      isPlaying: map['isPlaying'] == '1',
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(
        int.parse(map['lastUpdated'] ?? '0'),
      ),
    );
  }

  static WidgetStationData get empty => WidgetStationData(
    stationName: 'SakhaLive',
    lastUpdated: DateTime.fromMillisecondsSinceEpoch(0),
  );
}
