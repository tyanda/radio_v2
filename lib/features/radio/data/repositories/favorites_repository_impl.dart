import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/station.dart';
import '../datasources/station_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  static const String _favoriteKey = 'favorite_station';

  @override
  Future<String?> loadFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_favoriteKey);
  }

  @override
  Future<void> saveFavorite(String? stationName) async {
    final prefs = await SharedPreferences.getInstance();
    if (stationName == null) {
      await prefs.remove(_favoriteKey);
    } else {
      await prefs.setString(_favoriteKey, stationName);
    }
  }

  @override
  Future<List<Station>> loadStationList() async {
    return StationDataSource.getStationList();
  }
}
