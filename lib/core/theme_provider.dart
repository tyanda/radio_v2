import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'design/design_tokens.dart';

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
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
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
    // Кастомная цветовая схема с жёлтым акцентом как на Android
    return state.isDarkTheme
        ? ShadThemeData(
            brightness: Brightness.dark,
            colorScheme: ShadColorScheme(
              primary: AppColors.primary,
              primaryForeground: Colors.black,
              background: AppColors.background,
              foreground: AppColors.textPrimary,
              card: AppColors.cardBackground,
              cardForeground: AppColors.textPrimary,
              border: AppColors.divider,
              muted: AppColors.surfaceVariant,
              mutedForeground: AppColors.textSecondary,
              accent: AppColors.primaryLight,
              accentForeground: Colors.black,
              destructive: AppColors.error,
              destructiveForeground: Colors.white,
              input: AppColors.surfaceVariant,
              popover: AppColors.cardBackground,
              popoverForeground: AppColors.textPrimary,
              ring: AppColors.primary,
              secondary: AppColors.primaryDark,
              secondaryForeground: Colors.black,
              selection: AppColors.primary.withValues(alpha: 0.3),
            ),
          )
        : ShadThemeData(
            brightness: Brightness.light,
            colorScheme: ShadColorScheme(
              primary: AppColors.primary,
              primaryForeground: Colors.black,
              background: AppColors.backgroundLight, // #F5F5F7
              foreground: AppColors.textPrimaryLight,
              card: Colors.white,
              cardForeground: AppColors.textPrimaryLight,
              border: AppColors.dividerLight,
              muted: AppColors.surfaceVariantLight,
              mutedForeground: AppColors.textSecondaryLight,
              accent: AppColors.primaryLight,
              accentForeground: Colors.black,
              destructive: AppColors.error,
              destructiveForeground: Colors.white,
              input: AppColors.surfaceVariantLight,
              popover: Colors.white,
              popoverForeground: AppColors.textPrimaryLight,
              ring: AppColors.primary,
              secondary: AppColors.primaryDark,
              secondaryForeground: Colors.black,
              selection: AppColors.primary.withValues(alpha: 0.3),
            ),
          );
  }

  ThemeData get themeData {
    if (state.isDarkTheme) {
      return ThemeData.dark().copyWith(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.cardBackground,
        dividerColor: AppColors.divider,
        textTheme: const TextTheme().apply(fontFamily: 'Inter'),
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.primaryDark,
          surface: AppColors.cardBackground,
          onPrimary: Colors.black,
          onSurface: AppColors.textPrimary,
        ),
      );
    } else {
      return ThemeData.light().copyWith(
        primaryColor: AppColors.primary,
        canvasColor: AppColors.primaryDark,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        cardColor: Colors.white,
        dividerColor: AppColors.dividerLight,
        textTheme:
            const TextTheme(
              bodyLarge: TextStyle(color: AppColors.textPrimaryLight),
              bodyMedium: TextStyle(color: AppColors.textPrimaryLight),
              titleLarge: TextStyle(color: AppColors.textPrimaryLight),
            ).apply(
              fontFamily: 'Inter',
              bodyColor: AppColors.textPrimaryLight,
              displayColor: AppColors.textPrimaryLight,
            ),
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.primaryDark,
          surface: Colors.white,
          error: AppColors.error,
          onPrimary: Colors.black,
          onSurface: AppColors.textPrimaryLight,
          onSurfaceVariant: AppColors.textSecondaryLight,
        ),
      );
    }
  }
}
