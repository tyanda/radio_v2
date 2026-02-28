import '../../domain/station.dart';

abstract class FavoritesRepository {
  Future<Set<String>> loadFavorites();
  Future<void> saveFavorites(Set<String> stationNames);
  Future<List<Station>> loadStationList();
}
