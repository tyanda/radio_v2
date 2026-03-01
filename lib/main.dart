import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'core/config.dart';
import 'core/providers.dart';
import 'core/providers/dynamic_theme_provider.dart';
import 'core/utils/logger.dart';
import 'features/home/home_screen.dart';
import 'firebase_options.dart';
import 'widgets/splash_screen.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Загрузка конфигурации
  await AppConfig.initialize();

  // 1. Локализация
  try {
    await initializeDateFormatting('ru_RU');
  } catch (e) {
    Logger.error("Ошибка локализации: $e", tag: 'Main');
  }

  // 2. Firebase
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      Logger.log("Firebase initialized", tag: 'Main');
    } else {
      Logger.log("Firebase already initialized (skipped)", tag: 'Main');
    }
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      // Игнорируем ошибку дублирования - Firebase уже инициализирован
      Logger.log("Firebase duplicate-app (ignored)", tag: 'Main');
    } else {
      Logger.error("Firebase init error: $e", tag: 'Main');
      rethrow;
    }
  } catch (e) {
    Logger.error("Firebase unexpected error: $e", tag: 'Main');
    rethrow;
  }

  // Инициализация фонового воспроизведения
  await JustAudioBackground.init(
    androidNotificationChannelId: 'sakhalive_radio_channel',
    androidNotificationChannelName: 'SakhaLive Radio',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );

  // Настройка системной навигации (Edge-to-Edge) - ПОСЛЕ всех инициализаций
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Consumer(
        builder: (context, ref, child) {
          // Инициализируем менеджер динамической темы
          ref.watch(dynamicThemeManagerProvider);

          final themeNotifier = ref.read(themeProvider.notifier);
          final targetColor = ref.watch(dynamicColorProvider);

          return TweenAnimationBuilder<Color?>(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            tween: ColorTween(end: targetColor),
            builder: (context, color, child) {
              final animatedColor = color ?? targetColor;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final orientation = MediaQuery.of(context).orientation;
                  final isLandscape = orientation == Orientation.landscape;

                  return ShadTheme(
                    data: themeNotifier.getShadcnTheme(animatedColor),
                    child: MaterialApp(
                      title: 'Sakha Radio',
                      debugShowCheckedModeBanner: false,
                      theme: themeNotifier.getThemeData(animatedColor),
                      localizationsDelegates: const [
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                        AppLocalizations.delegate,
                      ],
                      supportedLocales: const [Locale('ru'), Locale('en')],
                      locale: const Locale('ru'),
                      home: kIsWeb
                          ? OrientationHandler(
                              isLandscape: isLandscape,
                              child: const AppInitializer(),
                            )
                          : const HomeScreen(),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// Обработчик ориентации для веб-версии
class OrientationHandler extends StatelessWidget {
  final bool isLandscape;
  final Widget child;

  const OrientationHandler({
    super.key,
    required this.isLandscape,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (isLandscape) {
      // В горизонтальной ориентации центрируем и ограничиваем ширину
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: child,
        ),
      );
    }
    // В вертикальной ориентации показываем как есть
    return child;
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
