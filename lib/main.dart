import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Локализация
  try {
    await initializeDateFormatting('ru_RU');
  } catch (e) {
    debugPrint("Ошибка локализации: $e");
  }

  // 2. Firebase
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint("Firebase initialized");
    } else {
      debugPrint("Firebase already initialized");
    }
  } catch (e) {
    debugPrint("Firebase init error (ignored if already exists): $e");
  }

  // 3. Audio Background
  if (!kIsWeb) {
    try {
      await JustAudioBackground.init(
        androidNotificationChannelId: 'com.sakha.radio.channel',
        androidNotificationChannelName: 'Sakha Radio Playback',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      );
    } catch (e) {
      debugPrint("AudioBackground init error: $e");
    }
  }

  runApp(const ProviderScope(child: MyApp()));
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
      supportedLocales: const [Locale('ru', 'RU'), Locale('en', 'US')],
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFFFFD700),
        scaffoldBackgroundColor: const Color(0xFF000000),
      ),
      home: const HomeScreen(),
    );
  }
}
