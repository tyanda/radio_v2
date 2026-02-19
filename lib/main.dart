import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'firebase_options.dart';
import 'package:radio_v2/features/home/home_screen.dart';
import 'core/config.dart';
import 'core/providers.dart';
import 'widgets/splash_screen.dart';
import 'core/utils/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Загрузка конфигурации
  await AppConfig.initialize();

  // 1. Локализация
  try {
    await initializeDateFormatting('ru_RU');
  } catch (e) {
    Logger.error("Ошибка локализации: $e");
  }

  // 2. Firebase
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      Logger.log("Firebase initialized");
    } else {
      Logger.log("Firebase already initialized (skipped)");
    }
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      // Игнорируем ошибку дублирования - Firebase уже инициализирован
      Logger.log("Firebase duplicate-app (ignored)");
    } else {
      Logger.error("Firebase init error: $e");
      rethrow;
    }
  } catch (e) {
    Logger.error("Firebase unexpected error: $e");
    rethrow;
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
      Logger.error("AudioBackground init error: $e");
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
          ref.watch(themeProvider);
          final themeNotifier = ref.read(themeProvider.notifier);

          return ShadApp(
            title: 'Sakha Radio',
            debugShowCheckedModeBanner: false,
            theme: themeNotifier.shadcnTheme,
            darkTheme: ShadThemeData(
              brightness: Brightness.dark,
              colorScheme: const ShadZincColorScheme.dark(),
            ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('ru', 'RU'), Locale('en', 'US')],
            home: kIsWeb ? const AppInitializer() : const HomeScreen(),
          );
        },
      ),
    );
  }
}

// Виджет для инициализации и перехода к главному экрану (только для Web)
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Задержка для загрузки веб-версии (2 секунды)
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
