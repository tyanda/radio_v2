import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:sakha_live/core/utils/logger.dart';
import 'dart:async';

class RadioAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  // StreamControllers to notify the PlayerNotifier when skip actions are triggered from the notification
  final _nextSubject = StreamController<void>.broadcast();
  final _prevSubject = StreamController<void>.broadcast();

  Stream<void> get onNext => _nextSubject.stream;
  Stream<void> get onPrev => _prevSubject.stream;

  // Состояние для восстановления после звонка
  bool _wasPlayingBeforeInterruption = false;
  double _volumeBeforeInterruption = 0.65;
  bool _isHandlingInterruption = false;

  RadioAudioHandler() {
    // Forward playback events to the state stream
    _player.playbackEventStream.map(_transformEvent).listen(playbackState.add);

    // Listen to media item changes and update notification metadata
    mediaItem.listen((item) {
      if (item != null) {
        Logger.log(
          "🎵 AudioHandler: MediaItem updated: ${item.title}",
          tag: 'AudioHandler',
        );
      }
    });

    // Инициализация Audio Session и Audio Focus
    _initAudioSession();
  }

  /// Инициализация аудио сессии и подписка на события Audio Focus
  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;

      // Настройка аудио сессии для медиа-контента
      await session.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.duckOthers,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          avAudioSessionRouteSharingPolicy:
              AVAudioSessionRouteSharingPolicy.defaultPolicy,
          avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.music,
            usage: AndroidAudioUsage.media,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
          androidWillPauseWhenDucked: true,
        ),
      );

      Logger.log("🎧 Audio Session configured", tag: 'AudioHandler');

      // Подписка на события прерывания (звонки, уведомления)
      session.interruptionEventStream.listen((event) {
        _handleAudioInterruption(event);
      });

      Logger.log("🎧 Audio Focus listeners added", tag: 'AudioHandler');
    } catch (e) {
      Logger.error("Failed to init Audio Session: $e", tag: 'AudioHandler');
    }
  }

  /// Обработка прерываний аудио (звонки, будильники, уведомления)
  void _handleAudioInterruption(AudioInterruptionEvent event) {
    Logger.log(
      "📞 Audio Interruption: ${event.begin ? 'Begin' : 'End'}, type: ${event.type}",
      tag: 'AudioHandler',
    );

    if (event.begin) {
      // Начало прерывания (звонок начался)
      _wasPlayingBeforeInterruption = _player.playing;
      _volumeBeforeInterruption = _player.volume;
      _isHandlingInterruption = true;

      if (_wasPlayingBeforeInterruption) {
        Logger.log("⏸️ Pausing for interruption", tag: 'AudioHandler');
        pause();
      }
    } else {
      // Конец прерывания (звонок закончился)
      _isHandlingInterruption = false;

      if (_wasPlayingBeforeInterruption) {
        Logger.log("▶️ Resuming after interruption", tag: 'AudioHandler');
        _resumeWithFadeIn();
      }
    }
  }

  /// Возобновление воспроизведения с плавным нарастанием громкости (Fade-in)
  Future<void> _resumeWithFadeIn() async {
    try {
      // Сбрасываем громкость до минимума
      await _player.setVolume(0.0);

      // Запускаем воспроизведение
      await play();

      // Плавное нарастание громкости в течение 2 секунд
      const fadeDuration = Duration(seconds: 2);
      const steps = 100;
      final stepDuration = fadeDuration ~/ steps;

      for (int i = 0; i <= steps; i++) {
        if (!_isHandlingInterruption && _player.playing) {
          final targetVolume = _volumeBeforeInterruption * (i / steps);
          await _player.setVolume(targetVolume);
          await Future.delayed(stepDuration);
        } else {
          // Прервано новым событием
          break;
        }
      }

      Logger.log("🎵 Fade-in completed", tag: 'AudioHandler');
    } catch (e) {
      Logger.error("Fade-in error: $e", tag: 'AudioHandler');
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    playbackState.add(
      playbackState.value.copyWith(
        playing: false,
        processingState: AudioProcessingState.idle,
      ),
    );
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

  /// Очистка ресурсов для предотвращения утечки памяти
  void dispose() {
    _nextSubject.close();
    _prevSubject.close();
    _player.dispose();
  }
}
