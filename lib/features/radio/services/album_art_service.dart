import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/utils/logger.dart';

/// Сервис для поиска обложек альбомов через iTunes API
///
/// Возможности:
/// - Кэширование результатов в памяти
/// - Rate limiting (макс. 20 запросов в минуту)
/// - Retry logic при ошибках сети
/// - Timeout для HTTP запросов
///
/// Использование:
/// ```dart
/// final service = AlbumArtService();
/// final artUrl = await service.searchAlbumArt(artist: 'KitJah', title: 'Kousyun');
/// ```
class AlbumArtService {
  static const _baseUrl = 'https://itunes.apple.com/search';
  static const _maxRequestsPerMinute = 20;
  static const _cacheExpiration = Duration(minutes: 30);

  // Кэш: ключ -> (URL обложки, время кэширования)
  final Map<String, _CacheEntry> _cache = {};

  // Rate limiting: список временных меток запросов
  final List<DateTime> _requestTimestamps = [];

  // Флаг для отслеживания текущих запросов
  final Map<String, Completer<String?>> _pendingRequests = {};

  /// Поиск обложки альбома по артисту и названию трека
  /// Возвращает URL обложки в высоком качестве (1200x1200)
  Future<String?> searchAlbumArt({String? artist, String? title}) async {
    if (artist == null && title == null) return null;

    // Создаём ключ кэша
    final cacheKey = _createCacheKey(artist, title);

    // Проверяем кэш
    if (_cache.containsKey(cacheKey)) {
      final entry = _cache[cacheKey]!;
      if (DateTime.now().difference(entry.timestamp) < _cacheExpiration) {
        Logger.log('🎨 AlbumArt: Cache hit: $cacheKey', tag: 'AlbumArt');
        return entry.artUrl;
      } else {
        // Истёк срок кэша
        _cache.remove(cacheKey);
      }
    }

    // Проверяем, есть ли уже pending запрос с таким же ключом
    if (_pendingRequests.containsKey(cacheKey)) {
      Logger.log(
        '🎨 AlbumArt: Waiting for pending request: $cacheKey',
        tag: 'AlbumArt',
      );
      return _pendingRequests[cacheKey]!.future;
    }

    // Rate limiting
    await _waitForRateLimit();

    // Создаём completer для отслеживания запроса
    final completer = Completer<String?>();
    _pendingRequests[cacheKey] = completer;

    try {
      final result = await _performSearch(artist, title, cacheKey);
      completer.complete(result);
      return result;
    } catch (e) {
      completer.completeError(e);
      return null;
    } finally {
      _pendingRequests.remove(cacheKey);
    }
  }

  /// Выполнение HTTP запроса к iTunes API
  Future<String?> _performSearch(
    String? artist,
    String? title,
    String cacheKey,
  ) async {
    try {
      // Формируем поисковый запрос
      final query = [
        if (artist != null && artist.isNotEmpty) 'term=$artist',
        if (title != null && title.isNotEmpty) ...[
          artist != null && artist.isNotEmpty ? '+$title' : 'term=$title',
        ],
      ].join('+');

      if (query.isEmpty) return null;

      final url = Uri.parse('$_baseUrl?media=music&limit=1&$query');

      Logger.log(
        '🎨 AlbumArt: Searching for: artist="$artist", title="$title"',
        tag: 'AlbumArt',
      );

      // Retry logic: до 3 попыток
      String? artUrl;
      int attempts = 0;
      const maxAttempts = 3;

      while (attempts < maxAttempts && artUrl == null) {
        attempts++;

        try {
          final response = await http
              .get(url)
              .timeout(
                const Duration(seconds: 5),
                onTimeout: () {
                  Logger.log(
                    'AlbumArt: Request timeout (attempt $attempts)',
                    tag: 'AlbumArt',
                  );
                  return http.Response('{"resultCount":0}', 408);
                },
              );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final results = data['results'] as List;

            if (results.isNotEmpty) {
              // Получаем обложку в высоком качестве (1200x1200)
              final artUrlRaw = results.first['artworkUrl100'] as String;
              artUrl = artUrlRaw.replaceAll('100x100bb', '1200x1200');

              // Кэшируем результат
              _cacheResult(cacheKey, artUrl);

              Logger.log('🎨 AlbumArt: Found: $artUrl', tag: 'AlbumArt');
            } else {
              Logger.log('AlbumArt: No results found', tag: 'AlbumArt');
              // Кэшируем null результат на 5 минут
              _cacheResult(cacheKey, null, expiration: Duration(minutes: 5));
            }
          } else {
            Logger.log(
              'AlbumArt: API error: ${response.statusCode} (attempt $attempts)',
              tag: 'AlbumArt',
            );

            if (attempts < maxAttempts) {
              // Ждём перед следующей попыткой (exponential backoff)
              await Future.delayed(Duration(milliseconds: 500 * attempts));
            }
          }
        } on TimeoutException catch (e) {
          Logger.log(
            'AlbumArt: Timeout: $e (attempt $attempts)',
            tag: 'AlbumArt',
          );

          if (attempts < maxAttempts) {
            await Future.delayed(Duration(milliseconds: 500 * attempts));
          }
        }
      }

      return artUrl;
    } catch (e) {
      Logger.log('AlbumArt: Error: $e', tag: 'AlbumArt');
      return null;
    }
  }

  /// Ожидание для соблюдения rate limiting
  Future<void> _waitForRateLimit() async {
    final now = DateTime.now();

    // Удаляем старые метки (старше 1 минуты)
    _requestTimestamps.removeWhere(
      (timestamp) => now.difference(timestamp) > const Duration(minutes: 1),
    );

    // Если достигнут лимит, ждём
    if (_requestTimestamps.length >= _maxRequestsPerMinute) {
      final oldestTimestamp = _requestTimestamps.first;
      final waitDuration =
          const Duration(minutes: 1) - now.difference(oldestTimestamp);

      if (waitDuration > Duration.zero) {
        Logger.log(
          '🎨 AlbumArt: Rate limit reached, waiting ${waitDuration.inSeconds}s',
          tag: 'AlbumArt',
        );
        await Future.delayed(waitDuration);
        // Рекурсивно проверяем снова
        await _waitForRateLimit();
      }
    }

    // Добавляем текущую метку
    _requestTimestamps.add(now);
  }

  /// Кэширование результата
  void _cacheResult(String key, String? artUrl, {Duration? expiration}) {
    _cache[key] = _CacheEntry(
      artUrl: artUrl,
      timestamp: DateTime.now(),
      expiration: expiration ?? _cacheExpiration,
    );

    Logger.log(
      '🎨 AlbumArt: Cached: $key (${artUrl != null ? "hit" : "miss"})',
      tag: 'AlbumArt',
    );
  }

  /// Создание ключа кэша из параметров
  String _createCacheKey(String? artist, String? title) {
    return '${artist?.toLowerCase() ?? ''}|${title?.toLowerCase() ?? ''}';
  }

  /// Очистка кэша
  void clearCache() {
    _cache.clear();
    Logger.log('🎨 AlbumArt: Cache cleared', tag: 'AlbumArt');
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

  /// Получить статистику кэша
  CacheStats getCacheStats() {
    final now = DateTime.now();
    final validEntries = _cache.values
        .where((entry) => now.difference(entry.timestamp) < entry.expiration)
        .length;

    return CacheStats(
      totalEntries: _cache.length,
      validEntries: validEntries,
      pendingRequests: _pendingRequests.length,
    );
  }
}

/// Запись кэша
class _CacheEntry {
  final String? artUrl;
  final DateTime timestamp;
  final Duration expiration;

  _CacheEntry({
    required this.artUrl,
    required this.timestamp,
    required this.expiration,
  });
}

/// Статистика кэша
class CacheStats {
  final int totalEntries;
  final int validEntries;
  final int pendingRequests;

  CacheStats({
    required this.totalEntries,
    required this.validEntries,
    required this.pendingRequests,
  });

  @override
  String toString() {
    return 'CacheStats(total: $totalEntries, valid: $validEntries, pending: $pendingRequests)';
  }
}
