import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:radio_v2/core/providers/providers.dart';
import '../models/weather_model.dart';
import '../models/weather_failure.dart';
import '../../../core/utils/logger.dart';

class WeatherNotifier extends AsyncNotifier<WeatherData?> {
  static const String _cachedWeatherKey = 'cached_weather_data';
  DateTime? _lastFetchTime;

  @override
  Future<WeatherData?> build() async {
    // Пытаемся загрузить из кэша сразу при создании
    final cached = await _loadCachedWeatherData();
    if (cached != null) {
      // Запускаем фоновое обновление, если данные устарели (> 15 мин)
      // или если это первый запуск
      _refreshInBackground();
      return cached;
    }

    // Если в кэше пусто, загружаем
    return _fetchWeather();
  }

  void _refreshInBackground() async {
    try {
      await refreshWeather(
        isSilent: true,
      ); // Use public method which checks time
    } catch (_) {}
  }

  Future<WeatherData?> _fetchWeather() async {
    final repository = ref.read(weatherRepositoryProvider);
    final service = ref.read(weatherServiceProvider);

    try {
      WeatherData data;
      try {
        final position = await service.getCurrentLocation();
        data = await repository.getWeatherForecastByCoords(
          position.latitude,
          position.longitude,
        );
      } catch (locationError) {
        Logger.error('Ошибка получения местоположения: $locationError');
        data = await repository.getWeatherForecast("Yakutsk");
      }

      _cacheWeatherData(data);
      _lastFetchTime = DateTime.now(); // Update timestamp
      state = AsyncData(data);
      return data;
    } on WeatherFailure catch (_) {
      final cached = await _loadCachedWeatherData();
      if (cached != null) {
        state = AsyncData(cached);
        return cached;
      }
      rethrow;
    } catch (e) {
      final cached = await _loadCachedWeatherData();
      if (cached != null) {
        state = AsyncData(cached);
        return cached;
      }
      throw WeatherFailure('Произошла ошибка: ${e.toString()}');
    }
  }

  Future<void> refreshWeather({
    bool force = false,
    bool isSilent = false,
  }) async {
    // Check if we need to update
    if (!force && _lastFetchTime != null) {
      final difference = DateTime.now().difference(_lastFetchTime!);
      if (difference.inMinutes < 15) {
        Logger.log(
          'Weather data is fresh (updated ${difference.inMinutes} mins ago). Skipping refresh.',
        );
        return;
      }
    }

    if (!isSilent) {
      state = const AsyncLoading(); // Show loading indicator only if not silent
    }
    await _fetchWeather();
  }

  Future<void> _cacheWeatherData(WeatherData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cachedWeatherKey, jsonEncode(data.toJson()));
    } catch (e) {
      Logger.error('Ошибка кэширования данных погоды: $e');
    }
  }

  Future<WeatherData?> _loadCachedWeatherData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cachedWeatherKey);
      if (cachedData != null) {
        return WeatherData.fromJson(jsonDecode(cachedData));
      }
    } catch (e) {
      Logger.error('Ошибка загрузки кэшированных данных погоды: $e');
    }
    return null;
  }
}

final weatherProvider = AsyncNotifierProvider<WeatherNotifier, WeatherData?>(
  WeatherNotifier.new,
);
