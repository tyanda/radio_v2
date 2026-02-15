// Сервис для работы с погодными данными
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../../../core/config.dart';
import '../models/weather_failure.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static String get _apiKey => AppConfig.openWeatherApiKey;

  Future<Map<String, dynamic>> getCurrentWeather(String city) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric&lang=ru',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw WeatherFailure('Город не найден: $city');
    } else if (response.statusCode == 401) {
      throw WeatherFailure('Неверный API ключ');
    } else {
      throw WeatherFailure('Ошибка сети: ${response.statusCode}');
    }
  }

  // Метод для получения погоды по координатам
  Future<Map<String, dynamic>> getCurrentWeatherByCoords(
    double lat,
    double lon,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=ru',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw WeatherFailure('Неверный API ключ');
    } else {
      throw WeatherFailure('Ошибка сети: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getForecast(String city) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/forecast?q=$city&appid=$_apiKey&units=metric&lang=ru',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw WeatherFailure('Город не найден: $city');
    } else if (response.statusCode == 401) {
      throw WeatherFailure('Неверный API ключ');
    } else {
      throw WeatherFailure('Ошибка сети: ${response.statusCode}');
    }
  }

  // Метод для получения прогноза по координатам
  Future<Map<String, dynamic>> getForecastByCoords(
    double lat,
    double lon,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=ru',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw WeatherFailure('Неверный API ключ');
    } else {
      throw WeatherFailure('Ошибка сети: ${response.statusCode}');
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
