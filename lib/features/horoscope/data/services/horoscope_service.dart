import '../models/horoscope_data.dart';

class HoroscopeService {
  Future<HoroscopeData> getHoroscope(String sign, String period) async {
    try {
      // Возвращаем заглушечные данные для гороскопа
      final horoscopeText = _generateSampleHoroscope(sign, period);
      final title = '${_getSignName(sign)} - Гороскоп на сегодня';
      
      return HoroscopeData(
        sign: sign,
        title: title,
        text: horoscopeText,
        period: period,
      );
    } catch (e) {
      throw Exception('Ошибка при генерации гороскопа: $e');
    }
  }

  String _generateSampleHoroscope(String sign, String period) {
    // Создаем образцы текстов гороскопа для разных знаков зодиака
    Map<String, String> sampleHoroscopes = {
      'aries': 'Сегодня Овнам стоит проявить инициативу. Возможны успехи в профессиональной сфере. Не бойтесь новых начинаний.',
      'taurus': 'Благоприятный день для решения финансовых вопросов. Избегайте конфликтов, сохраняйте спокойствие.',
      'gemini': 'Коммуникации будут на высоте. Отличное время для встреч и общения. Возможны интересные знакомства.',
      'cancer': 'Эмоциональный день. Обратите внимание на семью и домашний уют. Интуиция особенно сильна.',
      'leo': 'День приносит возможности для самореализации. Ваша харизма будет особенно заметна. Уверенно двигайтесь к цели.',
      'virgo': 'Внимательность к деталям принесет пользу. Рационализируйте свои планы и подходы к работе.',
      'libra': 'Баланс важен во всем. Сегодня отличный день для заключения соглашений и установления контактов.',
      'scorpio': 'Интенсивный день. Глубокие эмоции и интуитивные прозрения помогут принять важные решения.',
      'sagittarius': 'Приключения и путешествия в центре внимания. Отличное время для расширения кругозора.',
      'capricorn': 'Практический подход к делам будет вознагражден. Сосредоточьтесь на долгосрочных целях.',
      'aquarius': 'Необычные идеи и нестандартные решения принесут успех. Социальные связи окажутся полезными.',
      'pisces': 'Творческие порывы и духовное развитие на первом плане. Интуиция особенно сильна сегодня.',
    };

    // Если для данного знака нет специфического гороскопа, возвращаем общий
    return sampleHoroscopes[sign] ?? 'Сегодня благоприятный день для саморазвития и новых начинаний. Следуйте своим инстинктам.';
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
}
