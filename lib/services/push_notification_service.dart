import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:radio_v2/core/utils/logger.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Logger.log('Handling a background message: ${message.messageId}', tag: 'PushNotifications');
}

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      Logger.log('User granted permission', tag: 'PushNotifications');
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {},
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Logger.log('Got a message whilst in the foreground!', tag: 'PushNotifications');
      _showLocalNotification(message);
    });
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'news_channel',
            'Информационные уведомления',
            channelDescription: 'Уведомления о новостях и обновлениях',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  }

  static Future<void> subscribeToNews() async {
    try {
      await _messaging.subscribeToTopic('news');
      Logger.log('Subscribed to news topic', tag: 'PushNotifications');
    } catch (e) {
      Logger.error('Failed to subscribe: $e', tag: 'PushNotifications');
    }
  }

  static Future<void> unsubscribeFromNews() async {
    try {
      await _messaging.unsubscribeFromTopic('news');
      Logger.log('Unsubscribed from news topic', tag: 'PushNotifications');
    } catch (e) {
      Logger.error('Failed to unsubscribe: $e', tag: 'PushNotifications');
    }
  }
}
