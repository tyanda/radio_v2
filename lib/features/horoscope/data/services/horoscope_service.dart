import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import '../../../../core/utils/logger.dart';
import '../models/horoscope_data.dart';

class HoroscopeService {
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

  Future<String> fetchHoroscope(String zodiacId) async {
    Logger.log("Fetching horoscope for zodiac sign: $zodiacId");
    try {
      final url = Uri.parse('https://horo.mail.ru/prediction/$zodiacId/today/');
      Logger.log("Horoscope URL: $url");

      final response = await http
          .get(
            url,
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
              'Accept':
                  'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
              'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
            },
          )
          .timeout(const Duration(seconds: 10));

      Logger.log("Horoscope response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        Logger.log("Horoscope response body length: ${response.body.length}");
        var document = parser.parse(response.body);
        var mainElement = document.querySelector(
          'main[data-qa="ArticleLayout"]',
        );
        if (mainElement != null) {
          mainElement
              .querySelectorAll('a')
              .forEach((element) => element.remove());
          String cleanText = mainElement.text.trim();
          Logger.log("Horoscope text length: ${cleanText.length}");
          if (cleanText.isNotEmpty) {
            return cleanText;
          }
        } else {
          Logger.warn(
            "Horoscope: Could not find main element with selector 'main[data-qa=\"ArticleLayout\"]'",
          );
        }
      } else {
        Logger.warn("Horoscope response status: ${response.statusCode}");
      }
    } catch (e) {
      Logger.warn("Ошибка загрузки гороскопа с сайта: $e");
    }

    // Если не удалось получить данные с сайта, возвращаем сгенерированный гороскоп
    return _generateSampleHoroscope(zodiacId);
  }

  String _generateSampleHoroscope(String sign) {
    // Создаем образцы текстов гороскопа для разных знаков зодиака
    Map<String, String> sampleHoroscopes = {
      'aries':
          'Сегодня Овнам стоит проявить инициативу. Возможны успехи в профессиональной сфере. Не бойтесь новых начинаний. Энергия на вашей стороне, используйте её с умом.',
      'taurus':
          'Благоприятный день для решения финансовых вопросов. Избегайте конфликтов, сохраняйте спокойствие. Вечером возможна приятная встреча с друзьями.',
      'gemini':
          'Коммуникации будут на высоте. Отличное время для встреч и общения. Возможны интересные знакомства, которые повлияют на ваше будущее.',
      'cancer':
          'Эмоциональный день. Обратите внимание на семью и домашний уют. Интуиция особенно сильна, доверьтесь своим чувствам при принятии решений.',
      'leo':
          'День приносит возможности для самореализации. Ваша харизма будет особенно заметна. Уверенно двигайтесь к цели, успех на вашей стороне.',
      'virgo':
          'Внимательность к деталям принесет пользу. Рационализируйте свои планы и подходы к работе. Важно не упустить мелочи в важных делах.',
      'libra':
          'Баланс важен во всем. Сегодня отличный день для заключения соглашений и установления контактов. Избегайте чрезмерной суеты.',
      'scorpio':
          'Интенсивный день. Глубокие эмоции и интуитивные прозрения помогут принять важные решения. Не бойтесь идти до конца.',
      'sagittarius':
          'Приключения и путешествия в центре внимания. Отличное время для расширения кругозора. Возможны неожиданные повороты судьбы.',
      'capricorn':
          'Практический подход к делам будет вознагражден. Сосредоточьтесь на долгосрочных целях. Карьерный рост в пределах возможностей.',
      'aquarius':
          'Необычные идеи и нестандартные решения принесут успех. Социальные связи окажутся полезными. Будьте открыты новому.',
      'pisces':
          'Творческие порывы и духовное развитие на первом плане. Интуиция особенно сильна сегодня. Следуйте своим инстинктам и чувствам.',
    };

    // Если для данного знака нет специфического гороскопа, возвращаем общий
    return sampleHoroscopes[sign] ??
        'Сегодня благоприятный день для саморазвития и новых начинаний. Следуйте своим инстинктам и не бойтесь перемен.';
  }

  Future<HoroscopeData> getHoroscope(String sign, String period) async {
    Logger.log("Getting horoscope for sign: $sign, period: $period");
    final horoscopeText = await fetchHoroscope(sign);
    final signName = _zodiacMap[sign] ?? sign;
    final title = "$signName - Гороскоп на сегодня";

    return HoroscopeData(
      sign: signName,
      title: title,
      text: horoscopeText,
      period: period,
    );
  }

  static Map<String, String> getZodiacSigns() {
    return _zodiacMap;
  }
}
