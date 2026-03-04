import 'package:home_widget/home_widget.dart';
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
    try {
      // Сохраняем данные в SharedPreferences для виджета
      await HomeWidget.saveWidgetData<String>('stationName', stationName);
      await HomeWidget.saveWidgetData<String>(
        'currentTrack',
        currentTrack ?? '',
      );
      await HomeWidget.saveWidgetData<String>('albumArt', albumArt ?? '');
      await HomeWidget.saveWidgetData<String>(
        'isPlaying',
        isPlaying ? '1' : '0',
      );
      await HomeWidget.saveWidgetData<String>(
        'lastUpdated',
        DateTime.now().millisecondsSinceEpoch.toString(),
      );

      // Обновляем виджет
      await HomeWidget.updateWidget(
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
    // HomeWidget не предоставляет прямого метода проверки
    // Возвращаем true для совместимости
    return true;
  }

  /// Настройка callback для взаимодействия с виджетом
  Future<void> setupCallback() async {
    try {
      HomeWidget.widgetClicked.listen((uri) {
        // Обработка клика по виджету
        Logger.log('Widget clicked: $uri', tag: 'HomeWidget');
      });
    } catch (e) {
      Logger.error('Error setting up callback: $e', tag: 'HomeWidget');
    }
  }

  /// Получить платформу
  String get platform {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }
}
