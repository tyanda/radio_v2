// Сервис для работы с погодными данными
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_failure.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _apiKey = "8a392c6308671b581410d09e97f6ecac";

  Future<Map<String, dynamic>> getCurrentWeather(String city) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric&lang=ru'),
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

  Future<Map<String, dynamic>> getForecast(String city) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/forecast?q=$city&appid=$_apiKey&units=metric&lang=ru'),
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
}