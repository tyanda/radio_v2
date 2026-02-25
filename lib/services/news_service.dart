import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../core/config.dart';
import '../core/utils/logger.dart';

/// Сервис для получения RSS через CORS-прокси
///
/// Преимущества:
/// - Бесплатно (используется corsproxy.io)
/// - Надёжно
/// - Нет CORS проблем
/// - Быстро (кэширование)
class NewsService {
  final Dio _dio;

  // Резервный URL (прямой запрос для мобильных)
  static String get _directRssUrl => AppConfig.rssFeedUrl;

  // Кэш
  static const String _cacheKey = 'news_cache_v3';
  static const String _cacheTimestampKey = 'news_cache_timestamp_v3';
  static const Duration _cacheDuration = Duration(minutes: 15);

  NewsService(this._dio);

  /// Получает новости и возвращает список заголовков
  Future<List<String>> fetchNewsTitles({int limit = 5}) async {
    return _fetchNewsNative(limit: limit);
  }

  /// Версия для мобильных (через RSS2JSON для надёжности)
  Future<List<String>> _fetchNewsNative({int limit = 5}) async {
    try {
      // Используем RSS2JSON для надёжности
      final encodedUrl = Uri.encodeQueryComponent(_directRssUrl);
      final rss2JsonUrl =
          'https://api.rss2json.com/v1/api.json?rss_url=$encodedUrl';

      Logger.log('Native: Fetching via RSS2JSON', tag: 'NewsService');
      Logger.log('URL: $rss2JsonUrl', tag: 'NewsService');

      final response = await _dio
          .get(
            rss2JsonUrl,
            options: Options(
              followRedirects: true,
              validateStatus: (status) => status! < 500,
              responseType: ResponseType.json,
              receiveTimeout: const Duration(seconds: 15),
            ),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map && data['status'] == 'ok') {
          final items = data['items'] as List? ?? [];
          final titles = <String>[];

          for (final item in items) {
            if (titles.length >= limit) break;
            final title = item['title'] as String?;
            if (title != null && title.trim().isNotEmpty) {
              titles.add(title.trim().toUpperCase());
            }
          }

          if (titles.isNotEmpty) {
            Logger.log(
              'Parsed ${titles.length} titles via RSS2JSON',
              tag: 'NewsService',
            );
            await _cacheTitles(titles);
            return titles;
          }
        }

        Logger.warn(
          'RSS2JSON returned error or empty: ${data?['message']}',
          tag: 'NewsService',
        );
      } else {
        Logger.error(
          'RSS2JSON status ${response.statusCode}',
          tag: 'NewsService',
        );
      }

      // Если RSS2JSON не сработал, возвращаем кэш
      return _getCachedTitles(limit);
    } catch (e) {
      Logger.error('Native error: $e', tag: 'NewsService');
      return _getCachedTitles(limit);
    }
  }

  /// Кэширование заголовков
  Future<void> _cacheTitles(List<String> titles) async {
    if (titles.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(titles));
      await prefs.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      Logger.log('Cached ${titles.length} titles', tag: 'NewsService');
    } catch (e) {
      Logger.warn('Cache save error: $e', tag: 'NewsService');
    }
  }

  /// Получение кэшированных заголовков
  Future<List<String>> _getCachedTitles(int limit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      final timestamp = prefs.getInt(_cacheTimestampKey);

      if (cachedJson == null || timestamp == null) {
        return [];
      }

      // Проверяем актуальность
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (cacheAge > _cacheDuration.inMilliseconds) {
        Logger.log('Cache expired (${cacheAge ~/ 1000}s)', tag: 'NewsService');
        return [];
      }

      final titles = (jsonDecode(cachedJson) as List).cast<String>();
      Logger.log(
        'Returning ${titles.length} cached titles',
        tag: 'NewsService',
      );
      return titles.take(limit).toList();
    } catch (e) {
      Logger.warn('Cache read error: $e', tag: 'NewsService');
      return [];
    }
  }

  /// Очистка кэша (для отладки)
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimestampKey);
      Logger.log('Cache cleared', tag: 'NewsService');
    } catch (e) {
      Logger.warn('Cache clear error: $e', tag: 'NewsService');
    }
  }

  /// Принудительное обновление (игнорируя кэш)
  Future<List<String>> forceRefresh({int limit = 5}) async {
    Logger.log('Force refresh', tag: 'NewsService');
    final titles = await _fetchNewsNative(limit: limit);
    return titles;
  }
}
