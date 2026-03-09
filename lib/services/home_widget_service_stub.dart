/// Stub implementation for home_widget on Web
/// Home widgets are not supported on web platforms
library;

class HomeWidgetService {
  static const bool isSupported = false;

  static Future<void> setAppGroupId(String groupId) async {
    // Not supported on web
    return;
  }

  static Future<void> saveWidgetData<T>(String key, T value) async {
    // Not supported on web
    return;
  }

  static Future<void> updateWidget({
    String? name,
    String? androidName,
    String? iOSName,
  }) async {
    // Not supported on web
    return;
  }

  static Stream<dynamic> get widgetClicked {
    // Not supported on web - return empty stream
    return Stream.empty();
  }
}
