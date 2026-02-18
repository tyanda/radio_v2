// lib/core/config_native.dart
// Конфигурация для нативных платформ

import 'package:flutter_dotenv/flutter_dotenv.dart';
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
      await dotenv.load(fileName: ".env");

      openWeatherApiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
      firebaseWebApiKey = dotenv.env['FIREBASE_WEB_API_KEY'] ?? '';
      firebaseAndroidApiKey = dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? '';
      firebaseIOSApiKey = dotenv.env['FIREBASE_IOS_API_KEY'] ?? '';
      rssFeedUrl = dotenv.env['RSS_FEED_URL'] ?? '';
      apiNinjasKey = dotenv.env['API_NINJAS_KEY'] ?? '';
      apiVerveKey = dotenv.env['API_VERVE_KEY'] ?? '';

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
      if (rssFeedUrl.isEmpty) {
        Logger.warn('RSS_FEED_URL is empty');
      }
    } catch (e) {
      Logger.error('Could not load .env file: $e');
    }
  }
}
