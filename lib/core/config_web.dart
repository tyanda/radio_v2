// lib/core/config_web.dart
// Конфигурация для веб-платформы

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
    // В веб-версии НЕ загружаем .env напрямую через rootBundle, 
    // так как это часто вызывает ошибки 404 (assets/.env)
    // Вместо этого используем значения по умолчанию или localStorage
    
    // Значения по умолчанию (production)
    openWeatherApiKey = '8a392c6308671b581410d09e97f6ecac';
    firebaseWebApiKey = 'AIzaSyApqgccLr4zrPFv5PIXgQiJa4BKfSRkw7Q';
    firebaseAndroidApiKey = 'AIzaSyApqgccLr4zrPFv5PIXgQiJa4BKfSRkw7Q';
    rssFeedUrl = 'https://ysia.ru/feed/';
    apiNinjasKey = 'v0cxsQQg1mMoA7YeEUNnxqgwSj8aE8qvgFUoImPV';
    apiVerveKey = 'apv_914d0f39-46fc-4212-bf06-d2d55acca8b5';

    // Затем переопределяем из localStorage (для отладки/настройки пользователем)
    try {
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
    } catch (e) {
      Logger.warn('LocalStorage not available: $e', tag: 'Config (Web)');
    }

    Logger.log('=== AppConfig initialized (Web) ===', tag: 'Config');
    Logger.log('RSS_FEED_URL: $rssFeedUrl', tag: 'Config');
  }
}
