import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_handler.dart';
import '../core/theme_provider.dart';

// Провайдер для AudioHandler (инициализируется в main)
// На вебе возвращаем null, так как AudioService не поддерживается
final audioHandlerProvider = Provider<RadioAudioHandler?>((ref) {
  if (kIsWeb) return null;
  throw UnimplementedError(
    'audioHandlerProvider должен быть переопределён в main.dart при инициализации',
  );
});

// Провайдер для ThemeProvider
final themeProvider = AsyncNotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);
