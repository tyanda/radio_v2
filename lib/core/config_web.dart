// lib/core/config_web.dart
// Конфигурация для веб-платформы

import 'package:web/web.dart' as web;

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
    // В веб-версии используем значения из localStorage или по умолчанию
    // Для безопасности ключи не должны храниться в коде
    openWeatherApiKey =
        web.window.localStorage.getItem('OPENWEATHER_API_KEY') ?? '';
    firebaseWebApiKey =
        web.window.localStorage.getItem('FIREBASE_WEB_API_KEY') ?? '';
    firebaseAndroidApiKey =
        web.window.localStorage.getItem('FIREBASE_ANDROID_API_KEY') ?? '';
    firebaseIOSApiKey =
        web.window.localStorage.getItem('FIREBASE_IOS_API_KEY') ?? '';
    rssFeedUrl =
        web.window.localStorage.getItem('RSS_FEED_URL') ??
        'https://ysia.ru/feed/';
    apiNinjasKey = web.window.localStorage.getItem('API_NINJAS_KEY') ?? '';
    apiVerveKey = web.window.localStorage.getItem('API_VERVE_KEY') ?? '';

    // Если ключи не найдены в localStorage, используем значения по умолчанию
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
  }
}
