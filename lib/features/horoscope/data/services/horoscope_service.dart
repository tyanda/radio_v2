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

  // Запасные короткие гороскопы (если API недоступны)
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
    Logger.log('=== Fetching horoscope for: $zodiacId ===', tag: 'Horoscope');
    Logger.log('API_NINJAS_KEY configured: ${AppConfig.apiNinjasKey.isNotEmpty}', tag: 'Horoscope');
    Logger.log('API_VERVE_KEY configured: ${AppConfig.apiVerveKey.isNotEmpty}', tag: 'Horoscope');

    // Шаг 1: кэш (самый быстрый путь)
    final cached = await _getCached(zodiacId);
    if (cached != null) {
      Logger.log('✓ From cache', tag: 'Horoscope');
      return _HoroscopeResult(cached, 'Кэш');
    }

    Logger.log('Cache miss, trying APIs...', tag: 'Horoscope');

    // Шаг 2: APIVerve API (только для нативных платформ)
    // На вебе CORS блокирует запросы к APIVerve
    if (!kIsWeb) {
      Logger.log('Native platform: trying APIVerve...', tag: 'Horoscope');
      final apiVerveEnglish = await _fetchApiVerve(zodiacId);
      if (apiVerveEnglish != null && apiVerveEnglish.isNotEmpty) {
        Logger.log(
          'APIVerve returned English text, translating...',
          tag: 'Horoscope',
        );
        final apiVerveRussian = await _translate(apiVerveEnglish);
        await _saveCache(zodiacId, apiVerveRussian);
        return _HoroscopeResult(apiVerveRussian, 'APIVerve');
      }
      Logger.log('APIVerve failed, trying API Ninjas...', tag: 'Horoscope');
    } else {
      Logger.log(
        'Web platform: skipping APIVerve (CORS restriction)',
        tag: 'Horoscope',
      );
    }

    // Шаг 3: API Ninjas → английский текст
    Logger.log('Trying API Ninjas...', tag: 'Horoscope');
    final english = await _fetchApiNinjas(zodiacId);
    if (english == null || english.isEmpty) {
      Logger.log('API Ninjas failed, using sample horoscope', tag: 'Horoscope');
      // Используем запасной гороскоп
      final sample =
          _sampleHoroscopes[zodiacId] ?? 'Сегодня благоприятный день.';
      await _saveCache(zodiacId, sample);
      return _HoroscopeResult(sample, 'Прогноз');
    }

    // Шаг 4: перевод на русский
    Logger.log(
      'API Ninjas returned English text, translating...',
      tag: 'Horoscope',
    );
    final russian = await _translate(english);

    // Шаг 5: сохранение в кэш
    await _saveCache(zodiacId, russian);

    return _HoroscopeResult(russian, 'API Ninjas (переведено)');
  }

  /// Основной метод: возвращает гороскоп на сегодня (переведённый на русский)
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
      
      if (cachedText == null || timestamp == null) {
        return null;
      }
      
      // Проверяем срок действия кэша (24 часа = 86400 секунд)
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final age = now - timestamp;
      final maxAge = 24 * 60 * 60; // 24 часа
      
      Logger.log('Cache age: ${age ~/ 3600}h ${((age % 3600) / 60).toInt()}m (max: ${maxAge ~/ 3600}h)', tag: 'Horoscope');
      
      if (age > maxAge) {
        Logger.log('Cache expired, will fetch fresh', tag: 'Horoscope');
        // Не удаляем старый кэш — используем как fallback
        return null;
      }
      
      Logger.log('Cache is fresh', tag: 'Horoscope');
      return cachedText;
    } catch (e) {
      Logger.error('Error reading cache: $e', tag: 'Horoscope');
      return null;
    }
  }

  Future<void> _saveCache(String zodiacId, String text) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'horoscope_$zodiacId';
      final timestampKey = 'horoscope_${zodiacId}_timestamp';
      
      await prefs.setString(key, text);
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await prefs.setInt(timestampKey, now);
      
      Logger.log('Cached: $key with timestamp', tag: 'Horoscope');
    } catch (e) {
      Logger.error('Error saving cache: $e', tag: 'Horoscope');
    }
  }

  Future<String?> _fetchApiVerve(String zodiacId) async {
    try {
      final key = AppConfig.apiVerveKey.trim();
      Logger.log(
        'APIVerve key length: ${key.length}, empty: ${key.isEmpty}',
        tag: 'Horoscope',
      );

      if (key.isEmpty) {
        Logger.warn('APIVerve key not configured', tag: 'Horoscope');
        return null;
      }

      final apiUri = 'https://api.apiverve.com/v1/horoscope?sign=$zodiacId';
      final uri = Uri.parse(apiUri);

      Logger.log('APIVerve request URL: $uri', tag: 'Horoscope');

      // Заголовки
      final headers = {'x-api-key': key, 'Accept': 'application/json'};

      final res = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      Logger.log(
        'APIVerve response status: ${res.statusCode}',
        tag: 'Horoscope',
      );
      Logger.log('APIVerve response body: ${res.body}', tag: 'Horoscope');

      if (res.statusCode != 200) {
        Logger.warn(
          'APIVerve error ${res.statusCode}: ${res.body}',
          tag: 'Horoscope',
        );
        return null;
      }

      final json = jsonDecode(res.body) as Map<String, dynamic>;

      // Проверяем статус ответа
      final status = json['status'] as String?;
      Logger.log('APIVerve status: $status', tag: 'Horoscope');

      if (status != 'ok') {
        final error = json['error'] as String?;
        Logger.warn('APIVerve API error: $error', tag: 'Horoscope');
        return null;
      }

      // Извлекаем данные
      final data = json['data'] as Map<String, dynamic>?;
      if (data == null) {
        Logger.warn('APIVerve: no data field', tag: 'Horoscope');
        return null;
      }

      final text = data['horoscope'] as String?;
      Logger.log(
        'APIVerve horoscope length: ${text?.length}',
        tag: 'Horoscope',
      );

      if (text == null || text.isEmpty) {
        Logger.warn('APIVerve: empty horoscope', tag: 'Horoscope');
        return null;
      }

      Logger.log(
        '✓ APIVerve: horoscope received (${text.length} chars)',
        tag: 'Horoscope',
      );
      return text;
    } catch (e) {
      Logger.error('APIVerve exception: $e', tag: 'Horoscope');
      return null;
    }
  }

  Future<String?> _fetchApiNinjas(String zodiacId) async {
    try {
      final key = AppConfig.apiNinjasKey.trim();
      if (key.isEmpty) {
        Logger.warn('No API key in AppConfig', tag: 'Horoscope');
        return null;
      }

      final uri = Uri.parse(
        'https://api.api-ninjas.com/v1/horoscope?zodiac=$zodiacId',
      );

      final res = await http
          .get(uri, headers: {'X-Api-Key': key, 'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) {
        Logger.warn(
          'API error ${res.statusCode}: ${res.body}',
          tag: 'Horoscope',
        );
        return null;
      }

      final json = jsonDecode(res.body) as Map<String, dynamic>;

      // Проверяем на ошибку API
      if (json.containsKey('error')) {
        Logger.warn('API error: ${json['error']}', tag: 'Horoscope');
        return null;
      }

      final text = json['horoscope'] as String?;
      if (text == null || text.isEmpty) {
        Logger.warn('Empty horoscope field', tag: 'Horoscope');
        return null;
      }

      Logger.log('English text received', tag: 'Horoscope');
      return text;
    } catch (e) {
      Logger.warn('API exception: $e', tag: 'Horoscope');
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
