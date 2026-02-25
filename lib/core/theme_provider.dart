import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ThemeState {
  final bool isDarkTheme;

  ThemeState({required this.isDarkTheme});

  ThemeState copyWith({bool? isDarkTheme}) {
    return ThemeState(isDarkTheme: isDarkTheme ?? this.isDarkTheme);
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  static const String _themeKey = 'is_dark_theme';

  @override
  ThemeState build() {
    _loadThemePreference();
    return ThemeState(isDarkTheme: true);
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? true;
    state = state.copyWith(isDarkTheme: isDark);
    _updateSystemUI(isDark);
  }

  void _updateSystemUI(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFFFFFFF),
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  Future<void> toggleTheme() async {
    final newState = !state.isDarkTheme;
    state = state.copyWith(isDarkTheme: newState);
    _updateSystemUI(newState);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, newState);
  }

  ShadThemeData get shadcnTheme {
    return state.isDarkTheme
        ? ShadThemeData(
            brightness: Brightness.dark,
            colorScheme: const ShadZincColorScheme.dark(),
          )
        : ShadThemeData(
            brightness: Brightness.light,
            colorScheme: const ShadZincColorScheme.light(),
          );
  }

  ThemeData get themeData {
    if (state.isDarkTheme) {
      return ThemeData.dark().copyWith(
        primaryColor: const Color(0xFFF2C94C),
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        cardColor: const Color(0xFF1A1A1A),
        dividerColor: const Color(0xFF222222),
        textTheme: const TextTheme().apply(fontFamily: 'Inter'),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF2C94C),
          secondary: Color(0xFFF2C94C),
          surface: Color(0xFF1A1A1A),
          onPrimary: Colors.black,
        ),
      );
    } else {
      return ThemeData.light().copyWith(
        primaryColor: const Color(0xFFFFCC00), // accent: #FFCC00
        canvasColor: const Color(0xFFC9A53A), // brand: #C9A53A
        scaffoldBackgroundColor: const Color(0xFFF5F5F7), // background: #F5F5F7
        cardColor: const Color(0xFFFFFFFF), // cardBackground: СТРОГО БЕЛЫЙ #FFFFFF
        dividerColor: const Color(0xFFE5E5E7), // divider: #E5E5E7
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF1D1D1F)),
          bodyMedium: TextStyle(color: Color(0xFF1D1D1F)),
          titleLarge: TextStyle(color: Color(0xFF1D1D1F)),
        ).apply(
          fontFamily: 'Inter', 
          bodyColor: const Color(0xFF1D1D1F), // primaryText: #1D1D1F
          displayColor: const Color(0xFF1D1D1F),
        ),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFFCC00),
          secondary: Color(0xFFC9A53A), // brand
          surface: Color(0xFFFFFFFF),
          error: Color(0xFFEF4444), // error: #EF4444
          onPrimary: Color(0xFF000000), // Текст на желтом - СТРОГО ЧЕРНЫЙ
          onSurface: Color(0xFF1D1D1F), // primaryText
          onSurfaceVariant: Color(0xFF86868B), // secondaryText: #86868B
        ),
      );
    }
  }
}
