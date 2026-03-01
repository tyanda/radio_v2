# Riverpod Providers

## Создание providers для управления состоянием

### Базовый Provider

```dart
// lib/features/radio/providers/radio_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final radioRepositoryProvider = Provider<RadioRepository>((ref) {
  return RadioRepository();
});

final radioProvider = StreamNotifierProvider<RadioNotifier, RadioState>((ref) {
  return RadioNotifier(ref.read(radioRepositoryProvider));
});

class RadioState {
  final List<RadioStation> stations;
  final bool isLoading;
  final String? error;
  
  RadioState({
    this.stations = const [],
    this.isLoading = false,
    this.error,
  });
}

class RadioNotifier extends StreamNotifier<RadioState> {
  final RadioRepository repository;
  
  RadioNotifier(this.repository);
  
  @override
  Stream<RadioState> build() async* {
    yield RadioState(isLoading: true);
    try {
      await for (final stations in repository.watchStations()) {
        yield RadioState(stations: stations);
      }
    } catch (e) {
      yield RadioState(error: e.toString());
    }
  }
}
```

### StateNotifierProvider

```dart
final playerProvider = StateNotifierProvider<AudioNotifier, AudioState>((ref) {
  return AudioNotifier();
});

class AudioState {
  final bool isPlaying;
  final double volume;
  final String? currentStationId;
  
  AudioState({
    this.isPlaying = false,
    this.volume = 1.0,
    this.currentStationId,
  });
}

class AudioNotifier extends StateNotifier<AudioState> {
  AudioNotifier() : super(AudioState());
  
  void play(String stationId) {
    state = AudioState(
      isPlaying: true,
      currentStationId: stationId,
    );
  }
  
  void pause() {
    state = state.copyWith(isPlaying: false);
  }
  
  void setVolume(double volume) {
    state = state.copyWith(volume: volume);
  }
}
```

### Использование в виджете

```dart
class RadioPlayer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radioState = ref.watch(radioProvider);
    final audioNotifier = ref.read(playerProvider.notifier);
    
    if (radioState.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (radioState.error != null) {
      return Text('Ошибка: ${radioState.error}');
    }
    
    return Column(
      children: [
        for (final station in radioState.stations)
          StationTile(
            station: station,
            onTap: () => audioNotifier.play(station.id),
          ),
      ],
    );
  }
}
```

### Тестирование

```dart
void main() {
  test('должен_загружать_станции', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    
    final mockRepository = MockRadioRepository();
    when(mockRepository.watchStations())
        .thenAnswer((_) => Stream.value([testStation]));
    
    final state = container.read(radioProvider);
    await container.pump();
    
    expect(state.stations, hasLength(1));
  });
}
```

## Паттерны

1. **Provider для синглтонов** (repositories, services)
2. **StreamNotifierProvider для потоков** (Firebase streams)
3. **StateNotifierProvider для сложного состояния** (audio player)
4. **FutureProvider для однократной загрузки** (initial data)
