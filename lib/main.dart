import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:audio_service/audio_service.dart';
import 'package:home_widget/home_widget.dart';

import 'package:sakha_live/core/config.dart';
import 'package:sakha_live/core/providers.dart';
import 'package:sakha_live/core/providers/dynamic_theme_provider.dart';
import 'package:sakha_live/core/utils/logger.dart';
import 'package:sakha_live/features/home/home_screen.dart';
import 'package:sakha_live/firebase_options.dart';
import 'package:sakha_live/services/push_notification_service.dart';
import 'package:sakha_live/services/audio_handler.dart';
import 'package:sakha_live/widgets/splash_screen.dart';
import 'package:sakha_live/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация обработчика аудио (один раз на весь цикл жизни приложения)
  final audioHandler = await AudioService.init(
    builder: () => RadioAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.sakhalive.player',
      androidNotificationChannelName: 'SakhaLive Playback',
      androidStopForegroundOnPause: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidShowNotificationBadge: true,
    ),
  );

  // Инициализация Firebase
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await PushNotificationService.initialize();
      Logger.log("Firebase initialized", tag: 'Main');
    }
  } catch (e) {
    Logger.error("Firebase init error: $e", tag: 'Main');
  }

  // Инициализация Home Widget (только для Android/iOS, не работает на Web)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    try {
      await HomeWidget.setAppGroupId('group.com.sakhalive.shared');
      Logger.log("HomeWidget initialized", tag: 'Main');
    } catch (e) {
      Logger.error("HomeWidget init error: $e", tag: 'Main');
    }
  }

  // Загрузка конфигурации
  await AppConfig.initialize();

  runApp(
    ProviderScope(
      overrides: [audioHandlerProvider.overrideWithValue(audioHandler)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Ждем 2 секунды для красоты сплэша (как в исходной логике)
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Инициализируем менеджер динамической темы (слушает плеер)
    ref.watch(dynamicThemeManagerProvider);

    // Подписываемся на изменения темы для пересборки ShadTheme/MaterialApp
    ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final targetColor = ref.watch(dynamicColorProvider);

    return TweenAnimationBuilder<Color?>(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      tween: ColorTween(end: targetColor),
      builder: (context, color, child) {
        final animatedColor = color ?? targetColor;

        return ShadTheme(
          data: themeNotifier.getShadcnTheme(animatedColor),
          child: MaterialApp(
            title: 'SakhaLive',
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
            // Ключевое изменение: показываем либо сплэш, либо главный экран без Navigator.push
            home: _isInitialized ? const HomeScreen() : const SplashScreen(),
          ),
        );
      },
    );
  }
}
