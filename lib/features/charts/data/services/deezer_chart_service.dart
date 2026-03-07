import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sakha_live/core/utils/logger.dart';
import '../models/deezer_chart_response.dart';
import '../models/chart_item.dart';

/// Сервис для получения топ чартов из Deezer API
/// https://developers.deezer.com/api/chart
///
/// API не требует ключа, бесплатное использование
/// Базовый URL: https://api.deezer.com/chart/0/tracks
///
/// Для веба используется CORS-прокси для обхода ограничений браузера
class DeezerChartService {
  final String baseUrl;

  DeezerChartService({this.baseUrl = 'https://api.deezer.com'});

  /// Получение топ треков из глобального чарта Deezer
  Future<List<ChartItem>> fetchTopTracks({int limit = 10}) async {
    return _fetchFromUrl('$baseUrl/chart/0/tracks?limit=$limit', limit);
  }

  /// Получение топ треков России (используем ID плейлиста Top Russia)
  Future<List<ChartItem>> fetchTopRussianTracks({int limit = 10}) async {
    // ID плейлиста "Top Russia" в Deezer
    const russiaPlaylistId = '1116189381';
    return _fetchFromUrl(
      '$baseUrl/playlist/$russiaPlaylistId/tracks?limit=$limit',
      limit,
    );
  }

  /// Получение топ треков России за неделю
  Future<List<ChartItem>> fetchTopRussianWeeklyTracks({int limit = 10}) async {
    // Используем официальный плейлист "Top 50 Russia" от Deezer
    // ID: 1362916335 - больше треков с preview
    const weeklyPlaylistId = '1362916335';
    return _fetchFromUrl(
      '$baseUrl/playlist/$weeklyPlaylistId/tracks?limit=${limit + 5}', // Запрашиваем с запасом
      limit,
    );
  }

  Future<List<ChartItem>> _fetchFromUrl(String urlString, int limit) async {
    try {
      final url = Uri.parse(urlString);

      // Для веба используем CORS-прокси
      final effectiveUrl = kIsWeb
          ? Uri.parse(
              'https://api.allorigins.win/raw?url=${Uri.encodeComponent(url.toString())}',
            )
          : url;

      Logger.log('📊 Deezer API запрос: $effectiveUrl', tag: 'DeezerChart');

      final response = await http
          .get(effectiveUrl)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              Logger.error('⏱️ Deezer API timeout', tag: 'DeezerChart');
              return http.Response('Timeout', 408);
            },
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        // В чартах данные в ['tracks']['data'], в плейлистах — в ['data']
        final List<dynamic> data;
        if (json.containsKey('tracks')) {
          data =
              (json['tracks'] as Map<String, dynamic>)['data'] as List? ?? [];
        } else {
          data = json['data'] as List? ?? [];
        }

        Logger.log(
          '✅ Deezer API: загружено ${data.length} треков с URL: $urlString',
          tag: 'DeezerChart',
        );

        // Преобразуем JSON в ChartItem напрямую или через модель
        return data
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key;
              final trackJson = entry.value as Map<String, dynamic>;
              final track = DeezerTrack.fromJson(trackJson);

              return ChartItem(
                id: track.id,
                type: ChartItemType.song,
                title: track.title,
                artist: track.artist,
                rank: index + 1,
                coverUrl: track.coverUrl,
                previewUrl: track.previewUrl,
              );
            })
            .take(limit)
            .toList();
      } else {
        Logger.error(
          '❌ Deezer API error: ${response.statusCode} - ${response.reasonPhrase}',
          tag: 'DeezerChart',
        );
        return [];
      }
    } catch (e) {
      Logger.error('❌ Deezer API exception: $e', tag: 'DeezerChart');
      return [];
    }
  }

  /// Получение топ треков для конкретного региона
  /// Deezer не поддерживает фильтрацию по регионам напрямую,
  /// но можно использовать поиск с фильтром по стране
  Future<List<ChartItem>> fetchTopTracksByCountry({
    String country = 'RU',
    int limit = 10,
  }) async {
    // Для России используем глобальный чарт + поиск популярных русских артистов
    return fetchTopTracks(limit: limit);
  }
}
