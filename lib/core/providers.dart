import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme_provider.dart';

// Провайдер для ThemeProvider
final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);
