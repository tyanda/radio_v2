import 'package:http/http.dart' as http;
import 'package:dart_rss/dart_rss.dart';

class RssService {
  static const String _rssUrl = 'https://ysia.ru/feed/';
  static const String _userAgent = 'SakhaRadio/1.0';

  /// Получает RSS-ленту и возвращает список заголовков новостей
  static Future<List<String>> fetchNewsTitles({int limit = 5}) async {
    try {
      final response = await http.get(
        Uri.parse(_rssUrl),
        headers: {'User-Agent': _userAgent},
      );

      if (response.statusCode == 200) {
        final feed = RssFeed.parse(response.body);
        final titles = <String>[];

        for (final item in feed.items) {
          if (item.title != null && item.title!.isNotEmpty && titles.length < limit) {
            titles.add(item.title!.toUpperCase());
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
  static Future<RssFeed> fetchRssFeed() async {
    try {
      final response = await http.get(
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