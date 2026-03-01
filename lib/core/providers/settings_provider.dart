import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/push_notification_service.dart';

/// Состояние настроек приложения
class SettingsState {
  final bool backgroundPlayback;
  final double defaultVolume;
  final bool notificationsEnabled;
  final bool newsNotificationsEnabled;

  const SettingsState({
    this.backgroundPlayback = true,
    this.defaultVolume = 0.65,
    this.notificationsEnabled = true,
    this.newsNotificationsEnabled = true,
  });

  SettingsState copyWith({
    bool? backgroundPlayback,
    double? defaultVolume,
    bool? notificationsEnabled,
    bool? newsNotificationsEnabled,
  }) {
    return SettingsState(
      backgroundPlayback: backgroundPlayback ?? this.backgroundPlayback,
      defaultVolume: defaultVolume ?? this.defaultVolume,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      newsNotificationsEnabled: newsNotificationsEnabled ?? this.newsNotificationsEnabled,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    // Начальная загрузка настроек
    _loadSettings();
    return const SettingsState();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final newsEnabled = prefs.getBool('news_notifications_enabled') ?? true;
    
    state = SettingsState(
      backgroundPlayback: prefs.getBool('background_playback') ?? true,
      defaultVolume: prefs.getDouble('default_volume') ?? 0.65,
      notificationsEnabled: prefs.getBool('notifications_enabled') ?? true,
      newsNotificationsEnabled: newsEnabled,
    );

    // Синхронизируем подписку Firebase при загрузке
    if (newsEnabled) {
      PushNotificationService.subscribeToNews();
    } else {
      PushNotificationService.unsubscribeFromNews();
    }
  }

  /// Переключение фонового воспроизведения
  Future<void> toggleBackgroundPlayback(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('background_playback', value);
    state = state.copyWith(backgroundPlayback: value);
  }

  /// Установка громкости по умолчанию
  Future<void> setDefaultVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('default_volume', volume);
    state = state.copyWith(defaultVolume: volume);
  }

  /// Переключение уведомлений о воспроизведении
  Future<void> toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    state = state.copyWith(notificationsEnabled: value);
  }

  /// Переключение информационных уведомлений
  Future<void> toggleNewsNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('news_notifications_enabled', value);
    state = state.copyWith(newsNotificationsEnabled: value);

    if (value) {
      await PushNotificationService.subscribeToNews();
    } else {
      await PushNotificationService.unsubscribeFromNews();
    }
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
