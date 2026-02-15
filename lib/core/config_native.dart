// lib/core/config_native.dart
// Конфигурация для нативных платформ

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String defaultOpenWeatherApiKey = '8a392c6308671b581410d09e97f6ecac';
  static const String defaultFirebaseWebApiKey = 'AIzaSyCsP4btD3tfm9nOESW0YdCyVWYCJmmnBME';
  static const String defaultFirebaseAndroidApiKey = 'AIzaSyApqgccLr4zrPFv5PIXgQiJa4BKfSRkw7Q';
  static const String defaultFirebaseIOSApiKey = 'AIzaSyBPB2X2ke21Smr0vqSczfwRtM-dolvyPyA';
  static const String defaultRssFeedUrl = 'https://ysia.ru/feed/';

  // Переменные, которые будут использоваться в приложении
  static String openWeatherApiKey = defaultOpenWeatherApiKey;
  static String firebaseWebApiKey = defaultFirebaseWebApiKey;
  static String firebaseAndroidApiKey = defaultFirebaseAndroidApiKey;
  static String firebaseIOSApiKey = defaultFirebaseIOSApiKey;
  static String rssFeedUrl = defaultRssFeedUrl;

  static Future<void> initialize() async {
    await _loadFromEnv();
  }

  static Future<void> _loadFromEnv() async {
    try {
      await dotenv.load(fileName: ".env");
      
      openWeatherApiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? defaultOpenWeatherApiKey;
      firebaseWebApiKey = dotenv.env['FIREBASE_WEB_API_KEY'] ?? defaultFirebaseWebApiKey;
      firebaseAndroidApiKey = dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? defaultFirebaseAndroidApiKey;
      firebaseIOSApiKey = dotenv.env['FIREBASE_IOS_API_KEY'] ?? defaultFirebaseIOSApiKey;
      rssFeedUrl = dotenv.env['RSS_FEED_URL'] ?? defaultRssFeedUrl;
    } catch (e) {
      // Если не удалось загрузить .env, используем значения по умолчанию
      debugPrint('Could not load .env file: $e');
    }
  }
}