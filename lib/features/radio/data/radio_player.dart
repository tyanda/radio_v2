import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import '../../../core/utils/logger.dart';

/// Класс для управления воспроизведением радио-потока
class RadioPlayer {
  final AudioPlayer player;

  RadioPlayer() : player = AudioPlayer();

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

      // Проверка валидности URL
      final uri = Uri.parse(url);
      Logger.log(
        "RadioPlayer: Parsed URI scheme: ${uri.scheme}, host: ${uri.host}",
        tag: 'RadioPlayer',
      );

      await player.setAudioSource(
        AudioSource.uri(
          uri,
          tag: MediaItem(
            id: url,
            title: title,
            artist: artist,
            album: album ?? 'Sakha Radio',
            artUri: artUri != null ? Uri.parse(artUri) : null,
          ),
        ),
      );

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
        "RadioPlayer: Attempting to play, current player state: ${player.playerState}",
        tag: 'RadioPlayer',
      );
      await player.play();
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
      await player.pause();
      Logger.log("RadioPlayer: Paused", tag: 'RadioPlayer');
    } catch (e) {
      Logger.error("RadioPlayer: Pause failed: $e", tag: 'RadioPlayer');
      rethrow;
    }
  }

  Future<void> stop() async {
    try {
      Logger.log(
        "RadioPlayer: Stopping player, current state: ${player.playerState}",
        tag: 'RadioPlayer',
      );
      await player.stop();
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
      await player.setVolume(clampedVolume);
      Logger.log(
        "RadioPlayer: Volume set to $clampedVolume",
        tag: 'RadioPlayer',
      );
    } catch (e) {
      Logger.error("RadioPlayer: Set volume failed: $e", tag: 'RadioPlayer');
      rethrow;
    }
  }

  /// Скорость воспроизведения (0.5 - 2.0)
  Future<void> setSpeed(double speed) async {
    try {
      final clampedSpeed = speed.clamp(0.5, 2.0);
      await player.setSpeed(clampedSpeed);
      Logger.log("RadioPlayer: Speed set to $clampedSpeed", tag: 'RadioPlayer');
    } catch (e) {
      Logger.error("RadioPlayer: Set speed failed: $e", tag: 'RadioPlayer');
      rethrow;
    }
  }

  /// Получить текущее состояние плеера
  PlayerState get currentState => player.playerState;

  /// Поток изменений состояния плеера
  Stream<PlayerState> get playerStateStream => player.playerStateStream;

  /// Поток изменений состояния обработки (буферизация)
  Stream<ProcessingState> get processingStateStream =>
      player.processingStateStream;

  /// Очистка ресурсов
  Future<void> dispose() async {
    try {
      await player.stop();
      await player.dispose();
      Logger.log("RadioPlayer: Disposed", tag: 'RadioPlayer');
    } catch (e) {
      Logger.error("RadioPlayer: Dispose failed: $e", tag: 'RadioPlayer');
    }
  }
}
