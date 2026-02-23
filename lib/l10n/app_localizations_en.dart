// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'Sakha Radio';

  @override
  String get live_broadcast => 'LIVE BROADCAST';

  @override
  String get pause_status => 'PAUSE';

  @override
  String get good_morning => 'GOOD MORNING';

  @override
  String get good_afternoon => 'GOOD AFTERNOON';

  @override
  String get good_evening => 'GOOD EVENING';

  @override
  String get good_night => 'GOOD NIGHT';

  @override
  String get on_air => 'ON AIR';

  @override
  String get select_zodiac_sign => 'SELECT SIGN';

  @override
  String get loading_horoscope => 'Loading horoscope...';

  @override
  String error_loading_horoscope(String error) {
    return 'Error loading horoscope: $error';
  }

  @override
  String get horoscope_not_found => 'Horoscope not found. Try another sign.';

  @override
  String get horoscope_unavailable => 'Horoscope is temporarily unavailable';

  @override
  String get forecast_for_today => 'Forecast for today';

  @override
  String get error_network => 'NETWORK ERROR';

  @override
  String get retry => 'RETRY';

  @override
  String error_loading_weather(String error) {
    return 'Error loading weather: $error';
  }

  @override
  String error_playback(String error) {
    return 'Playback error: $error';
  }
}
