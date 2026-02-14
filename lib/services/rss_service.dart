import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:dart_rss/dart_rss.dart';

class RssService {
  final http.Client _client;
  static const String _rssUrl = 'https://ysia.ru/feed/';
  static const String _userAgent = 'SakhaRadio/1.0';

  RssService(this._client);

  /// Получает RSS-ленту и возвращает список заголовков новостей
  Future<List<String>> fetchNewsTitles({int limit = 5}) async {
    try {
      final uri = kIsWeb
          ? Uri.parse('https://corsproxy.io/?${Uri.encodeComponent(_rssUrl)}')
          : Uri.parse(_rssUrl);

      final response = await _client.get(
        uri,
        headers: {'User-Agent': _userAgent},
      );

      if (response.statusCode == 200) {
        final feed = RssFeed.parse(response.body);
        final titles = <String>[];

        for (final item in feed.items) {
          if (titles.length >= limit) break;

          if (item.title != null && item.title!.trim().isNotEmpty) {
            titles.add(item.title!.trim().toUpperCase());
          }
        }

        return titles;
      } else {
        throw Exception('Ошибка получения RSS-ленты: ${response.statusCode}');
      }
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
