import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'design/design_tokens.dart';

/// Состояние темы приложения
class ThemeState {
  final bool isDarkTheme;
  final bool isLoaded;

  const ThemeState({required this.isDarkTheme, this.isLoaded = false});

  ThemeState copyWith({bool? isDarkTheme, bool? isLoaded}) {
    return ThemeState(
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

/// Провайдер темы
final themeProvider = AsyncNotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);

/// Менеджер темы приложения
///
/// Фиксированные брендовые цвета:
/// - Primary: #F2C94C (жёлтый SakhaLive)
/// - Primary Dark: #C9A53A (золотой бренд)
/// - Background Dark: #0F0F0F
/// - Background Light: #F5F5F7
/// - Card Dark: #1A1A1A
/// - Card Light: #FFFFFF
class ThemeNotifier extends AsyncNotifier<ThemeState> {
  static const String _themeKey = 'is_dark_theme';

  /// Фиксированный брендовый цвет (жёлтый SakhaLive)
  static const Color brandPrimary = AppColors.primary;

  /// Фиксированный тёмный вариант бренда (золотой)
  static const Color brandPrimaryDark = AppColors.primaryDark;

  @override
  Future<ThemeState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? true;
    _updateSystemUI(isDark);
    return ThemeState(isDarkTheme: isDark, isLoaded: true);
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

  /// Переключить тему (светлая/тёмная)
  Future<void> toggleTheme() async {
    final currentState = await future;
    final newState = !currentState.isDarkTheme;
    state = const AsyncValue.loading();
    _updateSystemUI(newState);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, newState);

    state = AsyncValue.data(ThemeState(isDarkTheme: newState, isLoaded: true));
  }

  /// Проверить, тёмная ли тема активна
  bool get isDarkTheme {
    final currentState = state.value;
    return currentState?.isDarkTheme ?? true;
  }

  /// Получить тему данных для shadcn_ui
  /// Использует фиксированные брендовые цвета
  ShadThemeData getShadcnTheme() {
    return isDarkTheme ? _getDarkShadTheme() : _getLightShadTheme();
  }

  /// Тёмная тема shadcn_ui
  ShadThemeData _getDarkShadTheme() {
    return ShadThemeData(
      brightness: Brightness.dark,
      colorScheme: ShadColorScheme(
        primary: brandPrimary,
        primaryForeground: Colors.black,
        background: AppColors.background,
        foreground: Colors.white,
        card: AppColors.cardBackground,
        cardForeground: Colors.white,
        border: AppColors.divider,
        muted: AppColors.surfaceVariant,
        mutedForeground: AppColors.textSecondary,
        accent: brandPrimary.withValues(alpha: 0.15),
        accentForeground: Colors.white,
        destructive: AppColors.error,
        destructiveForeground: Colors.white,
        input: AppColors.cardBackground,
        popover: AppColors.cardBackground,
        popoverForeground: Colors.white,
        ring: brandPrimary,
        secondary: brandPrimary.withValues(alpha: 0.3),
        secondaryForeground: Colors.white,
        selection: brandPrimary.withValues(alpha: 0.3),
      ),
    );
  }

  /// Светлая тема shadcn_ui
  ShadThemeData _getLightShadTheme() {
    return ShadThemeData(
      brightness: Brightness.light,
      colorScheme: ShadColorScheme(
        primary: brandPrimary,
        primaryForeground: Colors.black,
        background: AppColors.backgroundLight,
        foreground: AppColors.textPrimaryLight,
        card: Colors.white,
        cardForeground: AppColors.textPrimaryLight,
        border: AppColors.dividerLight,
        muted: AppColors.surfaceVariantLight,
        mutedForeground: AppColors.textSecondaryLight,
        accent: brandPrimary.withValues(alpha: 0.1),
        accentForeground: Colors.black,
        destructive: AppColors.error,
        destructiveForeground: Colors.white,
        input: AppColors.surfaceVariantLight,
        popover: Colors.white,
        popoverForeground: AppColors.textPrimaryLight,
        ring: brandPrimary,
        secondary: brandPrimary.withValues(alpha: 0.2),
        secondaryForeground: Colors.black,
        selection: brandPrimary.withValues(alpha: 0.3),
      ),
    );
  }

  /// Получить ThemeData для Material виджетов
  /// Использует фиксированные брендовые цвета
  ThemeBundle getThemeData() {
    return ThemeBundle(
      darkTheme: _getDarkTheme(),
      lightTheme: _getLightTheme(),
    );
  }

  /// Тёмная тема Material
  ThemeData _getDarkTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: brandPrimary,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.cardBackground,
      dividerColor: AppColors.divider,
      textTheme: const TextTheme().apply(fontFamily: 'Inter'),
      colorScheme: ColorScheme.dark(
        primary: brandPrimary,
        secondary: brandPrimaryDark,
        surface: AppColors.background,
        onPrimary: Colors.black,
        onSurface: Colors.white,
        onSurfaceVariant: AppColors.textSecondary,
      ),
    );
  }

  /// Светлая тема Material
  ThemeData _getLightTheme() {
    return ThemeData.light().copyWith(
      primaryColor: brandPrimary,
      canvasColor: brandPrimaryDark,
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
        primary: brandPrimary,
        secondary: brandPrimaryDark,
        surface: Colors.white,
        error: AppColors.error,
        onPrimary: Colors.black,
        onSurface: AppColors.textPrimaryLight,
        onSurfaceVariant: AppColors.textSecondaryLight,
      ),
    );
  }
}

///Bundle тем для светлой и тёмной версии
class ThemeBundle {
  final ThemeData darkTheme;
  final ThemeData lightTheme;

  const ThemeBundle({required this.darkTheme, required this.lightTheme});
}
