// lib/core/config_native.dart
// Конфигурация для нативных платформ (Android, iOS, Desktop)

import 'package:flutter/services.dart' show rootBundle;
import 'utils/logger.dart';

class AppConfig {
  // Переменные, которые будут использоваться в приложении
  static String openWeatherApiKey = '';
  static String firebaseWebApiKey = '';
  static String firebaseAndroidApiKey = '';
  static String firebaseIOSApiKey = '';
  static String rssFeedUrl = '';
  static String apiNinjasKey = '';
  static String apiVerveKey = '';

  static Future<void> initialize() async {
    await _loadFromEnv();
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

      // Проверка и логирование
      if (openWeatherApiKey.isEmpty) {
        Logger.warn('OPENWEATHER_API_KEY is empty', tag: 'Config');
      }
      if (apiNinjasKey.isEmpty) {
        Logger.warn('API_NINJAS_KEY is empty', tag: 'Config');
      }
      if (apiVerveKey.isEmpty) {
        Logger.warn('API_VERVE_KEY is empty', tag: 'Config');
      }

      Logger.log('=== AppConfig initialized ===', tag: 'Config');
      Logger.log(
        'API_NINJAS_KEY: ${apiNinjasKey.isEmpty ? 'EMPTY' : 'SET (${apiNinjasKey.length} chars)'}',
        tag: 'Config',
      );
      Logger.log(
        'API_VERVE_KEY: ${apiVerveKey.isEmpty ? 'EMPTY' : 'SET (${apiVerveKey.length} chars)'}',
        tag: 'Config',
      );
      Logger.log('RSS_FEED_URL: $rssFeedUrl', tag: 'Config');
    } catch (e) {
      Logger.error('Could not load .env file: $e', tag: 'Config');
      Logger.log('Using default values', tag: 'Config');
      rssFeedUrl = 'https://ysia.ru/feed/';
    }
  }
}
