import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/weather_repository.dart';
import '../models/weather_model.dart';
import '../models/weather_failure.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _error;

  WeatherData? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final WeatherRepository _repository;
  static const String _cachedWeatherKey = 'cached_weather_data';

  WeatherProvider() : _repository = WeatherRepositoryImpl();

  Future<void> fetchWeather() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weatherData = await _repository.getWeatherForecast("Yakutsk");
      // Сохраняем данные в кэш
      _cacheWeatherData(_weatherData!);
    } on WeatherFailure catch (e) {
      _error = e.message;
      _weatherData = null;
      // Пытаемся загрузить данные из кэша
      await _loadCachedWeatherData();
    } catch (e) {
      _error = 'Произошла неизвестная ошибка: ${e.toString()}';
      _weatherData = null;
      // Пытаемся загрузить данные из кэша
      await _loadCachedWeatherData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _cacheWeatherData(WeatherData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cachedWeatherKey, jsonEncode(data.toJson()));
    } catch (e) {
      // Игнорируем ошибки кэширования
      debugPrint('Ошибка кэширования данных погоды: $e');
    }
  }

  Future<void> _loadCachedWeatherData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cachedWeatherKey);
      if (cachedData != null) {
        _weatherData = WeatherData.fromJson(jsonDecode(cachedData));
        _error = null; // Очищаем ошибку при успешной загрузке кэша
      }
    } catch (e) {
      // Игнорируем ошибки загрузки кэша
      debugPrint('Ошибка загрузки кэшированных данных погоды: $e');
    }
  }

  Future<void> refreshWeather() async {
    await fetchWeather();
  }
}
