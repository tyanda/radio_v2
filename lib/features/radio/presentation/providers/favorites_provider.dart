import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/station.dart';
import '../../domain/repositories/favorites_repository.dart';

class FavoritesState {
  final List<Station> stations;
  final Set<String> favoriteStationNames; // Несколько избранных
  final bool isLoading;
  final String? error;

  FavoritesState({
    required this.stations,
    Set<String>? favoriteStationNames,
    this.isLoading = false,
    this.error,
  }) : favoriteStationNames = favoriteStationNames ?? {};

  FavoritesState copyWith({
    List<Station>? stations,
    Set<String>? favoriteStationNames,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      stations: stations ?? this.stations,
      favoriteStationNames: favoriteStationNames ?? this.favoriteStationNames,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<Station> get favoriteStations {
    return stations
        .where((station) => favoriteStationNames.contains(station.name))
        .toList();
  }

  bool isFavorite(String stationName) {
    return favoriteStationNames.contains(stationName);
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
      final favoriteNames = await _repository.loadFavorites();
      state = FavoritesState(
        stations: stations,
        favoriteStationNames: favoriteNames,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load data: $e',
        isLoading: false,
      );
    }
  }

  Future<void> toggleFavorite(String stationName) async {
    try {
      final newFavorites = Set<String>.from(state.favoriteStationNames);

      if (newFavorites.contains(stationName)) {
        newFavorites.remove(stationName);
      } else {
        newFavorites.add(stationName);
      }

      await _repository.saveFavorites(newFavorites);
      state = state.copyWith(favoriteStationNames: newFavorites);
    } catch (e) {
      state = state.copyWith(error: 'Failed to toggle favorite: $e');
    }
  }

  Future<void> clearAllFavorites() async {
    try {
      await _repository.saveFavorites({});
      state = state.copyWith(favoriteStationNames: {});
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear favorites: $e');
    }
  }
}
