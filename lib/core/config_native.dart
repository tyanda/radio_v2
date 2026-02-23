// lib/core/config_native.dart
// Конфигурация для нативных платформ

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'utils/logger.dart';

class AppConfig {
  // Переменные, которые будут использоваться в приложении
  // Все значения загружаются из .env файла
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
      // flutter_dotenv 6.0.0 использует новый API
      final dotenv = DotEnv();
      await dotenv.load(fileName: ".env");

      openWeatherApiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
      firebaseWebApiKey = dotenv.env['FIREBASE_WEB_API_KEY'] ?? '';
      firebaseAndroidApiKey = dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? '';
      firebaseIOSApiKey = dotenv.env['FIREBASE_IOS_API_KEY'] ?? '';
      rssFeedUrl = dotenv.env['RSS_FEED_URL'] ?? 'https://ysia.ru/feed/';
      apiNinjasKey = dotenv.env['API_NINJAS_KEY'] ?? '';
      apiVerveKey = dotenv.env['API_VERVE_KEY'] ?? '';

      // Проверка на пустые значения
      if (openWeatherApiKey.isEmpty) {
        Logger.warn('OPENWEATHER_API_KEY is empty', tag: 'Config');
      }
      if (apiNinjasKey.isEmpty) {
        Logger.warn('API_NINJAS_KEY is empty', tag: 'Config');
      }
      if (apiVerveKey.isEmpty) {
        Logger.warn('API_VERVE_KEY is empty (опционально)', tag: 'Config');
      }
      if (rssFeedUrl.isEmpty) {
        rssFeedUrl = 'https://ysia.ru/feed/';
        Logger.log('RSS_FEED_URL: используется значение по умолчанию', tag: 'Config');
      }

      Logger.log('AppConfig initialized from .env file', tag: 'Config');
    } catch (e) {
      Logger.error('Could not load .env file: $e', tag: 'Config');
      Logger.log('Using default values for configuration', tag: 'Config');
      rssFeedUrl = 'https://ysia.ru/feed/';
    }
  }
}
