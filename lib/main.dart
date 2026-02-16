import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'home_screen.dart';
import 'core/config.dart';
import 'core/providers.dart';
import 'widgets/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Загрузка конфигурации
  await AppConfig.initialize();

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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Consumer(
        builder: (context, ref, child) {
          ref.watch(themeProvider); // Watch for rebuilds when theme changes
          final themeNotifier = ref.read(themeProvider.notifier);
          
          return MaterialApp(
            title: 'Sakha Radio',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('ru', 'RU'), Locale('en', 'US')],
            theme: themeNotifier.themeData,
            home: const AppInitializer(), // Используем виджет для инициализации приложения
          );
        },
      ),
    );
  }
}

// Виджет для инициализации приложения и перехода к главному экрану
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    // Запускаем инициализацию и переход к главному экрану
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Небольшая задержка для отображения сплеш-экрана (не более 2 секунд)
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Переход к главному экрану
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen(); // Показываем сплеш-экран до перехода
  }
}
