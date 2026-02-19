import 'package:flutter/material.dart';
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
  @override
  ThemeState build() {
    _loadThemePreference();
    return ThemeState(isDarkTheme: true);
  }

  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDark = prefs.getBool('is_dark_theme') ?? true;
    state = state.copyWith(isDarkTheme: isDark);
  }

  Future<void> toggleTheme() async {
    state = state.copyWith(isDarkTheme: !state.isDarkTheme);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_theme', state.isDarkTheme);
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
        primaryColor: const Color(0xFFFFD700),
        scaffoldBackgroundColor: const Color(0xFF000000),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD700),
          secondary: Color(0xFFFFD700),
        ),
      );
    } else {
      return ThemeData.light().copyWith(
        primaryColor: const Color(0xFF0066CC),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0066CC),
          secondary: Color(0xFF0066CC),
          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF000000),
        ),
      );
    }
  }
}
