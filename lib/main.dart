import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация локализации для форматирования дат
  try {
    await initializeDateFormatting('ru_RU');
    debugPrint("Локализация дат успешно инициализирована");
  } catch (e) {
    debugPrint("Ошибка инициализации локализации дат: $e");
  }

  // Инициализация Firebase с обработкой ошибок и таймаутом
  debugPrint("Инициализация Firebase");
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 15));
    debugPrint("Firebase успешно инициализирована");
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
    debugPrint("Error details: ${e.runtimeType}");
    // Продолжаем работу приложения даже при ошибке Firebase
  }

  // Инициализация фона и уведомлений с таймаутом
  debugPrint("Инициализация JustAudioBackground");
  try {
    // Проверяем, является ли текущая платформа web
    if (!kIsWeb) {
      await JustAudioBackground.init(
        androidNotificationChannelId: 'com.sakha.radio.channel',
        androidNotificationChannelName: 'Sakha Radio Playback',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ).timeout(const Duration(seconds: 10));
      debugPrint("JustAudioBackground успешно инициализирован");
    } else {
      debugPrint("Пропускаем инициализацию JustAudioBackground для web");
    }
  } catch (e) {
    debugPrint("JustAudioBackground initialization failed: $e");
    debugPrint("Error details: ${e.runtimeType}");
    // Продолжаем работу приложения даже при ошибке инициализации аудио
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sakha Radio',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru', 'RU'),
        Locale('en', 'US'),
      ],
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFFFFD700),
        scaffoldBackgroundColor: const Color(0xFF000000),
      ),
      home: const HomeScreen(),
    );
  }
}