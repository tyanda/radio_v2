// Сервис для работы с погодными данными
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/config.dart';
import '../models/weather_failure.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static String get _apiKey => AppConfig.openWeatherApiKey;
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

  // Метод для получения текущего местоположения пользователя
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Проверяем, включена ли служба геолокации
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw WeatherFailure('Служба геолокации отключена');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw WeatherFailure('Разрешение на геолокацию отклонено');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw WeatherFailure('Разрешение на геолокацию отклонено навсегда');
    }

    // Получаем текущее местоположение
    return await Geolocator.getCurrentPosition();
  }
}
