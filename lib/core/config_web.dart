// lib/core/config_web.dart
// Конфигурация для веб-платформы

class AppConfig {
  // Переменные, которые будут использоваться в приложении
  static String openWeatherApiKey = '';
  static String firebaseWebApiKey = '';
  static String firebaseAndroidApiKey = '';
  static String firebaseIOSApiKey = '';
  static String rssFeedUrl = '';
  static String apiNinjasKey = '';
  static String apiVerveKey = 'apv_914d0f39-46fc-4212-bf06-d2d55acca8b5';

  static Future<void> initialize() async {
    // В веб-версии используем значения по умолчанию
    openWeatherApiKey = '8a392c6308671b581410d09e97f6ecac';
    firebaseWebApiKey = '';
    firebaseAndroidApiKey = '';
    firebaseIOSApiKey = '';
    rssFeedUrl = 'https://ysia.ru/feed/';
    apiNinjasKey = 'v0cxsQQg1mMoA7YeEUNnxqgwSj8aE8qvgFUoImPV';
    // apiVerveKey уже установлен выше
  }
}
