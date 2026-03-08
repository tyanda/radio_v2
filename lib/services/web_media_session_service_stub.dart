// lib/services/web_media_session_service_stub.dart
// Stub для мобильных платформ (Android/iOS)

/// Stub класс для мобильных платформ
/// На мобильных используется audio_service вместо Media Session API
class WebMediaSessionService {
  static WebMediaSessionService? _instance;

  WebMediaSessionService._internal();

  factory WebMediaSessionService() {
    _instance ??= WebMediaSessionService._internal();
    return _instance!;
  }

  /// Инициализация (пустая реализация для мобильных)
  void init() {
    // Nothing to do on mobile - uses audio_service
  }

  /// Обновление метаданных (пустая реализация для мобильных)
  void updateMetadata({
    required String title,
    required String artist,
    required String? artwork,
    String? album,
  }) {
    // Nothing to do on mobile - uses audio_service
  }

  /// Обновление состояния воспроизведения (пустая реализация для мобильных)
  void setPlaybackState({
    required bool isPlaying,
    bool hasNext = true,
    bool hasPrevious = true,
    double? playbackRate,
  }) {
    // Nothing to do on mobile - uses audio_service
  }

  /// Проверка поддержки API (всегда false для мобильных)
  static bool get isSupported => false;

  /// Проверка инициализации
  bool get isInitialized => false;
}
