/// Модель элемента чарта (песня или реклама)
class ChartItem {
  final String id;
  final ChartItemType type;
  final String title;
  final String? artist; // Только для песен
  final int? rank; // Только для песен
  final String? coverUrl; // Обложка для песен
  final String? previewUrl; // URL для прослушивания (отрывок песни)
  final String? videoUrl; // URL видео для рекламы
  final String? actionText; // Текст кнопки действия
  final String? duration; // Длительность рекламы

  const ChartItem({
    required this.id,
    required this.type,
    required this.title,
    this.artist,
    this.rank,
    this.coverUrl,
    this.previewUrl,
    this.videoUrl,
    this.actionText,
    this.duration,
  });

  bool get isSong => type == ChartItemType.song;
  bool get isVideoAd => type == ChartItemType.videoAd;
}

enum ChartItemType { song, videoAd }
