import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme_provider.dart';

export 'providers/providers.dart';

// Провайдер для ThemeProvider
final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);
