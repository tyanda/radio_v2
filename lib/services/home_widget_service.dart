/// Web implementation for home_widget
/// Home widgets are not supported on web platforms
library;

import 'package:web/web.dart' as web;
import 'package:sakha_live/core/utils/logger.dart';

class HomeWidgetService {
  static const bool isSupported = false;

  static Future<void> setAppGroupId(String groupId) async {
    // Not supported on web
    Logger.log(
      'HomeWidget.setAppGroupId: Not supported on web',
      tag: 'HomeWidget',
    );
    return;
  }

  static Future<void> saveWidgetData<T>(String key, T value) async {
    // Not supported on web - optionally store in localStorage
    try {
      web.window.localStorage.setItem('home_widget_$key', value.toString());
      Logger.log(
        'HomeWidget data saved to localStorage: $key=$value',
        tag: 'HomeWidget',
      );
    } catch (e) {
      Logger.warn(
        'HomeWidget.saveWidgetData: localStorage not available: $e',
        tag: 'HomeWidget',
      );
    }
    return;
  }

  static Future<void> updateWidget({
    String? name,
    String? androidName,
    String? iOSName,
  }) async {
    // Not supported on web
    Logger.log(
      'HomeWidget.updateWidget: Not supported on web',
      tag: 'HomeWidget',
    );
    return;
  }

  static Stream<dynamic> get widgetClicked {
    // Not supported on web - return empty stream
    return Stream.empty();
  }
}
