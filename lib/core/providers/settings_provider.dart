import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Состояние настроек приложения
class SettingsState {
  final bool backgroundPlayback;
  final double defaultVolume;
  final bool notificationsEnabled;

  const SettingsState({
    this.backgroundPlayback = true,
    this.defaultVolume = 0.65,
    this.notificationsEnabled = true,
  });

  SettingsState copyWith({
    bool? backgroundPlayback,
    double? defaultVolume,
    bool? notificationsEnabled,
  }) {
    return SettingsState(
      backgroundPlayback: backgroundPlayback ?? this.backgroundPlayback,
      defaultVolume: defaultVolume ?? this.defaultVolume,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    _loadSettings();
    return const SettingsState();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      backgroundPlayback: prefs.getBool('background_playback') ?? true,
      defaultVolume: prefs.getDouble('default_volume') ?? 0.65,
      notificationsEnabled: prefs.getBool('notifications_enabled') ?? true,
    );
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

  /// Переключение уведомлений
  Future<void> toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    state = state.copyWith(notificationsEnabled: value);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
