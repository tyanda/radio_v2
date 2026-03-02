import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ru'),
    Locale('en'),
  ];

  /// Название приложения
  ///
  /// In ru, this message translates to:
  /// **'SakhaLive'**
  String get app_title;

  /// Статус прямого эфира в плеере
  ///
  /// In ru, this message translates to:
  /// **'ПРЯМОЙ ЭФИР'**
  String get live_broadcast;

  /// Статус паузы в плеере
  ///
  /// In ru, this message translates to:
  /// **'ПАУЗА'**
  String get pause_status;

  /// Приветствие утром
  ///
  /// In ru, this message translates to:
  /// **'ДОБРОЕ УТРО'**
  String get good_morning;

  /// Приветствие днём
  ///
  /// In ru, this message translates to:
  /// **'ДОБРЫЙ ДЕНЬ'**
  String get good_afternoon;

  /// Приветствие вечером
  ///
  /// In ru, this message translates to:
  /// **'ДОБРЫЙ ВЕЧЕР'**
  String get good_evening;

  /// Приветствие ночью
  ///
  /// In ru, this message translates to:
  /// **'ДОБРОЙ НОЧИ'**
  String get good_night;

  /// Статус 'в эфире'
  ///
  /// In ru, this message translates to:
  /// **'В ЭФИРЕ'**
  String get on_air;

  /// Заголовок выбора знака зодиака
  ///
  /// In ru, this message translates to:
  /// **'ВЫБЕРИТЕ ЗНАК'**
  String get select_zodiac_sign;

  /// Текст загрузки гороскопа
  ///
  /// In ru, this message translates to:
  /// **'Загрузка гороскопа...'**
  String get loading_horoscope;

  /// Ошибка загрузки гороскопа
  ///
  /// In ru, this message translates to:
  /// **'Ошибка загрузки гороскопа: {error}'**
  String error_loading_horoscope(String error);

  /// Гороскоп не найден
  ///
  /// In ru, this message translates to:
  /// **'Гороскоп не найден. Попробуйте другой знак.'**
  String get horoscope_not_found;

  /// Гороскоп недоступен
  ///
  /// In ru, this message translates to:
  /// **'Гороскоп временно недоступен'**
  String get horoscope_unavailable;

  /// Метка прогноза на сегодня
  ///
  /// In ru, this message translates to:
  /// **'Прогноз на сегодня'**
  String get forecast_for_today;

  /// Ошибка сети
  ///
  /// In ru, this message translates to:
  /// **'ОШИБКА СЕТИ'**
  String get error_network;

  /// Кнопка повтора
  ///
  /// In ru, this message translates to:
  /// **'ПОВТОРИТЬ'**
  String get retry;

  /// Ошибка загрузки погоды
  ///
  /// In ru, this message translates to:
  /// **'Ошибка загрузки погоды: {error}'**
  String error_loading_weather(String error);

  /// Ошибка воспроизведения
  ///
  /// In ru, this message translates to:
  /// **'Ошибка воспроизведения: {error}'**
  String error_playback(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
