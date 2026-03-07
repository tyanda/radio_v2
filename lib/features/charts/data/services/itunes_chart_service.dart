import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sakha_live/core/utils/logger.dart';
import '../models/chart_item.dart';

/// Сервис для получения топ чартов из iTunes API
/// https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/
///
/// API бесплатное, не требует ключа
/// Поддерживает страны: RU, US, GB, FR, DE, JP, KR и др.
class ItunesChartService {
  final String baseUrl;

  ItunesChartService({this.baseUrl = 'https://itunes.apple.com'});

  /// Получение топ треков из iTunes чарта
  Future<List<ChartItem>> fetchTopTracks({
    String country = 'RU',
    int limit = 10,
  }) async {
    try {
      // Используем RSS feed для топ песен
      final url = Uri.parse(
        'https://itunes.apple.com/$country/rss/topsongs/limit=$limit/json',
      );

      Logger.log('🍎 iTunes API запрос: $url', tag: 'ItunesChart');

      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              Logger.error('⏱️ iTunes API timeout', tag: 'ItunesChart');
              return http.Response('Timeout', 408);
            },
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        // iTunes возвращает данные в ['feed']['entry']
        final List<dynamic> entries = json['feed']?['entry'] as List? ?? [];

        Logger.log(
          '✅ iTunes API: получено ${entries.length} записей',
          tag: 'ItunesChart',
        );

        // В iTunes RSS все элементы в массиве entry - это треки
        final tracks = entries;

        return tracks.asMap().entries.map((entry) {
          final index = entry.key;
          final track = entry.value as Map<String, dynamic>;

          // Правильный парсинг структуры iTunes RSS с префиксами im:
          // im:name - название песни
          final title =
              track['im:name']?['label'] as String? ??
              track['title']?['label'] as String? ??
              '';

          // im:artist - исполнитель
          final artist =
              track['im:artist']?['label'] as String? ??
              track['artist']?['label'] as String? ??
              '';

          // Обложка: iTunes возвращает массив изображений в im:image
          final images = track['im:image'] as List? ?? [];
          String coverUrl = '';
          if (images.isNotEmpty) {
            // Берём изображение с наивысшим разрешением (последнее)
            coverUrl = images.last['label'] as String? ?? '';
          }

          // Preview URL: обычно находится в массиве link
          String previewUrl = '';
          final links = track['link'];
          if (links is List) {
            for (var link in links) {
              final attributes = link['attributes'] as Map? ?? {};
              if (attributes['im:assetType'] == 'preview') {
                previewUrl = attributes['href'] as String? ?? '';
                break;
              }
            }
          } else if (links is Map) {
            previewUrl = links['attributes']?['href'] as String? ?? '';
          }

          // ID трека: im:id в атрибутах id
          final id =
              track['id']?['attributes']?['im:id'] as String? ??
              track['id']?['label'] as String? ??
              '';

          return ChartItem(
            id: id,
            type: ChartItemType.song,
            title: title,
            artist: artist,
            rank: index + 1,
            coverUrl: _getHighResCover(coverUrl),
            previewUrl: previewUrl,
          );
        }).toList();
      } else {
        Logger.error(
          '❌ iTunes API error: ${response.statusCode}',
          tag: 'ItunesChart',
        );
        return [];
      }
    } catch (e) {
      Logger.error('❌ iTunes API exception: $e', tag: 'ItunesChart');
      return [];
    }
  }

  /// Получение топ треков для США (зарубежные хиты)
  Future<List<ChartItem>> fetchTopGlobalTracks({int limit = 10}) async {
    return fetchTopTracks(country: 'US', limit: limit);
  }

  /// Получение топ треков для России (русские хиты)
  Future<List<ChartItem>> fetchTopRussiaTracks({int limit = 10}) async {
    return fetchTopTracks(country: 'RU', limit: limit);
  }

  /// Улучшаем качество обложки (заменяем маленькие размеры на 600x600)
  String _getHighResCover(String url) {
    if (url.isEmpty) return '';
    // iTunes возвращает размеры в формате {size}x{size}bb.{ext}
    // Мы ищем этот паттерн и заменяем на 600x600bb
    final sizeRegex = RegExp(r'(\d+)x(\d+)bb');
    if (sizeRegex.hasMatch(url)) {
      return url.replaceFirst(sizeRegex, '600x600bb');
    }

    // Если паттерн не найден, пробуем обычные замены
    return url
        .replaceAll('100x100bb', '600x600bb')
        .replaceAll('53x53bb', '600x600bb')
        .replaceAll('55x55bb', '600x600bb')
        .replaceAll('60x60bb', '600x600bb')
        .replaceAll('75x75bb', '600x600bb')
        .replaceAll('170x170bb', '600x600bb');
  }
}
