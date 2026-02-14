import '../models/weather_model.dart';
import '../models/weather_failure.dart';
import 'weather_service.dart';

abstract class WeatherRepository {
  Future<WeatherData> getCurrentWeather(String city);
  Future<WeatherData> getWeatherForecast(String city);
  Future<WeatherData> getWeatherForecastByCoords(double lat, double lon);
}

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherService _service;

  WeatherRepositoryImpl(this._service);

  @override
  Future<WeatherData> getCurrentWeather(String city) async {
    try {
      final currentData = await _service.getCurrentWeather(city);

      // Для простоты возвращаем частичные данные, так как прогноз не запрашивается
      final combinedData = {'current': currentData, 'forecast': []};

      return WeatherData.fromJson(combinedData);
    } catch (e) {
      throw WeatherFailure(
        'Не удалось получить текущую погоду: ${e.toString()}',
      );
    }
  }

  @override
  Future<WeatherData> getWeatherForecast(String city) async {
    try {
      final now = await _service.getCurrentWeather(city);
      final fore = await _service.getForecast(city);

      // Берём прогноз примерно на 12:00 каждого дня
      final daily = (fore['list'] as List)
          .where((item) {
            return (item['dt_txt'] as String).contains('12:00:00');
          })
          .take(5)
          .toList();

      // Объединяем данные в одну структуру
      final combinedData = {'current': now, 'forecast': daily};

      return WeatherData.fromJson(combinedData);
    } catch (e) {
      throw WeatherFailure(
        'Не удалось получить прогноз погоды: ${e.toString()}',
      );
    }
  }

  @override
  Future<WeatherData> getWeatherForecastByCoords(double lat, double lon) async {
    try {
      final now = await _service.getCurrentWeatherByCoords(lat, lon);
      final fore = await _service.getForecastByCoords(lat, lon);

      // Берём прогноз примерно на 12:00 каждого дня
      final daily = (fore['list'] as List)
          .where((item) {
            return (item['dt_txt'] as String).contains('12:00:00');
          })
          .take(5)
          .toList();

      // Объединяем данные в одну структуру
      final combinedData = {'current': now, 'forecast': daily};

      return WeatherData.fromJson(combinedData);
    } catch (e) {
      throw WeatherFailure(
        'Не удалось получить прогноз погоды: ${e.toString()}',
      );
    }
  }
}
