import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_handler.dart';
import '../core/theme_provider.dart';

// Провайдер для AudioHandler (инициализируется в main)
final audioHandlerProvider = Provider<RadioAudioHandler>((ref) {
  throw UnimplementedError();
});

// Провайдер для ThemeProvider
final themeProvider = AsyncNotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);
