// lib/core/design/typography.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_tokens.dart';

/// Типография
///
/// Шрифтовая пара: **Inter** (заголовки + текст)
///
/// Альтернативные пары для разных настроений:
/// - **Elegant:** Cormorant Garamond / Montserrat
/// - **Modern:** Inter / Inter
/// - **Professional:** Roboto / Roboto
/// - **Creative:** Playfair Display / Lato
///
/// ## Использование
/// ```dart
/// // В теме
/// textTheme: AppTypography.textTheme,
///
/// // Отдельный стиль
/// style: AppTypography.h1,
/// ```
class AppTypography {
  const AppTypography._();

  // ═══════════════════════════════════════════════════════════════
  // TEXT THEME (для ThemeData)
  // ═══════════════════════════════════════════════════════════════

  /// Базовая текстовая тема на основе Google Fonts Inter
  static TextTheme get textTheme {
    return GoogleFonts.interTextTheme().apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );
  }

  /// Текстовая тема для тёмной темы
  static TextTheme get darkTextTheme {
    return GoogleFonts.interTextTheme().apply(
      bodyColor: AppColors.textPrimaryDark,
      displayColor: AppColors.textPrimaryDark,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ЗАГОЛОВКИ (Display & Headlines)
  // ═══════════════════════════════════════════════════════════════

  /// Display Large - Самый большой (главные заголовки)
  static const displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );

  /// Display Medium
  static const displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );

  /// Display Small
  static const displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );

  /// Headline Large (H1)
  static const h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );

  /// Headline Medium (H2)
  static const h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  /// Headline Small (H3)
  static const h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  // ═══════════════════════════════════════════════════════════════
  // ЗАГОЛОВКИ РАЗДЕЛОВ (Title)
  // ═══════════════════════════════════════════════════════════════

  /// Title Large (H4)
  static const titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );

  /// Title Medium (H5)
  static const titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
  );

  /// Title Small (H6)
  static const titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // ═══════════════════════════════════════════════════════════════
  // ТЕКСТ (Body)
  // ═══════════════════════════════════════════════════════════════

  /// Body Large - Основной текст (контент)
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  /// Body Medium - Стандартный текст (UI элементы)
  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  /// Body Small - Второстепенный текст (подписи)
  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // ═══════════════════════════════════════════════════════════════
  // КНОПКИ И LABELS
  // ═══════════════════════════════════════════════════════════════

  /// Label Large - Текст кнопок
  static const labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  /// Label Medium
  static const labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.33,
  );

  /// Label Small
  static const labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // ═══════════════════════════════════════════════════════════════
  // СПЕЦИАЛЬНЫЕ СТИЛИ
  // ═══════════════════════════════════════════════════════════════

  /// Button - Стиль для кнопок
  static const button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.43,
  );

  /// Caption - Подписи под элементами
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    color: AppColors.textSecondary,
  );

  /// Overline - Надзаголовки
  static const overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    height: 1.6,
  );
}
