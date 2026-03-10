import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sakha_live/core/providers/global_providers.dart';
import 'package:sakha_live/features/weather/models/weather_model.dart';
import 'package:sakha_live/features/weather/models/weather_failure.dart';
import 'package:sakha_live/features/weather/data/weather_repository.dart';
import 'package:sakha_live/features/weather/data/weather_service.dart';
import 'package:sakha_live/core/utils/logger.dart';

class WeatherNotifier extends Notifier<AsyncValue<WeatherData?>> {
  static const String _cachedWeatherKey = 'cached_weather_data';
  DateTime? _lastFetchTime;
  late WeatherRepositoryImpl _repository;
  late WeatherService _service;

  @override
  AsyncValue<WeatherData?> build() {
    _service = WeatherService(ref.read(dioProvider));
    _repository = WeatherRepositoryImpl(_service);

    // Пытаемся загрузить из кэша сразу при создании
    _loadCachedWeatherData().then((cached) {
      if (cached != null) {
        state = AsyncData(cached);
        _refreshInBackground();
      } else {
        _fetchWeather();
      }
    });

    return const AsyncLoading();
  }

  void _refreshInBackground() async {
    try {
      await refreshWeather(isSilent: true);
    } catch (_) {}
  }

  Future<void> _fetchWeather() async {
    try {
      WeatherData data;
      try {
        final position = await _service.getCurrentLocation();
        data = await _repository.getWeatherForecastByCoords(
          position.latitude,
          position.longitude,
        );
        Logger.log(
          'Погода загружена по координатам: ${position.latitude}, ${position.longitude}',
          tag: 'Weather',
        );
      } catch (locationError) {
        Logger.error(
          'Ошибка получения местоположения: $locationError',
          tag: 'Weather',
        );
        // Пробуем загрузить по городу Якутск
        data = await _repository.getWeatherForecast("Yakutsk");
        Logger.log('Погода загружена по умолчанию (Yakutsk)', tag: 'Weather');
      }

      await _cacheWeatherData(data);
      _lastFetchTime = DateTime.now();
      state = AsyncData(data);
    } on WeatherFailure catch (e) {
      final cached = await _loadCachedWeatherData();
      if (cached != null) {
        state = AsyncData(cached);
      } else {
        Logger.error('Ошибка получения погоды: $e', tag: 'Weather');
        state = AsyncError(e, StackTrace.current);
      }
    } catch (e) {
      final cached = await _loadCachedWeatherData();
      if (cached != null) {
        state = AsyncData(cached);
      } else {
        Logger.error('Произошла ошибка: ${e.toString()}', tag: 'Weather');
        state = AsyncError(e, StackTrace.current);
      }
    }
  }

  Future<void> refreshWeather({
    bool force = false,
    bool isSilent = false,
  }) async {
    if (!force && _lastFetchTime != null) {
      final difference = DateTime.now().difference(_lastFetchTime!);
      if (difference.inMinutes < 15) {
        Logger.log(
          'Weather data is fresh (updated ${difference.inMinutes} mins ago). Skipping refresh.',
          tag: 'Weather',
        );
        return;
      }
    }

    if (!isSilent) {
      state = const AsyncLoading();
    }
    await _fetchWeather();
  }

  Future<void> _cacheWeatherData(WeatherData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cachedWeatherKey, jsonEncode(data.toJson()));
    } catch (e) {
      Logger.error('Ошибка кэширования данных погоды: $e', tag: 'Weather');
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
      Logger.error(
        'Ошибка загрузки кэшированных данных погоды: $e',
        tag: 'Weather',
      );
    }
    return null;
  }
}

final weatherProvider =
    NotifierProvider<WeatherNotifier, AsyncValue<WeatherData?>>(
      WeatherNotifier.new,
    );
