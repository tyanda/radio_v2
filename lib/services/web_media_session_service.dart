// lib/services/web_media_session_service.dart
// Заглушка для Media Session API
// Полная реализация будет добавлена позже

/// Заглушка для Media Session API
/// Реализация будет добавлена после обновления package:web
class WebMediaSessionService {
  static WebMediaSessionService? _instance;

  WebMediaSessionService._internal();

  factory WebMediaSessionService() {
    _instance ??= WebMediaSessionService._internal();
    return _instance!;
  }

  /// Инициализация (пока не реализована)
  void init() {
    // Not implemented yet
  }

  /// Обновление метаданных (пока не реализована)
  void updateMetadata({
    required String title,
    required String artist,
    String? artwork,
    String? album,
  }) {
    // Not implemented yet
  }

  /// Обновление состояния воспроизведения (пока не реализована)
  void setPlaybackState({
    required bool isPlaying,
    bool hasNext = true,
    bool hasPrevious = true,
    double? playbackRate,
  }) {
    // Not implemented yet
  }

  /// Проверка поддержки API (всегда false пока)
  static bool get isSupported => false;

  /// Проверка инициализации
  bool get isInitialized => false;
}
