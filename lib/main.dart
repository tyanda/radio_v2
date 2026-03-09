import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:audio_service/audio_service.dart';
// Условный импорт для home_widget (не поддерживается на Web)
import 'package:sakha_live/services/home_widget_service.dart'
    if (dart.library.io) 'package:sakha_live/services/home_widget_service_stub.dart';

import 'package:sakha_live/core/config.dart';
import 'package:sakha_live/core/providers.dart';
import 'package:sakha_live/core/utils/logger.dart';
import 'package:sakha_live/features/home/home_screen.dart';
import 'package:sakha_live/firebase_options.dart';
import 'package:sakha_live/services/push_notification_service.dart';
import 'package:sakha_live/services/audio_handler.dart';
import 'package:sakha_live/widgets/splash_screen.dart';
import 'package:sakha_live/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Загрузка конфигурации (должна быть перед Firebase!)
  await AppConfig.initialize();

  // 2. Инициализация обработчика аудио (только для Android/iOS, не работает на Web)
  dynamic audioHandler;
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    audioHandler = await AudioService.init(
      builder: () => RadioAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.sakhalive.player',
        androidNotificationChannelName: 'SakhaLive Playback',
        androidStopForegroundOnPause: true,
        androidNotificationIcon: 'mipmap/ic_launcher',
        androidShowNotificationBadge: true,
      ),
    );
    Logger.log("AudioService initialized", tag: 'Main');
  } else {
    Logger.log("AudioService skipped for Web/Desktop", tag: 'Main');
  }

  // 3. Инициализация Firebase
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // На вебе инициализируем уведомления с осторожностью, так как это может блокировать поток
      if (kIsWeb) {
        // На вебе часто требуется VAPID ключ для FCM, поэтому инициализируем асинхронно без ожидания
        PushNotificationService.initialize().catchError((e) {
          Logger.error("Web Push init error: $e", tag: 'Main');
        });
      } else {
        await PushNotificationService.initialize();
      }

      Logger.log("Firebase initialized", tag: 'Main');
    }
  } catch (e) {
    Logger.error("Firebase init error: $e", tag: 'Main');
  }

  // 4. Инициализация Home Widget (не работает на Web)
  // Используем условный сервис вместо прямого импорта пакета
  try {
    await HomeWidgetService.setAppGroupId('group.com.sakhalive.shared');
    if (!kIsWeb) {
      Logger.log("HomeWidget initialized", tag: 'Main');
    }
  } catch (e) {
    Logger.error("HomeWidget init error: $e", tag: 'Main');
  }

  runApp(
    ProviderScope(
      overrides: [
        // Переопределяем audioHandlerProvider для всех платформ
        // На вебе будет null, на Android/iOS - реальный AudioHandler
        audioHandlerProvider.overrideWithValue(audioHandler),
      ],
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
    // Используем селектор для подписки только на isDarkTheme, чтобы избежать лишних пересборок
    final isDarkTheme = ref.watch(
      themeProvider.select((state) => state.value?.isDarkTheme ?? true),
    );

    final themeNotifier = ref.read(themeProvider.notifier);
    final themeData = themeNotifier.getThemeData();

    return ShadTheme(
      data: themeNotifier.getShadcnTheme(),
      child: MaterialApp(
        title: 'SakhaLive',
        debugShowCheckedModeBanner: false,
        theme: themeData.lightTheme,
        darkTheme: themeData.darkTheme,
        themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru'), Locale('en')],
        locale: const Locale('ru'),
        home: _isInitialized ? const HomeScreen() : const SplashScreen(),
      ),
    );
  }
}
