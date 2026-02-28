// lib/core/design/effects.dart
import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Эффекты: Тени, скругления, анимации
/// 
/// Адаптация UI/UX Pro Max "Soft UI Evolution"
class AppEffects {
  const AppEffects._();

  // ═══════════════════════════════════════════════════════════════
  // ТЕНИ (Soft Shadows)
  // ═══════════════════════════════════════════════════════════════
  
  /// Маленькая тень (карточки, кнопки)
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  /// Средняя тень (карточки при наведении)
  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  /// Большая тень (модальные окна, dropdown)
  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  /// XL тень (floating элементы)
  static List<BoxShadow> get shadowXl => [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 40,
          offset: const Offset(0, 12),
        ),
      ];

  /// Цветная тень (для primary кнопок)
  static List<BoxShadow> get shadowPrimary => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  // ═══════════════════════════════════════════════════════════════
  // СКРУГЛЕНИЯ (Border Radius)
  // ═══════════════════════════════════════════════════════════════
  
  /// 4px - Минимальное (checkbox, small кнопки)
  static const radiusSm = 4.0;

  /// 8px - Стандартное (кнопки, инпуты)
  static const radiusMd = 8.0;

  /// 12px - Большое (карточки)
  static const radiusLg = 12.0;

  /// 16px - Очень большое (модальные окна)
  static const radiusXl = 16.0;

  /// 9999px - Полное (pill buttons, аватарки)
  static const radiusFull = 9999.0;

  // ═══════════════════════════════════════════════════════════════
  // АНИМАЦИИ (Durations & Curves)
  // ═══════════════════════════════════════════════════════════════
  
  /// 150ms - Быстрая (hover states, иконки)
  static const durationFast = Duration(milliseconds: 150);

  /// 200ms - Стандартная (кнопки, transitions)
  static const durationNormal = Duration(milliseconds: 200);

  /// 300ms - Медленная (модальные окна, сложные анимации)
  static const durationSlow = Duration(milliseconds: 300);

  /// Стандартная кривая анимации
  static const curve = Curves.easeInOut;
  
  /// Кривая для emphasis (быстрое начало, медленный конец)
  static const curveEmphasis = Curves.easeOutCubic;
  
  /// Кривая для fade анимаций
  static const curveFade = Curves.easeIn;

  // ═══════════════════════════════════════════════════════════════
  // ГРАДИЕНТЫ
  // ═══════════════════════════════════════════════════════════════
  
  /// Градиент для primary кнопок
  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary,
      AppColors.primaryDark,
    ],
  );

  /// Градиент для secondary кнопок
  static const LinearGradient gradientSecondary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.secondary,
      AppColors.secondaryDark,
    ],
  );

  /// Градиент для фона (Aurora UI)
  static LinearGradient gradientAurora({
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [
        AppColors.primaryFaint,
        AppColors.secondaryFaint,
      ],
    );
  }
}
