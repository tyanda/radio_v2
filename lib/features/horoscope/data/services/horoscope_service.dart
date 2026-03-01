import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config.dart';
import '../../../../core/utils/logger.dart';
import '../models/horoscope_data.dart';

/// Результат с информацией об источнике
class _HoroscopeResult {
  final String text;
  final String source;

  _HoroscopeResult(this.text, this.source);
}

class HoroscopeService {
  // Знаки зодиака: английский → русский
  static const Map<String, String> _zodiacMap = {
    'aries': 'Овен',
    'taurus': 'Телец',
    'gemini': 'Близнецы',
    'cancer': 'Рак',
    'leo': 'Лев',
    'virgo': 'Дева',
    'libra': 'Весы',
    'scorpio': 'Скорпион',
    'sagittarius': 'Стрелец',
    'capricorn': 'Козерог',
    'aquarius': 'Водолей',
    'pisces': 'Рыбы',
  };

  // Запасные гороскопы (используются при ошибках API)
  static const Map<String, String> _sampleHoroscopes = {
    'aries':
        'Сегодня Овнам стоит проявить инициативу. Ваши идеи встретят поддержку у коллег и руководства. Вечер благоприятен для физической активности.',
    'taurus':
        'Благоприятный день для финансовых планирований. Ваше упорство поможет довести начатое до конца. В личных отношениях возможен приятный сюрприз.',
    'gemini':
        'Отличный день для общения и получения новых знаний. Возможны неожиданные новости, которые изменят ваши планы на неделю в лучшую сторону.',
    'cancer':
        'Сегодня интуиция подскажет верный путь в сложных вопросах. Уделите время дому и близким — это поможет восстановить душевное равновесие.',
    'leo':
        'Ваша энергия и харизма сегодня на пике. Прекрасное время для выступлений и презентаций. Не бойтесь брать на себя ответственность за важные проекты.',
    'virgo':
        'Внимание к деталям сегодня станет вашим главным преимуществом. День подходит для наведения порядка в делах и планирования долгосрочных целей.',
    'libra':
        'Гармоничный день для переговоров и примирения. Ваша способность находить компромиссы поможет избежать конфликтов в коллективе.',
    'scorpio':
        'Энергичный день, когда любые преграды будут по плечу. Интуиция поможет разоблачить тайных недоброжелателей. Будьте смелее в своих желаниях.',
    'sagittarius':
        'Сегодня открываются новые горизонты. Возможны предложения о поездках или начале обучения. Оптимизм поможет преодолеть любые мелкие неурядицы.',
    'capricorn':
        'Ваша практичность и дисциплина принесут долгожданные плоды. Хороший день для завершения старых дел и укрепления профессиональной репутации.',
    'aquarius':
        'День полон творческих идей и необычных озарений. Друзья или единомышленники помогут воплотить ваши самые смелые задумки в жизнь.',
    'pisces':
        'Творческий потенциал сегодня не знает границ. Уделите время искусству или медитации. Вечер обещает быть спокойным и вдохновляющим.',
  };

  final GoogleTranslator _translator = GoogleTranslator();

  /// Основной метод: возвращает гороскоп на сегодня (переведённый на русский)
  Future<_HoroscopeResult> _fetchHoroscopeWithSource(String zodiacId) async {
    Logger.log('=== Fetching horoscope for: $zodiacId ===', tag: 'Horoscope');

    // Шаг 1: кэш
    final cached = await _getCached(zodiacId);
    if (cached != null && cached.length > 10) {
      Logger.log('✓ Found valid cache for $zodiacId', tag: 'Horoscope');
      return _HoroscopeResult(cached, 'Кэш');
    }

    // Шаг 2: APIVerve API (Native only)
    if (!kIsWeb) {
      final apiVerveEnglish = await _fetchApiVerve(zodiacId);
      if (apiVerveEnglish != null && apiVerveEnglish.length > 5) {
        final apiVerveRussian = await _translate(apiVerveEnglish);
        if (apiVerveRussian.length > 5) {
          await _saveCache(zodiacId, apiVerveRussian);
          return _HoroscopeResult(apiVerveRussian, 'APIVerve');
        }
      }
    }

    // Шаг 3: API Ninjas
    final english = await _fetchApiNinjas(zodiacId);
    if (english != null && english.length > 5) {
      final russian = await _translate(english);
      if (russian.length > 5) {
        await _saveCache(zodiacId, russian);
        return _HoroscopeResult(russian, 'API Ninjas');
      }
    }

    // Шаг 4: Fallback (Samples)
    Logger.warn(
      'All APIs failed for $zodiacId, using sample',
      tag: 'Horoscope',
    );
    final sample =
        _sampleHoroscopes[zodiacId] ??
        'Сегодня вас ждет удачный день. Доверяйте своей интуиции и не бойтесь новых начинаний.';
    return _HoroscopeResult(sample, 'Прогноз');
  }

  /// Основной метод: возвращает гороскоп на сегодня
  Future<String> fetchHoroscope(String zodiacId) async {
    final result = await _fetchHoroscopeWithSource(zodiacId);
    return result.text;
  }

  Future<String?> _getCached(String zodiacId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'horoscope_$zodiacId';
      final timestampKey = 'horoscope_${zodiacId}_timestamp';

      final cachedText = prefs.getString(key);
      final timestamp = prefs.getInt(timestampKey);

      if (cachedText == null || timestamp == null || cachedText.isEmpty) {
        return null;
      }

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final age = now - timestamp;
      final maxAge = 24 * 60 * 60; // 24 часа

      if (age > maxAge) {
        return null; // Просрочен
      }

      return cachedText;
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveCache(String zodiacId, String text) async {
    if (text.isEmpty || text.length < 10) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('horoscope_$zodiacId', text);
      await prefs.setInt(
        'horoscope_${zodiacId}_timestamp',
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );
    } catch (e) {
      Logger.error('Error saving cache: $e', tag: 'Horoscope');
    }
  }

  Future<String?> _fetchApiVerve(String zodiacId) async {
    try {
      final key = AppConfig.apiVerveKey.trim();
      if (key.isEmpty) return null;

      final uri = Uri.parse(
        'https://api.apiverve.com/v1/horoscope?sign=$zodiacId',
      );
      final res = await http
          .get(uri, headers: {'x-api-key': key})
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['status'] == 'ok') {
          return json['data']['horoscope']?.toString();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> _fetchApiNinjas(String zodiacId) async {
    try {
      final key = AppConfig.apiNinjasKey.trim();
      if (key.isEmpty) return null;

      final uri = Uri.parse(
        'https://api.api-ninjas.com/v1/horoscope?zodiac=$zodiacId',
      );
      final res = await http
          .get(uri, headers: {'X-Api-Key': key})
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        // API Ninjas может возвращать массив или объект
        if (json is List && json.isNotEmpty) {
          return json[0]['horoscope']?.toString();
        } else if (json is Map) {
          return json['horoscope']?.toString();
        }
      }
      Logger.warn('API Ninjas error: ${res.statusCode}', tag: 'Horoscope');
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String> _translate(String english) async {
    Logger.log('Translating (${english.length} chars)...', tag: 'Horoscope');
    try {
      final trans = await _translator.translate(english, from: 'en', to: 'ru');
      var result = trans.text.trim();
      if (result.isNotEmpty) {
        // Пост-обработка: нормализация текста
        result = result
            .replaceAll(' ,', ',')
            .replaceAll(' .', '.')
            .replaceAll(' !', '!')
            .replaceAll(' ?', '?')
            .replaceAll(' ;', ';')
            .replaceAll(' :', ':')
            .replaceAll(RegExp(r'\s+'), ' ');
        Logger.log('✓ Translated (${result.length} chars)', tag: 'Horoscope');
        return result;
      } else {
        Logger.warn('Translate returned empty result', tag: 'Horoscope');
      }
    } catch (e) {
      Logger.error('Translate exception: $e', tag: 'Horoscope');
    }

    Logger.warn('Translation failed → return English', tag: 'Horoscope');
    return english;
  }

  /// Для экрана: полный объект гороскопа
  Future<HoroscopeData> getHoroscope(String sign, String period) async {
    final result = await _fetchHoroscopeWithSource(sign);
    final ruName = _zodiacMap[sign] ?? sign;
    final title = '$ruName — Гороскоп на сегодня';

    return HoroscopeData(
      sign: ruName,
      title: title,
      text: result.text,
      period: period,
      source: result.source,
    );
  }

  /// Список знаков для выбора в UI
  static Map<String, String> getZodiacSigns() => _zodiacMap;

  /// Очистка кэша гороскопов
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('horoscope_'));
    for (final key in keys) {
      await prefs.remove(key);
    }
    Logger.log('Cache cleared', tag: 'Horoscope');
  }
}
