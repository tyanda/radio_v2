import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/station.dart';
import '../datasources/local_station_source.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  static const String _favoritesKey = 'favorite_stations_v2';

  @override
  Future<Set<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    return favorites.toSet();
  }

  @override
  Future<void> saveFavorites(Set<String> stationNames) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, stationNames.toList());
  }

  @override
  Future<List<Station>> loadStationList() async {
    return StationDataSource.getStationList();
  }
}
