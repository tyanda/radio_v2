// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get app_title => 'SakhaLive';

  @override
  String get live_broadcast => 'ПРЯМОЙ ЭФИР';

  @override
  String get pause_status => 'ПАУЗА';

  @override
  String get good_morning => 'ДОБРОЕ УТРО';

  @override
  String get good_afternoon => 'ДОБРЫЙ ДЕНЬ';

  @override
  String get good_evening => 'ДОБРЫЙ ВЕЧЕР';

  @override
  String get good_night => 'ДОБРОЙ НОЧИ';

  @override
  String get on_air => 'В ЭФИРЕ';

  @override
  String get select_zodiac_sign => 'ВЫБЕРИТЕ ЗНАК';

  @override
  String get loading_horoscope => 'Загрузка гороскопа...';

  @override
  String error_loading_horoscope(String error) {
    return 'Ошибка загрузки гороскопа: $error';
  }

  @override
  String get horoscope_not_found =>
      'Гороскоп не найден. Попробуйте другой знак.';

  @override
  String get horoscope_unavailable => 'Гороскоп временно недоступен';

  @override
  String get forecast_for_today => 'Прогноз на сегодня';

  @override
  String get error_network => 'ОШИБКА СЕТИ';

  @override
  String get retry => 'ПОВТОРИТЬ';

  @override
  String error_loading_weather(String error) {
    return 'Ошибка загрузки погоды: $error';
  }

  @override
  String error_playback(String error) {
    return 'Ошибка воспроизведения: $error';
  }
}
