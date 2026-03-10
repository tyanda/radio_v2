// ignore_for_file: experimental_member_use

import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/repositories/radio_repository.dart';

class RadioRepositoryImpl implements RadioRepository {
  final AudioPlayer _player;

  RadioRepositoryImpl() : _player = AudioPlayer();

  @override
  Future<void> playStream({
    required String url,
    required String title,
    required String artist,
    required String artwork,
  }) async {
    try {
      Logger.log(
        "RadioRepositoryImpl: Loading stream: $url",
        tag: 'RadioRepositoryImpl',
      );
      Logger.log(
        "RadioRepositoryImpl: Stream details - Title: $title, Artist: $artist",
        tag: 'RadioRepositoryImpl',
      );

      final uri = Uri.parse(url);
      Logger.log(
        "RadioRepositoryImpl: Parsed URI scheme: ${uri.scheme}, host: ${uri.host}",
        tag: 'RadioRepositoryImpl',
      );

      await _player.setAudioSource(
        LockCachingAudioSource(
          Uri.parse(url),
          tag: MediaItem(
            id: url,
            title: title,
            artist: artist,
            artUri: Uri.tryParse(artwork),
          ),
        ),
      );

      Logger.log(
        "RadioRepositoryImpl: Stream loaded successfully",
        tag: 'RadioRepositoryImpl',
      );
    } on PlayerException catch (e) {
      Logger.log(
        "RadioRepositoryImpl: PlayerException occurred: ${e.message}, code: ${e.code}",
        tag: 'RadioRepositoryImpl',
      );
      rethrow;
    } catch (e) {
      Logger.log(
        "RadioRepositoryImpl: Unexpected error during stream loading: $e",
        tag: 'RadioRepositoryImpl',
      );
      rethrow;
    }
  }

  @override
  Future<void> play() async {
    try {
      Logger.log(
        "RadioRepositoryImpl: Attempting to play, current player state: ${_player.playerState}",
        tag: 'RadioRepositoryImpl',
      );
      await _player.play();
      Logger.log("RadioRepositoryImpl: Playing", tag: 'RadioRepositoryImpl');
    } catch (e) {
      Logger.log(
        "RadioRepositoryImpl: Error during play: $e",
        tag: 'RadioRepositoryImpl',
      );
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _player.pause();
      Logger.log("RadioRepositoryImpl: Paused", tag: 'RadioRepositoryImpl');
    } catch (e) {
      Logger.log(
        "RadioRepositoryImpl: Error during pause: $e",
        tag: 'RadioRepositoryImpl',
      );
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    try {
      Logger.log(
        "RadioRepositoryImpl: Stopping player, current state: ${_player.playerState}",
        tag: 'RadioRepositoryImpl',
      );
      await _player.stop();
      Logger.log("RadioRepositoryImpl: Stopped", tag: 'RadioRepositoryImpl');
    } catch (e) {
      Logger.log(
        "RadioRepositoryImpl: Error during stop: $e",
        tag: 'RadioRepositoryImpl',
      );
      rethrow;
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _player.setVolume(clampedVolume);
      Logger.log(
        "RadioRepositoryImpl: Volume set to $clampedVolume",
        tag: 'RadioRepositoryImpl',
      );
    } catch (e) {
      Logger.log(
        "RadioRepositoryImpl: Error during volume setting: $e",
        tag: 'RadioRepositoryImpl',
      );
      rethrow;
    }
  }

  @override
  Future<void> setSpeed(double speed) async {
    try {
      final clampedSpeed = speed.clamp(0.5, 2.0);
      await _player.setSpeed(clampedSpeed);
      Logger.log(
        "RadioRepositoryImpl: Speed set to $clampedSpeed",
        tag: 'RadioRepositoryImpl',
      );
    } catch (e) {
      Logger.log(
        "RadioRepositoryImpl: Error during speed setting: $e",
        tag: 'RadioRepositoryImpl',
      );
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _player.stop();
      await _player.dispose();
      Logger.log("RadioRepositoryImpl: Disposed", tag: 'RadioRepositoryImpl');
    } catch (e) {
      Logger.log(
        "RadioRepositoryImpl: Error during disposal: $e",
        tag: 'RadioRepositoryImpl',
      );
      rethrow;
    }
  }

  // Методы для получения состояния плеера
  PlayerState get currentState => _player.playerState;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Stream<ProcessingState> get processingStateStream =>
      _player.processingStateStream;
}
