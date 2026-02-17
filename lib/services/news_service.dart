import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dart_rss/dart_rss.dart';
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
    if (kIsWeb) {
      return _fetchNewsWeb(limit: limit);
    }
    return _fetchNewsNative(limit: limit);
  }

  /// Версия для Web (через RSS2JSON с CORS поддержкой)
  Future<List<String>> _fetchNewsWeb({int limit = 5}) async {
    Logger.log('[NewsService] Web: Fetching via RSS2JSON');

    try {
      // Проверяем кэш сначала
      final cached = await _getCachedTitles(limit);
      if (cached.isNotEmpty) {
        Logger.log('[NewsService] Returning cached data');
        return cached;
      }

      // Используем RSS2JSON — бесплатный сервис с CORS поддержкой
      // https://rss2json.com/
      final rss2JsonUrl = 'https://api.rss2json.com/v1/api.json?rss_url=${Uri.encodeComponent(_directRssUrl)}';
      
      final response = await _dio.get(
        rss2JsonUrl,
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status! < 500,
          responseType: ResponseType.json,
          receiveTimeout: const Duration(seconds: 15),
        ),
      ).timeout(const Duration(seconds: 20));

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
            Logger.log('[NewsService] Parsed ${titles.length} titles via RSS2JSON');
            await _cacheTitles(titles);
            return titles;
          }
        }
        
        Logger.warn('[NewsService] RSS2JSON returned error or empty');
      } else {
        Logger.error('[NewsService] RSS2JSON status ${response.statusCode}');
      }
      
      // Если RSS2JSON не сработал, возвращаем кэш или заглушку
      return _getCachedTitles(limit);
      
    } catch (e) {
      Logger.error('[NewsService] Error: $e');
      return _getCachedTitles(limit);
    }
  }

  /// Версия для мобильных (прямой запрос)
  Future<List<String>> _fetchNewsNative({int limit = 5}) async {
    try {
      final response = await _dio.get(
        _directRssUrl,
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (compatible; SakhaRadio/1.0)',
          },
        ),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        Logger.log('[NewsService] Native: RSS fetched (${response.data.length} bytes)');
        return _parseRssContent(response.data.toString(), limit);
      } else {
        Logger.error('[NewsService] Native error: ${response.statusCode}');
        return _getCachedTitles(limit);
      }
    } catch (e) {
      Logger.error('[NewsService] Native fetch error: $e');
      return _getCachedTitles(limit);
    }
  }

  /// Парсинг RSS контента
  List<String> _parseRssContent(String content, int limit) {
    try {
      if (content.trim().isEmpty) {
        Logger.warn('[NewsService] Empty content');
        return [];
      }

      // Проверяем, что это RSS/XML
      if (!content.contains('<rss') && !content.contains('<feed')) {
        Logger.warn('[NewsService] Not RSS/XML content');
        return [];
      }

      final feed = RssFeed.parse(content);
      final titles = <String>[];

      for (final item in feed.items) {
        if (titles.length >= limit) break;

        if (item.title != null && item.title!.trim().isNotEmpty) {
          titles.add(item.title!.trim().toUpperCase());
        }
      }

      Logger.log('[NewsService] Parsed ${titles.length} titles');
      return titles;
    } catch (e) {
      Logger.error('[NewsService] Parse error: $e');
      return [];
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
      Logger.log('[NewsService] Cached ${titles.length} titles');
    } catch (e) {
      Logger.warn('[NewsService] Cache save error: $e');
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
        Logger.log('[NewsService] Cache expired (${cacheAge ~/ 1000}s)');
        return [];
      }

      final titles = (jsonDecode(cachedJson) as List).cast<String>();
      Logger.log('[NewsService] Returning ${titles.length} cached titles');
      return titles.take(limit).toList();
    } catch (e) {
      Logger.warn('[NewsService] Cache read error: $e');
      return [];
    }
  }

  /// Очистка кэша (для отладки)
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimestampKey);
      Logger.log('[NewsService] Cache cleared');
    } catch (e) {
      Logger.warn('[NewsService] Cache clear error: $e');
    }
  }

  /// Принудительное обновление (игнорируя кэш)
  Future<List<String>> forceRefresh({int limit = 5}) async {
    Logger.log('[NewsService] Force refresh');
    
    if (kIsWeb) {
      final titles = await _fetchNewsWeb(limit: limit);
      return titles;
    } else {
      final titles = await _fetchNewsNative(limit: limit);
      return titles;
    }
  }
}
