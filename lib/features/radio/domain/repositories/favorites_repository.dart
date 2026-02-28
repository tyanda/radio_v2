import '../../domain/station.dart';

abstract class FavoritesRepository {
  Future<String?> loadFavorite();
  Future<void> saveFavorite(String? stationName);
  Future<List<Station>> loadStationList();
}
