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

  static Future<void> initialize() async {
    // В веб-версии используем значения по умолчанию из .env (если доступен)
    // или оставляем пустыми для ручной настройки
    openWeatherApiKey = '';
    firebaseWebApiKey = '';
    firebaseAndroidApiKey = '';
    firebaseIOSApiKey = '';
    rssFeedUrl = 'https://ysia.ru/feed/';
    apiNinjasKey = '';
  }
}
