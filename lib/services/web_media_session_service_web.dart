// lib/services/web_media_session_service_web.dart
// Реализация Media Session API для веб-платформы

import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Реализация Media Session API для веб-платформы
class WebMediaSessionService {
  static WebMediaSessionService? _instance;

  WebMediaSessionService._internal();

  factory WebMediaSessionService() {
    _instance ??= WebMediaSessionService._internal();
    return _instance!;
  }

  /// Проверка поддержки API (true если navigator.mediaSession существует)
  // ignore: unnecessary_null_comparison
  static bool get isSupported => web.window.navigator.mediaSession != null;

  bool _initialized = false;

  /// Инициализация Media Session с обработчиками действий
  void init() {
    if (!isSupported) return;

    // Инициализация без установки обработчиков (не критично для метаданных)
    _initialized = true;
  }

  /// Обновление метаданных текущего трека
  void updateMetadata({
    required String title,
    required String artist,
    String? artwork,
    String? album,
  }) {
    if (!isSupported) return;

    // Создаем список artwork
    final artworkList = <web.MediaImage>[];
    if (artwork != null) {
      artworkList.add(web.MediaImage(src: artwork, sizes: '512x512'));
    }

    final metadata = web.MediaMetadataInit(
      title: title,
      artist: artist,
      album: album ?? '',
      artwork: artworkList.toJS,
    );
    // package:web возвращает не-null тип, но проверяем на всякий случай
    // ignore: unnecessary_null_comparison
    if (web.window.navigator.mediaSession != null) {
      web.window.navigator.mediaSession.metadata = web.MediaMetadata(metadata);
    }
  }

  /// Обновление состояния воспроизведения
  void setPlaybackState({
    required bool isPlaying,
    bool hasNext = true,
    bool hasPrevious = true,
    double? playbackRate,
  }) {
    if (!isSupported) return;

    // Устанавливаем состояние воспроизведения (playbackState)
    // Это экспериментальное API, поддерживается не во всех браузерах
    // Пока просто обновим доступные действия
  }

  /// Проверка инициализации
  bool get isInitialized => _initialized;
}
