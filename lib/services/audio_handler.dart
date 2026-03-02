import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sakha_live/core/utils/logger.dart';
import 'dart:async';

class RadioAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  
  // StreamControllers to notify the PlayerNotifier when skip actions are triggered from the notification
  final _nextSubject = StreamController<void>.broadcast();
  final _prevSubject = StreamController<void>.broadcast();

  Stream<void> get onNext => _nextSubject.stream;
  Stream<void> get onPrev => _prevSubject.stream;

  RadioAudioHandler() {
    // Forward playback events to the state stream
    _player.playbackEventStream.map(_transformEvent).listen(playbackState.add);
    
    // Listen to media item changes and update notification metadata
    mediaItem.listen((item) {
      if (item != null) {
        Logger.log("🎵 AudioHandler: MediaItem updated: ${item.title}", tag: 'AudioHandler');
      }
    });
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      processingState: AudioProcessingState.idle,
    ));
  }

  @override
  Future<void> skipToNext() async {
    Logger.log("⏭️ AudioHandler: Skip to next", tag: 'AudioHandler');
    _nextSubject.add(null);
  }

  @override
  Future<void> skipToPrevious() async {
    Logger.log("⏮️ AudioHandler: Skip to previous", tag: 'AudioHandler');
    _prevSubject.add(null);
  }

  Future<void> setVolume(double volume) => _player.setVolume(volume);

  Future<void> setStream(String url, MediaItem item) async {
    mediaItem.add(item);
    try {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
    } catch (e) {
      Logger.error("AudioHandler error: $e", tag: 'AudioHandler');
    }
  }

  void updateMetadata(MediaItem item) {
    mediaItem.add(item);
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  // Getter for the player to allow direct control if needed, 
  // but better to use AudioHandler methods.
  AudioPlayer get player => _player;
}
