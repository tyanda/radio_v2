import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_handler.dart';

// Экспортируем theme_provider для доступа к themeProvider
export 'theme_provider.dart';
export 'providers/horoscope_provider.dart';
export 'providers/radio_providers.dart';
export 'providers/weather_provider.dart';
export 'providers/settings_provider.dart';
export 'providers/view_mode_provider.dart';
export 'providers/dynamic_theme_provider.dart';

// Провайдер для AudioHandler (инициализируется в main)
// На вебе и при сбое инициализации возвращаем null
final audioHandlerProvider = Provider<RadioAudioHandler?>((ref) => null);

// Провайдер для ThemeProvider экспортируется из core/theme_provider.dart
