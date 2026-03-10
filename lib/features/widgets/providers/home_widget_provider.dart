import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repository/home_widget_repository.dart';
import '../data/models/widget_data.dart';

/// Провайдер репозитория виджетов
final homeWidgetRepositoryProvider = Provider<HomeWidgetRepository>((ref) {
  return HomeWidgetRepository();
});

/// Провайдер состояния виджета
final homeWidgetStateProvider =
    StateNotifierProvider<HomeWidgetNotifier, WidgetStationData>((ref) {
      return HomeWidgetNotifier(ref.watch(homeWidgetRepositoryProvider));
    });

class HomeWidgetNotifier extends StateNotifier<WidgetStationData> {
  final HomeWidgetRepository _repository;

  HomeWidgetNotifier(this._repository) : super(WidgetStationData.empty);

  /// Обновление данных виджета из состояния плеера
  Future<void> updateFromPlayerState({
    required String stationName,
    String? currentTrack,
    String? albumArt,
    bool isPlaying = false,
  }) async {
    // Обновляем состояние
    state = WidgetStationData(
      stationName: stationName,
      currentTrack: currentTrack,
      albumArt: albumArt,
      isPlaying: isPlaying,
      lastUpdated: DateTime.now(),
    );

    // Обновляем виджет
    await _repository.updateWidgetData(
      stationName: stationName,
      currentTrack: currentTrack,
      albumArt: albumArt,
      isPlaying: isPlaying,
    );
  }

  /// Инициализация виджета
  Future<void> initialize() async {
    await _repository.setupCallback();
  }
}
