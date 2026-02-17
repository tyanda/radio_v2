import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dart_rss/dart_rss.dart';
import '../core/config.dart';

class RssService {
  final http.Client _client;
  static String get _rssUrl => AppConfig.rssFeedUrl;
  static const String _userAgent = 'SakhaRadio/1.0';

  RssService(this._client);

  /// Получает RSS-ленту и возвращает список заголовков новостей
  Future<List<String>> fetchNewsTitles({int limit = 5}) async {
    try {
      String body;
      
      // Для веба используем CORS-прокси с запасными вариантами
      if (kIsWeb) {
        final proxyUrls = [
          'https://thingproxy.freeboard.io/fetch/${Uri.encodeComponent(_rssUrl)}',
          'https://corsproxy.info/?${Uri.encodeComponent(_rssUrl)}',
        ];
        
        String content = '';
        
        for (final proxyUrl in proxyUrls) {
          try {
            final response = await _client.get(Uri.parse(proxyUrl));
            if (response.statusCode == 200) {
              content = response.body;
              break;
            }
          } catch (_) {
            continue;
          }
        }
        
        // Если прокси не сработали, используем заглушку
        if (content.isEmpty) {
          return [
            'ДОБРО ПОЖАЛОВАТЬ В SAKHA LIVE',
            'ОСТАВАЙТЕСЬ С НАМИ',
          ];
        }
        
        body = content;
      } else {
        final response = await _client.get(Uri.parse(_rssUrl));
        if (response.statusCode != 200) {
          throw Exception('Ошибка получения RSS-ленты: ${response.statusCode}');
        }
        body = response.body;
      }
      
      final feed = RssFeed.parse(body);
      final titles = <String>[];

      for (final item in feed.items) {
        if (titles.length >= limit) break;

        if (item.title != null && item.title!.trim().isNotEmpty) {
          titles.add(item.title!.trim().toUpperCase());
        }
      }

      return titles;
    } catch (e) {
      throw Exception('Ошибка при загрузке новостей: $e');
    }
  }

  /// Получает RSS-ленту и возвращает полные данные
  Future<RssFeed> fetchRssFeed() async {
    try {
      final response = await _client.get(
        Uri.parse(_rssUrl),
        headers: {'User-Agent': _userAgent},
      );

      if (response.statusCode == 200) {
        return RssFeed.parse(response.body);
      } else {
        throw Exception('Ошибка получения RSS-ленты: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка при загрузке RSS-ленты: $e');
    }
  }
}
