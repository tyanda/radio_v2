// lib/core/config_native.dart
// Конфигурация для нативных платформ

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'utils/logger.dart';

class AppConfig {
  // Переменные, которые будут использоваться в приложении
  static String openWeatherApiKey = '8a392c6308671b581410d09e97f6ecac'; // Значение по умолчанию
  static String firebaseWebApiKey = '';
  static String firebaseAndroidApiKey = '';
  static String firebaseIOSApiKey = '';
  static String rssFeedUrl = 'https://ysia.ru/feed/'; // Значение по умолчанию
  static String apiNinjasKey = 'v0cxsQQg1mMoA7YeEUNnxqgwSj8aE8qvgFUoImPV'; // Значение по умолчанию
  static String apiVerveKey = 'apv_914d0f39-46fc-4212-bf06-d2d55acca8b5'; // Значение по умолчанию

  static Future<void> initialize() async {
    await _loadFromEnv();
  }

  static Future<void> _loadFromEnv() async {
    try {
      await dotenv.load(fileName: ".env");

      openWeatherApiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? openWeatherApiKey;
      firebaseWebApiKey = dotenv.env['FIREBASE_WEB_API_KEY'] ?? firebaseWebApiKey;
      firebaseAndroidApiKey = dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? firebaseAndroidApiKey;
      firebaseIOSApiKey = dotenv.env['FIREBASE_IOS_API_KEY'] ?? firebaseIOSApiKey;
      rssFeedUrl = dotenv.env['RSS_FEED_URL'] ?? rssFeedUrl;
      apiNinjasKey = dotenv.env['API_NINJAS_KEY'] ?? apiNinjasKey;
      apiVerveKey = dotenv.env['API_VERVE_KEY'] ?? apiVerveKey;

      // Проверка на пустые значения
      if (openWeatherApiKey.isEmpty) {
        Logger.warn('OPENWEATHER_API_KEY is empty');
      }
      if (apiNinjasKey.isEmpty) {
        Logger.warn('API_NINJAS_KEY is empty');
      }
      if (apiVerveKey.isEmpty) {
        Logger.warn('API_VERVE_KEY is empty (опционально)');
      }
      if (rssFeedUrl == 'https://ysia.ru/feed/') {
        Logger.log('RSS_FEED_URL: используется значение по умолчанию');
      }
    } catch (e) {
      Logger.error('Could not load .env file: $e');
      Logger.log('RSS_FEED_URL: используется значение по умолчанию');
    }
  }
}
