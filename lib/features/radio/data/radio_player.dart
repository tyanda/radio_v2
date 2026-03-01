import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import '../../../core/utils/logger.dart';
import 'web_radio_player.dart';
import '../../../services/audio_handler.dart';

/// Класс для управления воспроизведением радио-потока
/// На Web используется HTML5 Audio API, на других платформах - just_audio через audio_service
class RadioPlayer {
  final AudioPlayer? player;
  final RadioPlayerInterface? webPlayer;
  final bool isWeb;
  final RadioAudioHandler? audioHandler;

  // Поток для метаданных треков
  final _mediaItemController = StreamController<MediaItem?>.broadcast();
  StreamSubscription? _icyMetadataSubscription;

  RadioPlayer({this.audioHandler})
    : isWeb = kIsWeb,
      player = kIsWeb ? null : (audioHandler?.player ?? AudioPlayer()),
      webPlayer = kIsWeb ? createRadioPlayer() : null;

  /// Поток метаданных текущего трека
  Stream<MediaItem?> get mediaItemStream {
    return _mediaItemController.stream;
  }

  /// Обновление метаданных трека
  void _updateMediaItem(MediaItem? mediaItem) {
    _mediaItemController.add(mediaItem);
    // Обновляем метаданные в системном уведомлении через audioHandler
    if (!isWeb && audioHandler != null && mediaItem != null) {
      audioHandler!.mediaItem.add(mediaItem);
    }
  }

  /// Подписка на ICY-метаданные из потока
  void _subscribeToIcyMetadata() {
    if (isWeb || player == null) return;

    _icyMetadataSubscription?.cancel();
    _icyMetadataSubscription = player!.icyMetadataStream.listen((icyMetadata) {
      if (icyMetadata != null && icyMetadata.info != null) {
        final title = icyMetadata.info!.title;
        Logger.log("🎵 ICY Metadata: title=$title", tag: 'RadioPlayer');

        if (title != null && title.isNotEmpty) {
          // Парсим "Artist - Title" формат
          String? artist;
          String trackTitle = title;

          final separatorIndex = title.indexOf(' - ');
          if (separatorIndex != -1) {
            artist = title.substring(0, separatorIndex).trim();
            trackTitle = title.substring(separatorIndex + 3).trim();
          }

          _updateMediaItem(
            MediaItem(
              id: 'icy_metadata',
              title: trackTitle,
              artist: artist,
              album: 'Sakha Radio',
              artUri: _mediaItemController.stream.value?.artUri,
            ),
          );
        }
      }
    });
  }

  /// Подключение к потоку радио с метаданными
  Future<void> playStream({
    required String url,
    required String title,
    required String artist,
    String? album,
    String? artUri,
  }) async {
    try {
      Logger.log("RadioPlayer: Loading stream: $url", tag: 'RadioPlayer');
      
      final mediaItem = MediaItem(
        id: url,
        title: title,
        artist: artist,
        album: album ?? 'Sakha Radio',
        artUri: artUri != null ? Uri.parse(artUri) : null,
      );

      if (isWeb) {
        // Web: используем HTML5 Audio
        await webPlayer!.loadStream(url);
        // Для Web эмулируем метаданные
        _updateMediaItem(mediaItem);
      } else {
        // Mobile/Desktop: используем just_audio через audioHandler
        final uri = Uri.parse(url);
        
        // Сначала устанавливаем метаданные в уведомление
        if (audioHandler != null) {
          audioHandler!.mediaItem.add(mediaItem);
        }

        await player!.setAudioSource(AudioSource.uri(uri, tag: mediaItem));

        // Обновляем локальные метаданные
        _updateMediaItem(mediaItem);

        // Подписываемся на ICY-метаданные из потока
        _subscribeToIcyMetadata();
      }

      Logger.log("RadioPlayer: Stream loaded successfully", tag: 'RadioPlayer');
    } catch (e) {
      Logger.error("RadioPlayer error: $e", tag: 'RadioPlayer');
      rethrow;
    }
  }

  /// Управление воспроизведением
  Future<void> play() async {
    if (isWeb) {
      await webPlayer!.resume();
    } else {
      await player!.play();
    }
  }

  Future<void> pause() async {
    if (isWeb) {
      await webPlayer!.pause();
    } else {
      await player!.pause();
    }
  }

  Future<void> stop() async {
    if (isWeb) {
      await webPlayer!.stop();
    } else {
      await player!.stop();
    }
  }

  /// Установка громкости (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    final clampedVolume = volume.clamp(0.0, 1.0);
    if (isWeb) {
      await webPlayer!.setVolume(clampedVolume);
    } else {
      await player!.setVolume(clampedVolume);
    }
  }

  /// Скорость воспроизведения (0.5 - 2.0) - только для не-Web
  Future<void> setSpeed(double speed) async {
    if (!isWeb) {
      await player!.setSpeed(speed.clamp(0.5, 2.0));
    }
  }

  /// Получить текущее состояние плеера
  bool get isPlaying =>
      isWeb ? webPlayer!.isPlaying : player!.playerState.playing;

  /// Получить текущее состояние обработки
  ProcessingState get processingState =>
      isWeb ? ProcessingState.ready : player!.processingState;

  /// Поток изменений состояния плеера
  Stream<PlayerState> get playerStateStream {
    if (isWeb) {
      return webPlayer!.playerStateStream.map(
        (playing) => PlayerState(playing, ProcessingState.ready),
      );
    }
    return player!.playerStateStream;
  }

  /// Поток изменений состояния обработки (буферизация)
  Stream<ProcessingState> get processingStateStream {
    if (isWeb) {
      return webPlayer!.bufferingStateStream.map(
        (isBuffering) =>
            isBuffering ? ProcessingState.buffering : ProcessingState.ready,
      );
    }
    return player!.processingStateStream;
  }

  /// Очистка ресурсов
  Future<void> dispose() async {
    await _icyMetadataSubscription?.cancel();
    if (isWeb) {
      await webPlayer!.dispose();
    } else {
      // Мы не диспозим player здесь, так как он общий для audioHandler
      // Но можем остановить поток
      await player!.stop();
    }
    await _mediaItemController.close();
  }
}

// Helper to get value from stream
extension StreamValueExtension<T> on Stream<T> {
  T? get value {
    T? latestValue;
    listen((v) => latestValue = v).cancel();
    return latestValue;
  }
}
