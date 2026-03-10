import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/utils/logger.dart';

/// Сервис для получения метаданных треков из Radio-Browser API
///
/// Использование:
/// ```dart
/// final service = RadioBrowserMetadataService();
/// service.startFetchingMetadata(stationUuid);
/// service.metadataStream.listen((songTitle) { ... });
/// ```
class RadioBrowserMetadataService {
  static const String _baseUrl =
      'https://de1.api.radio-browser.info/json/stations/byuuid';

  final _metadataController = StreamController<String?>.broadcast();
  Timer? _fetchTimer;
  String? _currentUuid;

  /// Поток метаданных (название трека)
  Stream<String?> get metadataStream => _metadataController.stream;

  /// Начать периодический запрос метаданных
  void startFetchingMetadata(String stationUuid) {
    if (_currentUuid == stationUuid && _fetchTimer?.isActive == true) {
      return; // Уже fetching для этой станции
    }

    _currentUuid = stationUuid;
    _fetchTimer?.cancel();

    // Немедленный первый запрос
    _fetchMetadata();

    // Затем каждые 30 секунд
    _fetchTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchMetadata();
    });

    Logger.log(
      "📻 RadioBrowser: Started fetching metadata for UUID: $stationUuid",
      tag: 'RadioBrowser',
    );
  }

  /// Остановить получение метаданных
  void stopFetchingMetadata() {
    _fetchTimer?.cancel();
    _fetchTimer = null;
    _currentUuid = null;
    Logger.log(
      "📻 RadioBrowser: Stopped fetching metadata",
      tag: 'RadioBrowser',
    );
  }

  /// Получить метаданные из API
  Future<void> _fetchMetadata() async {
    if (_currentUuid == null) return;

    // Проверяем, не закрыт ли контроллер
    if (_metadataController.isClosed) return;

    try {
      final url = Uri.parse('$_baseUrl/$_currentUuid');
      Logger.log("📻 RadioBrowser: Fetching from $url", tag: 'RadioBrowser');

      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);

        if (jsonList.isNotEmpty) {
          final firstStation = jsonList[0] as Map<String, dynamic>;
          final songTitle = firstStation['songtitle'] as String?;

          Logger.log(
            "📻 RadioBrowser: songtitle = '${songTitle ?? 'null'}'",
            tag: 'RadioBrowser',
          );

          if (!_metadataController.isClosed) {
            _metadataController.add(songTitle);
          }
        } else {
          Logger.log("📻 RadioBrowser: Empty response", tag: 'RadioBrowser');
          if (!_metadataController.isClosed) {
            _metadataController.add(null);
          }
        }
      } else {
        Logger.error(
          "📻 RadioBrowser: HTTP ${response.statusCode}",
          tag: 'RadioBrowser',
        );
        if (!_metadataController.isClosed) {
          _metadataController.add(null);
        }
      }
    } catch (e) {
      Logger.error(
        "📻 RadioBrowser: Error fetching metadata: $e",
        tag: 'RadioBrowser',
      );
      if (!_metadataController.isClosed) {
        _metadataController.add(null);
      }
    }
  }

  /// Очистка ресурсов
  void dispose() {
    stopFetchingMetadata();
    _metadataController.close();
  }
}
