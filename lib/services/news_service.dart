import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../core/config.dart';
import '../core/utils/logger.dart';

// Импорт для веб-версии
import 'package:web/web.dart' as web;

/// Сервис для получения RSS через CORS-прокси
///
/// Преимущества:
/// - Бесплатно (используется corsproxy.io)
/// - Надёжно
/// - Нет CORS проблем
/// - Быстро (кэширование)
class NewsService {
  final Dio _dio;
  bool _isRefreshing = false; // Флаг для предотвращения рекурсии

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
    Logger.log('Web: Fetching via RSS2JSON', tag: 'NewsService');

    try {
      // Сначала пробуем загрузить из кэша
      final cached = await _getCachedTitles(limit);
      if (cached.isNotEmpty) {
        Logger.log('Web: Using cached titles', tag: 'NewsService');
        // Возвращаем кэш, но в фоне обновляем (только если нет уже идущего запроса)
        if (!_isRefreshing) {
          _isRefreshing = true;
          _fetchNewsWeb(limit: limit).then((titles) {
            if (titles.isNotEmpty) {
              _cacheTitles(titles);
            }
          }).whenComplete(() {
            _isRefreshing = false;
          });
        }
        return cached;
      }

      // Кэша нет — загружаем через RSS2JSON
      // https://rss2json.com/
      final rss2JsonUrl =
          'https://api.rss2json.com/v1/api.json?rss_url=${Uri.encodeComponent(_directRssUrl)}';

      Logger.log('Web URL: $rss2JsonUrl', tag: 'NewsService');

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
              'Web: Parsed ${titles.length} titles via RSS2JSON',
              tag: 'NewsService',
            );
            // Кэшируем успешный результат
            _cacheTitles(titles);
            return titles;
          }
        }

        Logger.warn(
          'Web: RSS2JSON returned error or empty: ${data?['message']}',
          tag: 'NewsService',
        );
      } else {
        Logger.error(
          'Web: RSS2JSON status ${response.statusCode}',
          tag: 'NewsService',
        );
      }

      // Если RSS2JSON не сработал, возвращаем заглушку
      return ["НЕТ НОВОСТЕЙ", "ОСТАВАЙТЕСЬ С НАМИ"];
    } catch (e) {
      Logger.error('Web Error: $e', tag: 'NewsService');
      return ["ЗАГРУЗКА НОВОСТЕЙ...", "ПРОВЕРЬТЕ ИНТЕРНЕТ"];
    }
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
      if (kIsWeb) {
        // Для веба используем напрямую localStorage
        web.window.localStorage.setItem(_cacheKey, jsonEncode(titles));
        web.window.localStorage.setItem(
          _cacheTimestampKey,
          DateTime.now().millisecondsSinceEpoch.toString(),
        );
      } else {
        // Для нативных платформ — SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, jsonEncode(titles));
        await prefs.setInt(
          _cacheTimestampKey,
          DateTime.now().millisecondsSinceEpoch,
        );
      }
      Logger.log('Cached ${titles.length} titles', tag: 'NewsService');
    } catch (e) {
      Logger.warn('Cache save error: $e', tag: 'NewsService');
    }
  }

  /// Получение кэшированных заголовков
  Future<List<String>> _getCachedTitles(int limit) async {
    try {
      String? cachedJson;
      int? timestamp;

      if (kIsWeb) {
        // Для веба используем напрямую localStorage
        cachedJson = web.window.localStorage.getItem(_cacheKey);
        final timestampStr = web.window.localStorage.getItem(_cacheTimestampKey);
        if (timestampStr != null && timestampStr.isNotEmpty) {
          timestamp = int.tryParse(timestampStr);
        }
      } else {
        // Для нативных платформ — SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        cachedJson = prefs.getString(_cacheKey);
        timestamp = prefs.getInt(_cacheTimestampKey);
      }

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
      if (kIsWeb) {
        // Для веба используем напрямую localStorage
        web.window.localStorage.removeItem(_cacheKey);
        web.window.localStorage.removeItem(_cacheTimestampKey);
      } else {
        // Для нативных платформ — SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_cacheKey);
        await prefs.remove(_cacheTimestampKey);
      }
      Logger.log('Cache cleared', tag: 'NewsService');
    } catch (e) {
      Logger.warn('Cache clear error: $e', tag: 'NewsService');
    }
  }

  /// Принудительное обновление (игнорируя кэш)
  Future<List<String>> forceRefresh({int limit = 5}) async {
    Logger.log('Force refresh', tag: 'NewsService');

    if (kIsWeb) {
      final titles = await _fetchNewsWeb(limit: limit);
      // Кэшируем результат
      if (titles.isNotEmpty) {
        await _cacheTitles(titles);
      }
      return titles;
    } else {
      final titles = await _fetchNewsNative(limit: limit);
      return titles;
    }
  }
}
