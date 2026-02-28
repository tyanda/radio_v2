import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import '../../../core/utils/logger.dart';
import 'web_radio_player.dart';

/// Класс для управления воспроизведением радио-потока
/// На Web используется HTML5 Audio API, на других платформах - just_audio
class RadioPlayer {
  final AudioPlayer? player;
  final RadioPlayerInterface? webPlayer;
  final bool isWeb;
  
  // Поток для метаданных треков
  final _mediaItemController = StreamController<MediaItem?>.broadcast();
  StreamSubscription? _icyMetadataSubscription;

  RadioPlayer()
      : isWeb = kIsWeb,
        player = kIsWeb ? null : AudioPlayer(),
        webPlayer = kIsWeb ? createRadioPlayer() : null;

  /// Поток метаданных текущего трека
  Stream<MediaItem?> get mediaItemStream {
    if (isWeb) {
      return _mediaItemController.stream;
    }
    // Для не-Web платформ, возвращаем наш контроллер
    // just_audio не имеет mediaItemStream в старых версиях
    return _mediaItemController.stream;
  }
  
  /// Обновление метаданных трека
  void _updateMediaItem(MediaItem? mediaItem) {
    _mediaItemController.add(mediaItem);
  }
  
  /// Подписка на ICY-метаданные из потока
  void _subscribeToIcyMetadata() {
    if (isWeb || player == null) return;
    
    _icyMetadataSubscription?.cancel();
    _icyMetadataSubscription = player!.icyMetadataStream.listen((icyMetadata) {
      if (icyMetadata != null && icyMetadata.info != null) {
        final title = icyMetadata.info!.title;
        Logger.log(
          "🎵 ICY Metadata: title=$title",
          tag: 'RadioPlayer',
        );
        
        if (title != null && title.isNotEmpty) {
          _updateMediaItem(MediaItem(
            id: 'icy_metadata',
            title: title,
            artist: null,
            album: 'Sakha Radio',
          ));
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
      Logger.log(
        "RadioPlayer: Stream details - Title: $title, Artist: $artist",
        tag: 'RadioPlayer',
      );

      if (isWeb) {
        // Web: используем HTML5 Audio
        await webPlayer!.loadStream(url);
        // Для Web эмулируем метаданные
        _mediaItemController.add(MediaItem(
          id: url,
          title: title,
          artist: artist,
          album: album ?? 'Sakha Radio',
          artUri: artUri != null ? Uri.parse(artUri) : null,
        ));
      } else {
        // Mobile/Desktop: используем just_audio
        final uri = Uri.parse(url);
        Logger.log(
          "RadioPlayer: Parsed URI scheme: ${uri.scheme}, host: ${uri.host}",
          tag: 'RadioPlayer',
        );

        final mediaItem = MediaItem(
          id: url,
          title: title,
          artist: artist,
          album: album ?? 'Sakha Radio',
          artUri: artUri != null ? Uri.parse(artUri) : null,
        );

        await player!.setAudioSource(
          AudioSource.uri(uri, tag: mediaItem),
        );

        // Обновляем метаданные
        _updateMediaItem(mediaItem);
        
        // Подписываемся на ICY-метаданные из потока
        _subscribeToIcyMetadata();
      }

      Logger.log("RadioPlayer: Stream loaded successfully", tag: 'RadioPlayer');
    } on PlayerException catch (e) {
      Logger.error(
        "RadioPlayer: PlayerException - Code: ${e.code}, Message: ${e.message}",
        tag: 'RadioPlayer',
      );
      Logger.error(
        "RadioPlayer: Full error details - ${e.toString()}",
        tag: 'RadioPlayer',
      );
      rethrow;
    } on FormatException catch (e) {
      Logger.error(
        "RadioPlayer: URL FormatException - ${e.message}",
        tag: 'RadioPlayer',
      );
      rethrow;
    } catch (e) {
      Logger.error("RadioPlayer: Unexpected error: $e", tag: 'RadioPlayer');
      Logger.error(
        "RadioPlayer: Error type: ${e.runtimeType}",
        tag: 'RadioPlayer',
      );
      rethrow;
    }
  }

  /// Управление воспроизведением
  Future<void> play() async {
    try {
      Logger.log(
        "RadioPlayer: Attempting to play, isWeb: $isWeb",
        tag: 'RadioPlayer',
      );
      
      if (isWeb) {
        // Для Web используем resume() который может перезагрузить поток
        await webPlayer!.resume();
      } else {
        await player!.play();
      }
      
      Logger.log("RadioPlayer: Playing", tag: 'RadioPlayer');
    } catch (e) {
      Logger.error("RadioPlayer: Play failed: $e", tag: 'RadioPlayer');
      Logger.error(
        "RadioPlayer: Play error details - ${e.toString()}",
        tag: 'RadioPlayer',
      );
      rethrow;
    }
  }

  Future<void> pause() async {
    try {
      Logger.log("RadioPlayer: Pausing", tag: 'RadioPlayer');
      if (isWeb) {
        await webPlayer!.pause();
      } else {
        await player!.pause();
      }
      Logger.log("RadioPlayer: Paused", tag: 'RadioPlayer');
    } catch (e) {
      Logger.error("RadioPlayer: Pause failed: $e", tag: 'RadioPlayer');
      rethrow;
    }
  }

  Future<void> stop() async {
    try {
      Logger.log("RadioPlayer: Stopping player", tag: 'RadioPlayer');
      if (isWeb) {
        await webPlayer!.stop();
      } else {
        await player!.stop();
      }
      Logger.log("RadioPlayer: Stopped", tag: 'RadioPlayer');
    } catch (e) {
      Logger.error("RadioPlayer: Stop failed: $e", tag: 'RadioPlayer');
      Logger.error(
        "RadioPlayer: Stop error details - ${e.toString()}",
        tag: 'RadioPlayer',
      );
      rethrow;
    }
  }

  /// Установка громкости (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      if (isWeb) {
        await webPlayer!.setVolume(clampedVolume);
      } else {
        await player!.setVolume(clampedVolume);
      }
      Logger.log(
        "RadioPlayer: Volume set to $clampedVolume",
        tag: 'RadioPlayer',
      );
    } catch (e) {
      Logger.error("RadioPlayer: Set volume failed: $e", tag: 'RadioPlayer');
      rethrow;
    }
  }

  /// Скорость воспроизведения (0.5 - 2.0) - только для не-Web
  Future<void> setSpeed(double speed) async {
    if (isWeb) {
      Logger.log("RadioPlayer: setSpeed not supported on Web", tag: 'RadioPlayer');
      return;
    }
    
    try {
      final clampedSpeed = speed.clamp(0.5, 2.0);
      await player!.setSpeed(clampedSpeed);
      Logger.log("RadioPlayer: Speed set to $clampedSpeed", tag: 'RadioPlayer');
    } catch (e) {
      Logger.error("RadioPlayer: Set speed failed: $e", tag: 'RadioPlayer');
      rethrow;
    }
  }

  /// Получить текущее состояние плеера
  bool get isPlaying => isWeb ? webPlayer!.isPlaying : player!.playerState.playing;

  /// Получить текущее состояние обработки
  ProcessingState get processingState => 
      isWeb ? ProcessingState.ready : player!.processingState;

  /// Поток изменений состояния плеера
  Stream<PlayerState> get playerStateStream {
    if (isWeb) {
      return webPlayer!.playerStateStream.map((playing) => 
          PlayerState(playing, ProcessingState.ready));
    }
    return player!.playerStateStream;
  }

  /// Поток изменений состояния обработки (буферизация)
  Stream<ProcessingState> get processingStateStream {
    if (isWeb) {
      return webPlayer!.bufferingStateStream.map((isBuffering) =>
          isBuffering ? ProcessingState.buffering : ProcessingState.ready);
    }
    return player!.processingStateStream;
  }

  /// Очистка ресурсов
  Future<void> dispose() async {
    try {
      Logger.log("RadioPlayer: Disposing", tag: 'RadioPlayer');
      if (isWeb) {
        await webPlayer!.dispose();
        await _icyMetadataSubscription?.cancel();
        await _mediaItemController.close();
      } else {
        await player!.stop();
        await player!.dispose();
        await _icyMetadataSubscription?.cancel();
        await _mediaItemController.close();
      }
      Logger.log("RadioPlayer: Disposed", tag: 'RadioPlayer');
    } catch (e) {
      Logger.error("RadioPlayer: Dispose failed: $e", tag: 'RadioPlayer');
    }
  }
}
