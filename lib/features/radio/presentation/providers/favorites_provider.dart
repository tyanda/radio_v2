import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/station.dart';
import '../../domain/repositories/favorites_repository.dart';

class FavoritesState {
  final List<Station> stations;
  final String? favoriteStationName;
  final bool isLoading;
  final String? error;

  FavoritesState({
    required this.stations,
    this.favoriteStationName,
    this.isLoading = false,
    this.error,
  });

  FavoritesState copyWith({
    List<Station>? stations,
    String? favoriteStationName,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      stations: stations ?? this.stations,
      favoriteStationName: favoriteStationName ?? this.favoriteStationName,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  Station? get favoriteStation {
    if (favoriteStationName == null) return null;
    return stations.firstWhere(
      (station) => station.name == favoriteStationName,
      orElse: () => stations.first,
    );
  }
}

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final FavoritesRepository _repository;

  FavoritesNotifier(this._repository)
    : super(FavoritesState(stations: [], isLoading: true)) {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final stations = await _repository.loadStationList();
      final favoriteName = await _repository.loadFavorite();
      state = FavoritesState(
        stations: stations,
        favoriteStationName: favoriteName,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load data: $e',
        isLoading: false,
      );
    }
  }

  Future<void> setFavorite(Station station) async {
    try {
      await _repository.saveFavorite(station.name);
      state = state.copyWith(favoriteStationName: station.name);
    } catch (e) {
      state = state.copyWith(error: 'Failed to save favorite: $e');
    }
  }

  Future<void> clearFavorite() async {
    try {
      await _repository.saveFavorite(null);
      state = state.copyWith(favoriteStationName: null);
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear favorite: $e');
    }
  }

  Future<void> toggleFavorite(String stationName) async {
    try {
      if (state.favoriteStationName == stationName) {
        await clearFavorite();
      } else {
        final station = state.stations.firstWhere(
          (s) => s.name == stationName,
          orElse: () => throw Exception('Station not found: $stationName'),
        );
        await setFavorite(station);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to toggle favorite: $e');
    }
  }
}
