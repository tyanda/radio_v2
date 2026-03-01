// Сервис для работы с погодными данными
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config.dart';
import '../../../core/utils/logger.dart';
import '../models/weather_failure.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static String get _apiKey => AppConfig.openWeatherApiKey;
  static const String _coordsCacheKeyLat = 'user_coords_lat';
  static const String _coordsCacheKeyLon = 'user_coords_lon';
  final Dio _dio;

  WeatherService(this._dio);

  Future<Map<String, dynamic>> getCurrentWeather(String city) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/weather',
        queryParameters: {
          'q': city,
          'appid': _apiKey,
          'units': 'metric',
          'lang': 'ru',
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 404) {
        throw WeatherFailure('Город не найден: $city');
      } else if (response.statusCode == 401) {
        throw WeatherFailure('Неверный API ключ');
      } else {
        throw WeatherFailure('Ошибка API: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw WeatherFailure('Превышено время ожидания');
      } else if (e.type == DioExceptionType.connectionError) {
        throw WeatherFailure('Ошибка подключения к серверу');
      }
      throw WeatherFailure('Ошибка сети: ${e.message}');
    } catch (e) {
      throw WeatherFailure('Неизвестная ошибка: ${e.toString()}');
    }
  }

  // Метод для получения погоды по координатам
  Future<Map<String, dynamic>> getCurrentWeatherByCoords(
    double lat,
    double lon,
  ) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/weather',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': _apiKey,
          'units': 'metric',
          'lang': 'ru',
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 401) {
        throw WeatherFailure('Неверный API ключ');
      } else {
        throw WeatherFailure('Ошибка API: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw WeatherFailure('Ошибка подключения к серверу');
      }
      throw WeatherFailure('Ошибка сети: ${e.message}');
    } catch (e) {
      throw WeatherFailure('Неизвестная ошибка: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getForecast(String city) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/forecast',
        queryParameters: {
          'q': city,
          'appid': _apiKey,
          'units': 'metric',
          'lang': 'ru',
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 404) {
        throw WeatherFailure('Город не найден: $city');
      } else if (response.statusCode == 401) {
        throw WeatherFailure('Неверный API ключ');
      } else {
        throw WeatherFailure('Ошибка API: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw WeatherFailure('Ошибка подключения к серверу');
      }
      throw WeatherFailure('Ошибка сети: ${e.message}');
    } catch (e) {
      throw WeatherFailure('Неизвестная ошибка: ${e.toString()}');
    }
  }

  // Метод для получения прогноза по координатам
  Future<Map<String, dynamic>> getForecastByCoords(
    double lat,
    double lon,
  ) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/forecast',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': _apiKey,
          'units': 'metric',
          'lang': 'ru',
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 401) {
        throw WeatherFailure('Неверный API ключ');
      } else {
        throw WeatherFailure('Ошибка API: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw WeatherFailure('Ошибка подключения к серверу');
      }
      throw WeatherFailure('Ошибка сети: ${e.message}');
    } catch (e) {
      throw WeatherFailure('Неизвестная ошибка: ${e.toString()}');
    }
  }

  /// Получает сохранённые координаты из кэша
  Future<Map<String, double>?> getCachedCoords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(_coordsCacheKeyLat);
      final lon = prefs.getDouble(_coordsCacheKeyLon);

      if (lat != null && lon != null) {
        return {'lat': lat, 'lon': lon};
      }
    } catch (e) {
      // Игнорируем ошибки кэша
    }
    return null;
  }

  /// Сохраняет координаты в кэш
  Future<void> cacheCoords(double lat, double lon) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_coordsCacheKeyLat, lat);
      await prefs.setDouble(_coordsCacheKeyLon, lon);
    } catch (e) {
      // Игнорируем ошибки кэширования
    }
  }

  /// Получает местоположение пользователя с кэшированием
  Future<Position> getCurrentLocation() async {
    // Сначала пробуем получить из кэша
    final cachedCoords = await getCachedCoords();
    if (cachedCoords != null) {
      Logger.log(
        'Используем кэшированные координаты: ${cachedCoords['lat']}, ${cachedCoords['lon']}',
        tag: 'Weather',
      );
      return Position(
        latitude: cachedCoords['lat']!,
        longitude: cachedCoords['lon']!,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }

    // Если кэша нет — запрашиваем геолокацию
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // Проверяем, включена ли служба геолокации
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Если служба отключена — используем Якутск по умолчанию
        await cacheCoords(62.03, 129.73);
        throw WeatherFailure('Служба геолокации отключена');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Пользователь отклонил — сохраняем Якутск как дефолт
          await cacheCoords(62.03, 129.73);
          throw WeatherFailure('Разрешение на геолокацию отклонено');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Отклонено навсегда — сохраняем Якутск
        await cacheCoords(62.03, 129.73);
        throw WeatherFailure('Разрешение на геолокацию отклонено навсегда');
      }

      // Получаем текущее местоположение с таймаутом
      final position = await _getCurrentPositionWithTimeout();

      // Сохраняем в кэш
      await cacheCoords(position.latitude, position.longitude);
      Logger.log(
        'Координаты сохранены в кэш: ${position.latitude}, ${position.longitude}',
        tag: 'Weather',
      );

      return position;
    } catch (e) {
      // При любой ошибке сохраняем Якутск
      if (e is! WeatherFailure) {
        await cacheCoords(62.03, 129.73);
        Logger.error(
          'Ошибка геолокации, используем Якутск: $e',
          tag: 'Weather',
        );
      }
      rethrow;
    }
  }

  /// Получает координаты с таймаутом
  Future<Position> _getCurrentPositionWithTimeout() async {
    try {
      return await Geolocator.getCurrentPosition().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw WeatherFailure('Превышено время ожидания геолокации');
        },
      );
    } on TimeoutException {
      throw WeatherFailure('Превышено время ожидания геолокации');
    }
  }
}
