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

  ShadThemeData getShadcnTheme(Color primaryColor) {
    // Кастомная цветовая схема с динамическим акцентом
    return state.isDarkTheme
        ? ShadThemeData(
            brightness: Brightness.dark,
            colorScheme: ShadColorScheme(
              primary: primaryColor,
              primaryForeground: Colors.black,
              background: AppColors.background,
              foreground: AppColors.textPrimary,
              card: AppColors.cardBackground,
              cardForeground: AppColors.textPrimary,
              border: AppColors.divider,
              muted: AppColors.surfaceVariant,
              mutedForeground: AppColors.textSecondary,
              accent: primaryColor.withValues(alpha: 0.2),
              accentForeground: Colors.white,
              destructive: AppColors.error,
              destructiveForeground: Colors.white,
              input: AppColors.surfaceVariant,
              popover: AppColors.cardBackground,
              popoverForeground: AppColors.textPrimary,
              ring: primaryColor,
              secondary: AppColors.primaryDark,
              secondaryForeground: Colors.black,
              selection: primaryColor.withValues(alpha: 0.3),
            ),
          )
        : ShadThemeData(
            brightness: Brightness.light,
            colorScheme: ShadColorScheme(
              primary: primaryColor,
              primaryForeground: Colors.black,
              background: AppColors.backgroundLight,
              foreground: AppColors.textPrimaryLight,
              card: Colors.white,
              cardForeground: AppColors.textPrimaryLight,
              border: AppColors.dividerLight,
              muted: AppColors.surfaceVariantLight,
              mutedForeground: AppColors.textSecondaryLight,
              accent: primaryColor.withValues(alpha: 0.1),
              accentForeground: Colors.black,
              destructive: AppColors.error,
              destructiveForeground: Colors.white,
              input: AppColors.surfaceVariantLight,
              popover: Colors.white,
              popoverForeground: AppColors.textPrimaryLight,
              ring: primaryColor,
              secondary: AppColors.primaryDark,
              secondaryForeground: Colors.black,
              selection: primaryColor.withValues(alpha: 0.3),
            ),
          );
  }

  ThemeData getThemeData(Color primaryColor) {
    if (state.isDarkTheme) {
      return ThemeData.dark().copyWith(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.cardBackground,
        dividerColor: AppColors.divider,
        textTheme: const TextTheme().apply(fontFamily: 'Inter'),
        colorScheme: ColorScheme.dark(
          primary: primaryColor,
          secondary: AppColors.primaryDark,
          surface: AppColors.cardBackground,
          onPrimary: Colors.black,
          onSurface: AppColors.textPrimary,
        ),
      );
    } else {
      return ThemeData.light().copyWith(
        primaryColor: primaryColor,
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
        colorScheme: ColorScheme.light(
          primary: primaryColor,
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
