// lib/core/design/design_tokens.dart
import 'package:flutter/material.dart';

/// Дизайн-токены для Radio V4
/// 
/// Адаптация UI/UX Pro Max для Flutter + shadcn_ui
/// 
/// ## Цветовая палитра
/// - Primary: Yellow/Gold (бренд Sakha Radio)
/// - Secondary: Amber (акценты)
/// - Semantic: Success, Warning, Error, Info
/// 
/// ## Использование
/// ```dart
/// // В виджете
/// color: AppColors.primary
/// 
/// // В теме
/// primary: AppColors.primary,
/// ```
class AppColors {
  const AppColors._();

  // ═══════════════════════════════════════════════════════════════
  // PRIMARY (Brand Colors) - Yellow/Gold (Sakha Radio)
  // ═══════════════════════════════════════════════════════════════
  static const primary = Color(0xFFF2C94C);       // Yellow 500 (Accent из Figma)
  static const primaryDark = Color(0xFFC9A53A);   // Gold 600 (Brand из Figma)
  static const primaryLight = Color(0xFFFFE9A7);  // Yellow 300 (Shadow Yellow)
  static const primaryFaint = Color(0xFFFFF9DB);  // Yellow 50

  // ═══════════════════════════════════════════════════════════════
  // SECONDARY - Amber
  // ═══════════════════════════════════════════════════════════════
  static const secondary = Color(0xFFF59E0B);     // Amber 500
  static const secondaryDark = Color(0xFFD97706); // Amber 600
  static const secondaryLight = Color(0xFFFBBF24);// Amber 400
  static const secondaryFaint = Color(0xFFFFF7ED);// Amber 50

  // ═══════════════════════════════════════════════════════════════
  // BACKGROUND & SURFACE (Dark Theme First)
  // ═══════════════════════════════════════════════════════════════
  // Основной фон (из Figma)
  static const background = Color(0xFF0F0F0F);
  static const backgroundLight = Color(0xFFFFFFFF);
  
  // Фон карточек (из Figma)
  static const cardBackground = Color(0xFF1A1A1A);
  static const cardBackgroundLight = Color(0xFFF8FAFC);
  
  // Поверхности
  static const surface = Color(0xFF1A1A1A);
  static const surfaceLight = Color(0xFFF8FAFC);
  static const surfaceVariant = Color(0xFF2A2A2A);
  static const surfaceVariantLight = Color(0xFFF1F5F9);

  // ═══════════════════════════════════════════════════════════════
  // TEXT COLORS
  // ═══════════════════════════════════════════════════════════════
  // Основной текст (из Figma)
  static const textPrimary = Colors.white;
  static const textPrimaryLight = Color(0xFF1E293B);
  
  // Для совместимости
  @Deprecated('Используйте textPrimaryLight')
  static const textPrimaryDark = Color(0xFF1E293B);
  
  // Вторичный текст (из Figma)
  static const textSecondary = Color(0xFFA3A3A3);
  static const textSecondaryLight = Color(0xFF64748B);
  
  // Третичный текст
  static const textTertiary = Color(0xFF86868B);
  static const textTertiaryLight = Color(0xFF94A3B8);
  
  // Для тёмного текста на светлом фоне
  static const textName = Color(0xFF2A2A2A);
  static const textLight = Colors.white;

  // ═══════════════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ═══════════════════════════════════════════════════════════════
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);

  // ═══════════════════════════════════════════════════════════════
  // BORDER & DIVIDER
  // ═══════════════════════════════════════════════════════════════
  static const divider = Color(0xFF222222);
  static const dividerLight = Color(0xFFE2E8F0);
  static const border = Color(0xFF2A2A2A);
  static const borderLight = Color(0xFFE2E8F0);

  // ═══════════════════════════════════════════════════════════════
  // SPECIAL COLORS (из Figma)
  // ═══════════════════════════════════════════════════════════════
  static const shadowYellow = Color(0xFFFFE9A7);
  static const iconGrey = Color(0xFFA7B0B8);

  // ═══════════════════════════════════════════════════════════════
  // BACKWARD COMPATIBILITY (алиасы для старого кода)
  // ═══════════════════════════════════════════════════════════════
  @Deprecated('Используйте primary')
  static const accent = primary;
  
  @Deprecated('Используйте primaryDark')
  static const brand = primaryDark;
  
  @Deprecated('Используйте textSecondary')
  static const subText = textSecondary;
  
  @Deprecated('Используйте textPrimary')
  static const primaryText = textPrimary;
  
  @Deprecated('Используйте textSecondary')
  static const secondaryText = textSecondary;
}
