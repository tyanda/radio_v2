// lib/core/design/design_tokens.dart
import 'package:flutter/material.dart';

/// Дизайн-токены для Radio V4
/// 
/// Адаптация UI/UX Pro Max для Flutter + shadcn_ui
/// 
/// ## Цветовая палитра
/// - Primary: Emerald (бренд, основные действия)
/// - Secondary: Indigo (вторичные элементы)
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
  // PRIMARY (Brand Colors) - Emerald
  // ═══════════════════════════════════════════════════════════════
  static const primary = Color(0xFF10B981);       // Emerald 500
  static const primaryDark = Color(0xFF059669);   // Emerald 600
  static const primaryLight = Color(0xFF34D399);  // Emerald 400
  static const primaryFaint = Color(0xFFD1FAE5);  // Emerald 100

  // ═══════════════════════════════════════════════════════════════
  // SECONDARY - Indigo
  // ═══════════════════════════════════════════════════════════════
  static const secondary = Color(0xFF6366F1);     // Indigo 500
  static const secondaryDark = Color(0xFF4F46E5); // Indigo 600
  static const secondaryLight = Color(0xFF818CF8);// Indigo 400
  static const secondaryFaint = Color(0xFFE0E7FF);// Indigo 100

  // ═══════════════════════════════════════════════════════════════
  // BACKGROUND & SURFACE
  // ═══════════════════════════════════════════════════════════════
  // Light mode
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF8FAFC);       // Slate 50
  static const surfaceVariant = Color(0xFFF1F5F9);// Slate 100
  
  // Dark mode
  static const backgroundDark = Color(0xFF0F172A);// Slate 900
  static const surfaceDark = Color(0xFF1E293B);   // Slate 800
  static const surfaceVariantDark = Color(0xFF334155);// Slate 700

  // ═══════════════════════════════════════════════════════════════
  // TEXT COLORS
  // ═══════════════════════════════════════════════════════════════
  // Light mode
  static const textPrimary = Color(0xFF1E293B);   // Slate 800
  static const textSecondary = Color(0xFF64748B); // Slate 500
  static const textTertiary = Color(0xFF94A3B8);  // Slate 400
  static const textLight = Color(0xFFFFFFFF);
  
  // Dark mode
  static const textPrimaryDark = Color(0xFFF8FAFC);
  static const textSecondaryDark = Color(0xFF94A3B8);
  static const textTertiaryDark = Color(0xFF64748B);

  // ═══════════════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ═══════════════════════════════════════════════════════════════
  static const success = Color(0xFF10B981);       // Emerald 500
  static const warning = Color(0xFFF59E0B);       // Amber 500
  static const error = Color(0xFFEF4444);         // Red 500
  static const info = Color(0xFF3B82F6);          // Blue 500

  // ═══════════════════════════════════════════════════════════════
  // BORDER & DIVIDER
  // ═══════════════════════════════════════════════════════════════
  static const border = Color(0xFFE2E8F0);        // Slate 200
  static const borderDark = Color(0xFF475569);    // Slate 600
  static const divider = Color(0xFFE2E8F0);
  static const dividerDark = Color(0xFF334155);

  // ═══════════════════════════════════════════════════════════════
  // RADIO STATION BRANDING (для примера)
  // ═══════════════════════════════════════════════════════════════
  static const europaPlus = Color(0xFF7C3AED);    // Violet
  static const superDisco = Color(0xFFEC4899);    // Pink
  static const retroFM = Color(0xFFEF4444);       // Red
}
