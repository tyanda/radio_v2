import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/horoscope_data.dart';

class HoroscopeService {
  // Используем прокси-сервер для обхода CORS
  static const String baseUrl = 'http://localhost:5000/api'; // Адрес нашего прокси-сервера

  Future<HoroscopeData> getHoroscope(String sign, String period) async {
    try {
      // Сначала пробуем получить данные из альтернативного источника (JSON API)
      try {
        final url = Uri.parse('$baseUrl/horoscope/$sign');
        
        final response = await http.get(
          url,
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
            'Accept': 'application/json',
            'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
          },
        );

        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          
          // Проверяем, есть ли в ответе нужные поля
          if (jsonData.containsKey('horoscope')) {
            return HoroscopeData(
              sign: sign,
              title: '${_getSignName(sign)} - Гороскоп на сегодня',
              text: jsonData['horoscope'],
              period: period,
            );
          }
        }
      } catch (e) {
        // Если альтернативный источник не сработал, используем основной
        // ignore: avoid_print
        print('Альтернативный источник не сработал: $e');
      }

      // Если альтернативный источник не сработал, используем основной метод (через HTML-парсинг)
      final url = Uri.parse('$baseUrl/horo-full/$sign/$period');

      final response = await http.get(
        url,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
          'Upgrade-Insecure-Requests': '1',
        },
      );

      if (response.statusCode == 200) {
        // Извлечение данных из HTML-ответа
        final html = utf8.decode(response.bodyBytes);
        return _parseHoroscope(html, sign, period);
      } else {
        response.statusCode >= 400 && response.statusCode < 500
            ? throw Exception('Ошибка клиента: ${response.statusCode}')
            : throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Не удалось подключиться к серверу прогнозов: $e');
    }
  }

  // Вспомогательная функция для получения названия знака зодиака
  String _getSignName(String sign) {
    switch (sign) {
      case 'aries': return 'Овен';
      case 'taurus': return 'Телец';
      case 'gemini': return 'Близнецы';
      case 'cancer': return 'Рак';
      case 'leo': return 'Лев';
      case 'virgo': return 'Дева';
      case 'libra': return 'Весы';
      case 'scorpio': return 'Скорпион';
      case 'sagittarius': return 'Стрелец';
      case 'capricorn': return 'Козерог';
      case 'aquarius': return 'Водолей';
      case 'pisces': return 'Рыбы';
      default: return sign;
    }
  }

  HoroscopeData _parseHoroscope(String html, String sign, String period) {
    // Используем парсинг для извлечения данных из HTML, следуя логике Python-скрипта

    // Ищем заголовок гороскопа
    final titleMatch = RegExp(
      r'<h1[^>]*>(.*?)</h1>',
      dotAll: true,
    ).firstMatch(html);
    final title = titleMatch != null
        ? _decodeHtmlEntities(_removeHtmlTags(titleMatch.group(1)!)).trim()
        : 'Гороскоп';

    // Ищем основной текст гороскопа
    // Обновляем регулярные выражения для соответствия новой структуре сайта
    final articleRegex = RegExp(r'<article[^>]*>(.*?)</article>', dotAll: true);
    final divRegex = RegExp(
      r'<div[^>]*class="[^"]*article__item[^"]*"[^>]*>(.*?)</div>',
      dotAll: true,
    );
    final dataQaRegex = RegExp(
      r'<div[^>]*data-qa="[^"]*ArticleLayout[^"]*"[^>]*>(.*?)</div>',
      dotAll: true,
    );
    
    // Добавим новые возможные селекторы для актуальной версии сайта
    final contentRegex = RegExp(
      r'<div[^>]*class="[^"]*prediction__content[^"]*"[^>]*>(.*?)</div>',
      dotAll: true,
    );
    final textRegex = RegExp(
      r'<div[^>]*class="[^"]*item-text[^"]*"[^>]*>(.*?)</div>',
      dotAll: true,
    );
    final mainContentRegex = RegExp(
      r'<div[^>]*class="[^"]*main-content[^"]*"[^>]*>(.*?)</div>',
      dotAll: true,
    );

    String? horoscopeText;

    // Основные селекторы, в порядке приоритета
    horoscopeText =
        articleRegex.firstMatch(html)?.group(1) ??
        contentRegex.firstMatch(html)?.group(1) ??
        textRegex.firstMatch(html)?.group(1) ??
        divRegex.firstMatch(html)?.group(1) ??
        dataQaRegex.firstMatch(html)?.group(1) ??
        mainContentRegex.firstMatch(html)?.group(1);

    // Запасной селектор, если верстка изменилась
    horoscopeText ??= _findPredictionContent(html);

    if (horoscopeText == null) {
      throw Exception('Контент гороскопа не найден на странице.');
    }

    // Очищаем HTML-теги
    horoscopeText = _removeHtmlTags(horoscopeText);
    horoscopeText = _decodeHtmlEntities(horoscopeText);

    return HoroscopeData(
      sign: sign,
      title: title,
      text: horoscopeText.trim(),
      period: period,
    );
  }

  // Метод для поиска контента гороскопа, если основные селекторы не сработали
  String? _findPredictionContent(String html) {
    // Ищем контент в div с классом, содержащим "prediction"
    final predictionRegex = RegExp(
      r'<div[^>]*class="[^"]*prediction[^"]*"[^>]*>(.*?)</div>',
      dotAll: true,
    );
    var match = predictionRegex.firstMatch(html);
    if (match != null) {
      return match.group(1);
    }

    // Ищем контент с другими возможными классами
    final possibleSelectors = [
      r'<div[^>]*class="[^"]*item[^"]*"[^>]*>(.*?)</div>',
      r'<p[^>]*class="[^"]*prediction[^"]*"[^>]*>(.*?)</p>',
      r'<span[^>]*class="[^"]*prediction[^"]*"[^>]*>(.*?)</span>',
      r'<div[^>]*id="[^"]*prediction[^"]*"[^>]*>(.*?)</div>',
      r'<section[^>]*class="[^"]*prediction[^"]*"[^>]*>(.*?)</section>',
    ];

    for (var selector in possibleSelectors) {
      final regExp = RegExp(selector, dotAll: true);
      match = regExp.firstMatch(html);
      if (match != null) {
        return match.group(1);
      }
    }

    // Если не нашли, пробуем другие возможные селекторы
    final commonContentRegex = RegExp(
      r'<div[^>]*class="[^"]*(?:article|content|text|item)[^"]*"[^>]*>(.*?)</div>',
      dotAll: true,
    );
    match = commonContentRegex.firstMatch(html);
    if (match != null) {
      return match.group(1);
    }

    // Если ничего не нашли, возвращаем null
    return null;
  }

  String _removeHtmlTags(String html) {
    // Удаляем HTML-теги, но оставляем переводы строк
    return html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\n\s*\n'), '\n'); // Убираем лишние пустые строки
  }

  String _decodeHtmlEntities(String text) {
    // Простая замена некоторых HTML-сущностей
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&#x27;', "'");
  }
}
