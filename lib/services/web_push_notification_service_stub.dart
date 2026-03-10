// lib/services/web_push_notification_service_stub.dart
// Stub для мобильных платформ (Android/iOS)
// На мобильных используется Firebase Messaging

/// Stub класс для мобильных платформ
/// На мобильных используется Firebase Messaging через push_notification_service.dart
class WebPushNotificationService {
  static WebPushNotificationService? _instance;

  WebPushNotificationService._internal();

  factory WebPushNotificationService() {
    _instance ??= WebPushNotificationService._internal();
    return _instance!;
  }

  /// Проверка поддержки Push API (всегда false для мобильных)
  static bool get isSupported => false;

  /// Проверка поддержки на iOS (всегда false для мобильных)
  static bool get isIOSSupported => false;

  /// Инициализация (пустая реализация)
  Future<bool> initialize() async => false;

  /// Запрос разрешения (пустая реализация)
  Future<String> requestPermission() async => 'denied';

  /// Подписка на push (пустая реализация)
  Future<bool> subscribe({String? vapidPublicKey}) async => false;

  /// Отписка от push (пустая реализация)
  Future<bool> unsubscribe() async => false;

  /// Проверка подписки (пустая реализация)
  Future<bool> isSubscribed() async => false;

  /// Показ локального уведомления (пустая реализация)
  static Future<bool> showNotification({
    required String title,
    String? body,
    String? icon,
    String? badge,
    String? tag,
    bool requireInteraction = false,
  }) async => false;

  /// Получение уведомлений (пустая реализация)
  static Future<List> getNotifications() async => [];

  /// Закрытие всех уведомлений (пустая реализация)
  static void closeAllNotifications() {}

  /// Текущее состояние разрешения
  static String get permissionState => 'denied';
}
