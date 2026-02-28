import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/utils/logger.dart';

/// Сервис для поиска обложек альбомов через iTunes API
///
/// Использование:
/// ```dart
/// final service = AlbumArtService();
/// final artUrl = await service.searchAlbumArt(artist: 'Baha Men', title: 'Who Let The Dogs Out');
/// ```
class AlbumArtService {
  static const _baseUrl = 'https://itunes.apple.com/search';

  /// Поиск обложки альбома по артисту и названию трека
  /// Возвращает URL обложки в высоком качестве
  Future<String?> searchAlbumArt({String? artist, String? title}) async {
    if (artist == null && title == null) return null;

    try {
      // Формируем поисковый запрос
      final query = [
        if (artist != null && artist.isNotEmpty) 'term=$artist',
        if (title != null && title.isNotEmpty) ...[
          artist != null && artist.isNotEmpty ? '+$title' : 'term=$title',
        ],
      ].join('+');

      final url = Uri.parse('$_baseUrl?media=music&limit=1&$query');

      Logger.log(
        '🎨 AlbumArt: Searching for: artist="$artist", title="$title"',
        tag: 'AlbumArt',
      );

      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              Logger.log('AlbumArt: Request timeout', tag: 'AlbumArt');
              return http.Response('{"resultCount":0}', 408);
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        if (results.isNotEmpty) {
          // Получаем обложку в высоком качестве (1200x1200)
          final artUrl = results.first['artworkUrl100'] as String;
          final highResUrl = artUrl.replaceAll('100x100bb', '1200x1200');

          Logger.log('🎨 AlbumArt: Found: $highResUrl', tag: 'AlbumArt');

          return highResUrl;
        } else {
          Logger.log('AlbumArt: No results found', tag: 'AlbumArt');
        }
      } else {
        Logger.log(
          'AlbumArt: API error: ${response.statusCode}',
          tag: 'AlbumArt',
        );
      }
    } catch (e) {
      Logger.log('AlbumArt: Error: $e', tag: 'AlbumArt');
    }

    return null;
  }

  /// Извлечение URL обложки из ICY метаданных (если станция передаёт)
  /// Некоторые станции передают artUrl в расширенных метаданных
  String? extractArtUrlFromIcy(Map<String, dynamic>? metadata) {
    if (metadata == null) return null;

    // Проверяем различные возможные поля
    return metadata['artUrl'] as String? ??
        metadata['imageUrl'] as String? ??
        metadata['albumArt'] as String? ??
        metadata['coverArt'] as String?;
  }
}
