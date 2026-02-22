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
      Logger.log("RadioPlayer: Loading stream: $url");

      await player.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: url,
            title: title,
            artist: artist,
            album: album ?? 'Sakha Radio',
            artUri: artUri != null ? Uri.parse(artUri) : null,
          ),
        ),
      );

      Logger.log("RadioPlayer: Stream loaded successfully");
    } on PlayerException catch (e) {
      Logger.error("RadioPlayer: PlayerException - Code: ${e.code}, Message: ${e.message}");
      rethrow;
    } catch (e) {
      Logger.error("RadioPlayer: Unexpected error: $e");
      rethrow;
    }
  }

  /// Управление воспроизведением
  Future<void> play() async {
    try {
      await player.play();
      Logger.log("RadioPlayer: Playing");
    } catch (e) {
      Logger.error("RadioPlayer: Play failed: $e");
      rethrow;
    }
  }

  Future<void> pause() async {
    try {
      await player.pause();
      Logger.log("RadioPlayer: Paused");
    } catch (e) {
      Logger.error("RadioPlayer: Pause failed: $e");
      rethrow;
    }
  }

  Future<void> stop() async {
    try {
      await player.stop();
      Logger.log("RadioPlayer: Stopped");
    } catch (e) {
      Logger.error("RadioPlayer: Stop failed: $e");
      rethrow;
    }
  }

  /// Установка громкости (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await player.setVolume(clampedVolume);
      Logger.log("RadioPlayer: Volume set to $clampedVolume");
    } catch (e) {
      Logger.error("RadioPlayer: Set volume failed: $e");
      rethrow;
    }
  }

  /// Скорость воспроизведения (0.5 - 2.0)
  Future<void> setSpeed(double speed) async {
    try {
      final clampedSpeed = speed.clamp(0.5, 2.0);
      await player.setSpeed(clampedSpeed);
      Logger.log("RadioPlayer: Speed set to $clampedSpeed");
    } catch (e) {
      Logger.error("RadioPlayer: Set speed failed: $e");
      rethrow;
    }
  }

  /// Получить текущее состояние плеера
  PlayerState get currentState => player.playerState;

  /// Поток изменений состояния плеера
  Stream<PlayerState> get playerStateStream => player.playerStateStream;

  /// Очистка ресурсов
  Future<void> dispose() async {
    try {
      await player.stop();
      await player.dispose();
      Logger.log("RadioPlayer: Disposed");
    } catch (e) {
      Logger.error("RadioPlayer: Dispose failed: $e");
    }
  }
}
