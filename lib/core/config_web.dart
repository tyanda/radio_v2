// lib/core/config_web.dart
// Конфигурация для веб-платформы

import 'package:flutter/services.dart' show rootBundle;
import 'package:web/web.dart' as web;
import 'utils/logger.dart';

class AppConfig {
  // Переменные, которые будут использоваться в приложении
  static String openWeatherApiKey = '';
  // Firebase ключи по умолчанию для веба (из google-services.json)
  // Проект: sakhalive-ticker
  static String firebaseWebApiKey = 'AIzaSyApqgccLr4zrPFv5PIXgQiJa4BKfSRkw7Q';
  static String firebaseAndroidApiKey =
      'AIzaSyApqgccLr4zrPFv5PIXgQiJa4BKfSRkw7Q';
  static String firebaseIOSApiKey = '';
  static String rssFeedUrl = '';
  static String apiNinjasKey = '';
  static String apiVerveKey = '';

  static Future<void> initialize() async {
    // Сначала пробуем загрузить из .env файла (assets)
    await _loadFromEnv();

    // Затем переопределяем из localStorage (для отладки)
    openWeatherApiKey =
        web.window.localStorage.getItem('OPENWEATHER_API_KEY') ??
        openWeatherApiKey;
    firebaseWebApiKey =
        web.window.localStorage.getItem('FIREBASE_WEB_API_KEY') ??
        firebaseWebApiKey;
    firebaseAndroidApiKey =
        web.window.localStorage.getItem('FIREBASE_ANDROID_API_KEY') ??
        firebaseAndroidApiKey;
    firebaseIOSApiKey =
        web.window.localStorage.getItem('FIREBASE_IOS_API_KEY') ??
        firebaseIOSApiKey;
    rssFeedUrl = web.window.localStorage.getItem('RSS_FEED_URL') ?? rssFeedUrl;
    apiNinjasKey =
        web.window.localStorage.getItem('API_NINJAS_KEY') ?? apiNinjasKey;
    apiVerveKey =
        web.window.localStorage.getItem('API_VERVE_KEY') ?? apiVerveKey;

    // Если ключи всё ещё пустые, используем значения по умолчанию
    // В production рекомендуется использовать прокси-сервер для API запросов
    if (openWeatherApiKey.isEmpty) {
      openWeatherApiKey = '8a392c6308671b581410d09e97f6ecac';
    }
    if (apiNinjasKey.isEmpty) {
      apiNinjasKey = 'v0cxsQQg1mMoA7YeEUNnxqgwSj8aE8qvgFUoImPV';
    }
    if (apiVerveKey.isEmpty) {
      apiVerveKey = 'apv_914d0f39-46fc-4212-bf06-d2d55acca8b5';
    }

    Logger.log('=== AppConfig initialized (Web) ===', tag: 'Config');
    Logger.log(
      'FIREBASE_WEB_API_KEY: ${firebaseWebApiKey.isEmpty ? 'EMPTY' : 'SET'}',
      tag: 'Config',
    );
    Logger.log('RSS_FEED_URL: $rssFeedUrl', tag: 'Config');
  }

  static Future<void> _loadFromEnv() async {
    try {
      // Загружаем .env файл из assets через rootBundle
      final envContent = await rootBundle.loadString('.env');

      // Парсим содержимое вручную
      final lines = envContent.split('\n');
      final envMap = <String, String>{};

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

        final parts = trimmed.split('=');
        if (parts.length >= 2) {
          final key = parts.first.trim();
          final value = parts.skip(1).join('=').trim();
          // Удаляем кавычки
          final cleanValue = value.replaceAll('"', '').replaceAll("'", '');
          envMap[key] = cleanValue;
        }
      }

      openWeatherApiKey = envMap['OPENWEATHER_API_KEY'] ?? '';
      firebaseWebApiKey = envMap['FIREBASE_WEB_API_KEY'] ?? '';
      firebaseAndroidApiKey = envMap['FIREBASE_ANDROID_API_KEY'] ?? '';
      firebaseIOSApiKey = envMap['FIREBASE_IOS_API_KEY'] ?? '';
      rssFeedUrl = envMap['RSS_FEED_URL'] ?? 'https://ysia.ru/feed/';
      apiNinjasKey = envMap['API_NINJAS_KEY'] ?? '';
      apiVerveKey = envMap['API_VERVE_KEY'] ?? '';
    } catch (e) {
      Logger.error('Could not load .env file: $e', tag: 'Config (Web)');
    }
  }
}
