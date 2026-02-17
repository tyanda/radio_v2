import 'dart:convert';
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

  // Запасные короткие гороскопы (если API и перевод недоступны)
  static const Map<String, String> _sampleHoroscopes = {
    'aries':
        'Сегодня Овнам стоит проявить инициативу. Возможны успехи в профессиональной сфере.',
    'taurus':
        'Благоприятный день для финансовых вопросов. Сохраняйте спокойствие.',
    'gemini': 'Коммуникации на высоте. Отличное время для встреч и знакомств.',
    'cancer': 'Эмоциональный день. Обратите внимание на семью и уют.',
    'leo': 'Возможности для самореализации. Ваша харизма на пике.',
    'virgo': 'Внимание к деталям принесёт пользу. Рационализируйте планы.',
    'libra': 'Баланс во всём. Хороший день для соглашений и контактов.',
    'scorpio': 'Интенсивный день. Интуиция поможет принять решения.',
    'sagittarius': 'Приключения и новые горизонты в центре внимания.',
    'capricorn': 'Практичность будет вознаграждена. Сосредоточьтесь на целях.',
    'aquarius': 'Необычные идеи принесут успех. Будьте открыты новому.',
    'pisces': 'Творчество и духовность на первом плане.',
  };

  final GoogleTranslator _translator = GoogleTranslator();

  /// Основной метод: возвращает гороскоп на сегодня (переведённый на русский)
  Future<_HoroscopeResult> _fetchHoroscopeWithSource(String zodiacId) async {
    Logger.log('Fetching horoscope for: $zodiacId');

    // Шаг 1: кэш (самый быстрый путь)
    final cached = await _getCached(zodiacId);
    if (cached != null) {
      Logger.log('From cache');
      return _HoroscopeResult(cached, 'Кэш');
    }

    // Шаг 2: API Ninjas → английский текст
    final english = await _fetchApiNinjas(zodiacId);
    if (english == null || english.isEmpty) {
      Logger.log('API failed → sample fallback');
      final fallback =
          _sampleHoroscopes[zodiacId] ?? 'Сегодня благоприятный день.';
      await _saveCache(zodiacId, fallback); // кэшируем fallback тоже
      return _HoroscopeResult(fallback, 'Примерный прогноз');
    }

    // Шаг 3: перевод на русский
    final russian = await _translate(english);

    // Шаг 4: сохранение в кэш
    await _saveCache(zodiacId, russian);

    return _HoroscopeResult(russian, 'API Ninjas (переведено)');
  }

  /// Основной метод: возвращает гороскоп на сегодня (переведённый на русский)
  Future<String> fetchHoroscope(String zodiacId) async {
    final result = await _fetchHoroscopeWithSource(zodiacId);
    return result.text;
  }

  Future<String?> _getCached(String zodiacId) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final key = 'horoscope_${zodiacId}_$today';
    return prefs.getString(key);
  }

  Future<void> _saveCache(String zodiacId, String text) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final key = 'horoscope_${zodiacId}_$today';
    await prefs.setString(key, text);
    Logger.log('Cached: $key');
  }

  Future<String?> _fetchApiNinjas(String zodiacId) async {
    try {
      final key = AppConfig.apiNinjasKey.trim();
      if (key.isEmpty) {
        Logger.warn('No API key in AppConfig');
        return null;
      }

      final uri = Uri.parse(
        'https://api.api-ninjas.com/v1/horoscope?zodiac=$zodiacId',
      );

      final res = await http
          .get(uri, headers: {'X-Api-Key': key, 'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) {
        Logger.warn('API error ${res.statusCode}: ${res.body}');
        return null;
      }

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final text = json['horoscope'] as String?;
      if (text == null || text.isEmpty) {
        Logger.warn('Empty horoscope field');
        return null;
      }

      Logger.log('English text received');
      return text;
    } catch (e) {
      Logger.warn('API exception: $e');
      return null;
    }
  }

  Future<String> _translate(String english) async {
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
        Logger.log('Translated (${result.length} chars)');
        return result;
      }
    } catch (e) {
      Logger.warn('Translate error: $e');
    }

    Logger.warn('Translation failed → return English');
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
    Logger.log('Cache cleared');
  }

  /// Полная очистка кэша (один раз для миграции)
  static Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Logger.log('All cache cleared');
  }
}
