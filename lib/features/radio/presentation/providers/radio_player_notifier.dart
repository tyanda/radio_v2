import 'package:riverpod/riverpod.dart';
import '../../domain/repositories/radio_repository.dart';
import '../../data/repositories/radio_repository_impl.dart';
import '../../domain/station.dart';

// Состояние плеера
class PlayerState {
  final bool isPlaying;
  final bool isBuffering;
  final double volume;
  final double speed;
  final Station? currentStation;
  final String? errorMessage;

  PlayerState({
    required this.isPlaying,
    required this.isBuffering,
    required this.volume,
    required this.speed,
    this.currentStation,
    this.errorMessage,
  });

  // Фабричный конструктор для создания начального состояния
  factory PlayerState.initial() {
    return PlayerState(
      isPlaying: false,
      isBuffering: false,
      volume: 1.0,
      speed: 1.0,
      currentStation: null,
      errorMessage: null,
    );
  }

  // Метод для создания копии состояния с измененными параметрами
  PlayerState copyWith({
    bool? isPlaying,
    bool? isBuffering,
    double? volume,
    double? speed,
    Station? currentStation,
    String? errorMessage,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      volume: volume ?? this.volume,
      speed: speed ?? this.speed,
      currentStation: currentStation ?? this.currentStation,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Нотификатор для управления состоянием плеера
class RadioPlayerNotifier extends StateNotifier<PlayerState> {
  final RadioRepository _radioRepository;

  RadioPlayerNotifier(this._radioRepository) : super(PlayerState.initial());

  // Воспроизведение станции
  Future<void> playStation(Station station) async {
    try {
      state = state.copyWith(
        isBuffering: true,
        currentStation: station,
        errorMessage: null,
      );

      await _radioRepository.playStream(
        url: station.url,
        title: station.name,
        artist: station.desc,
        artwork: station.art,
      );

      await _radioRepository.play();

      state = state.copyWith(isPlaying: true, isBuffering: false);
    } catch (e) {
      state = state.copyWith(
        isBuffering: false,
        errorMessage: 'Ошибка воспроизведения: $e',
      );
    }
  }

  // Переключение воспроизведения (play/pause)
  Future<void> togglePlay() async {
    if (state.isBuffering) return;

    if (state.isPlaying) {
      await _radioRepository.pause();
      state = state.copyWith(isPlaying: false);
    } else {
      if (state.currentStation != null) {
        await _radioRepository.play();
        state = state.copyWith(isPlaying: true);
      }
    }
  }

  // Остановка воспроизведения
  Future<void> stop() async {
    await _radioRepository.stop();
    state = state.copyWith(
      isPlaying: false,
      isBuffering: false,
      currentStation: null,
    );
  }

  // Установка громкости
  Future<void> setVolume(double volume) async {
    await _radioRepository.setVolume(volume);
    state = state.copyWith(volume: volume);
  }

  // Установка скорости воспроизведения
  Future<void> setSpeed(double speed) async {
    await _radioRepository.setSpeed(speed);
    state = state.copyWith(speed: speed);
  }

  // Освобождение ресурсов
  Future<void> disposePlayer() async {
    await _radioRepository.dispose();
  }
}

// Провайдер для RadioPlayerNotifier
final radioPlayerProvider =
    StateNotifierProvider<RadioPlayerNotifier, PlayerState>((ref) {
      final repository = RadioRepositoryImpl();
      return RadioPlayerNotifier(repository);
    });
