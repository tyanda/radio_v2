// Условный импорт для home_widget (не поддерживается на Web)
import 'package:sakha_live/services/home_widget_service.dart'
    if (dart.library.io) 'package:sakha_live/services/home_widget_service_stub.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:sakha_live/core/utils/logger.dart';

/// Репозиторий для управления домашними виджетами
class HomeWidgetRepository {
  static const String widgetName = 'SakhaLiveWidget';
  static const String androidId = 'sakha_live_widget';
  static const String iOSId = 'SakhaLiveWidget';

  /// Обновление данных виджета
  Future<void> updateWidgetData({
    required String stationName,
    String? currentTrack,
    String? albumArt,
    bool isPlaying = false,
  }) async {
    // Виджеты не поддерживаются на Web
    if (kIsWeb) return;

    try {
      // Сохраняем данные в SharedPreferences для виджета
      await HomeWidgetService.saveWidgetData<String>(
        'stationName',
        stationName,
      );
      await HomeWidgetService.saveWidgetData<String>(
        'currentTrack',
        currentTrack ?? '',
      );
      await HomeWidgetService.saveWidgetData<String>(
        'albumArt',
        albumArt ?? '',
      );
      await HomeWidgetService.saveWidgetData<String>(
        'isPlaying',
        isPlaying ? '1' : '0',
      );
      await HomeWidgetService.saveWidgetData<String>(
        'lastUpdated',
        DateTime.now().millisecondsSinceEpoch.toString(),
      );

      // Обновляем виджет
      await HomeWidgetService.updateWidget(
        name: widgetName,
        androidName: androidId,
        iOSName: iOSId,
      );
    } catch (e) {
      Logger.error('Error updating widget: $e', tag: 'HomeWidget');
    }
  }

  /// Проверка наличия виджета на экране
  Future<bool> isWidgetAdded() async {
    // Виджеты не поддерживаются на Web
    if (kIsWeb) return false;

    // HomeWidget не предоставляет прямого метода проверки
    // Возвращаем true для совместимости
    return true;
  }

  /// Настройка callback для взаимодействия с виджетом
  Future<void> setupCallback() async {
    // Виджеты не поддерживаются на Web
    if (kIsWeb) return;

    try {
      HomeWidgetService.widgetClicked.listen((uri) {
        // Обработка клика по виджету
        Logger.log('Widget clicked: $uri', tag: 'HomeWidget');
      });
    } catch (e) {
      Logger.error('Error setting up callback: $e', tag: 'HomeWidget');
    }
  }

  /// Получить платформу
  String get platform {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }
}
