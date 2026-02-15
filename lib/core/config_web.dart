// lib/core/config_web.dart
// Конфигурация для веб-платформы

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
    _loadFromWeb();
  }

  static void _loadFromWeb() {
    // В веб-версии используем значения по умолчанию
    openWeatherApiKey = defaultOpenWeatherApiKey;
    firebaseWebApiKey = defaultFirebaseWebApiKey;
    firebaseAndroidApiKey = defaultFirebaseAndroidApiKey;
    firebaseIOSApiKey = defaultFirebaseIOSApiKey;
    rssFeedUrl = defaultRssFeedUrl;
  }
}