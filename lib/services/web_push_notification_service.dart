// lib/services/web_push_notification_service.dart
// Заглушка для Web Push Notifications
// Полная реализация будет добавлена позже

/// Заглушка для Web Push Notifications
/// Реализация будет добавлена после обновления package:web
class WebPushNotificationService {
  static WebPushNotificationService? _instance;

  WebPushNotificationService._internal();

  factory WebPushNotificationService() {
    _instance ??= WebPushNotificationService._internal();
    return _instance!;
  }

  /// Проверка поддержки Push API (пока false)
  static bool get isSupported => false;

  /// Инициализация (пока не реализована)
  Future<bool> initialize() async => false;

  /// Запрос разрешения (пока не реализована)
  Future<String> requestPermission() async => 'denied';

  /// Подписка на push (пока не реализована)
  Future<bool> subscribe({String? vapidPublicKey}) async => false;

  /// Отписка от push (пока не реализована)
  Future<bool> unsubscribe() async => false;

  /// Проверка подписки (пока не реализована)
  Future<bool> isSubscribed() async => false;

  /// Показ локального уведомления (пока не реализована)
  static Future<bool> showNotification({
    required String title,
    String? body,
    String? icon,
    String? badge,
    String? tag,
    bool requireInteraction = false,
  }) async =>
      false;

  /// Текущее состояние разрешения
  static String get permissionState => 'denied';
}
