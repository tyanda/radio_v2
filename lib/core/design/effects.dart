// lib/core/design/effects.dart
import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Эффекты: Тени, скругления, анимации
///
/// Адаптация UI/UX Pro Max "Soft UI Evolution" для Sakha Radio
///
/// ## Использование
/// ```dart
/// // Тени
/// boxShadow: AppEffects.shadowLg
///
/// // Скругления
/// borderRadius: BorderRadius.circular(AppEffects.radiusLg)
///
/// // Анимации
/// duration: AppEffects.durationSlow
/// curve: AppEffects.curveEmphasis
///
/// // Градиенты
/// decoration: BoxDecoration(gradient: AppEffects.gradientPrimary)
/// ```
class AppEffects {
  const AppEffects._();

  // ═══════════════════════════════════════════════════════════════
  // ТЕНИ (Soft Shadows) - для тёмной темы
  // ═══════════════════════════════════════════════════════════════

  /// Маленькая тень (карточки, кнопки)
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  /// Средняя тень (карточки при наведении)
  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// Большая тень (модальные окна, dropdown)
  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  /// XL тень (floating элементы)
  static List<BoxShadow> get shadowXl => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.5),
      blurRadius: 40,
      offset: const Offset(0, 12),
    ),
  ];

  /// Цветная тень (для primary кнопок - жёлтое свечение)
  static List<BoxShadow> get shadowPrimary => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// Glow эффект для активных элементов
  static List<BoxShadow> get glowPrimary => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.5),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

  /// Inner shadow эффект (вдавленные элементы)
  static List<BoxShadow> get shadowInner => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(2, 2),
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.1),
      blurRadius: 8,
      offset: const Offset(-2, -2),
    ),
  ];

  /// Мягкое свечение для фона
  static List<BoxShadow> get glowSoft => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.2),
      blurRadius: 30,
      spreadRadius: 5,
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

  /// 24px - Максимальное для карточек
  static const radius2xl = 24.0;

  /// 9999px - Полное (pill buttons, аватарки)
  static const radiusFull = 9999.0;

  // ═══════════════════════════════════════════════════════════════
  // АНИМАЦИИ (Durations & Curves)
  // ═══════════════════════════════════════════════════════════════

  /// 100ms - Мгновенная (micro-interactions)
  static const durationInstant = Duration(milliseconds: 100);

  /// 150ms - Быстрая (hover states, иконки)
  static const durationFast = Duration(milliseconds: 150);

  /// 200ms - Стандартная (кнопки, transitions)
  static const durationNormal = Duration(milliseconds: 200);

  /// 300ms - Медленная (модальные окна, сложные анимации)
  static const durationSlow = Duration(milliseconds: 300);

  /// 500ms - Очень медленная (parallax, background)
  static const durationVerySlow = Duration(milliseconds: 500);

  /// Стандартная кривая анимации
  static const curve = Curves.easeInOut;

  /// Кривая для emphasis (быстрое начало, медленный конец)
  static const curveEmphasis = Curves.easeOutCubic;

  /// Кривая для fade анимаций
  static const curveFade = Curves.easeIn;

  /// Пружинистая кривая (bounce effect)
  static const curveBounce = Curves.elasticOut;

  /// Плавная кривая для скролла
  static const curveScroll = Curves.easeOutCubic;

  // ═══════════════════════════════════════════════════════════════
  // ГРАДИЕНТЫ
  // ═══════════════════════════════════════════════════════════════

  /// Градиент для primary кнопок
  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryDark],
  );

  /// Градиент для secondary кнопок
  static const LinearGradient gradientSecondary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.secondary, AppColors.secondaryDark],
  );

  /// Градиент для фона (Aurora UI)
  static LinearGradient gradientAurora({
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [AppColors.primaryFaint, AppColors.secondaryFaint],
    );
  }

  /// Градиент для карточек (тёмная тема)
  static const LinearGradient gradientCardDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
  );

  /// Градиент для карточек (светлая тема)
  static const LinearGradient gradientCardLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Color(0xFFF8FAFC)],
  );

  /// Золотой градиент (премиум элементы)
  static const LinearGradient gradientGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFE9A7), Color(0xFFF2C94C), Color(0xFFC9A53A)],
  );

  /// Ночной градиент
  static const LinearGradient gradientNight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1A2E), Color(0xFF0F0F0F)],
  );

  // ═══════════════════════════════════════════════════════════════
  // БЛЮР ЭФФЕКТЫ
  // ═══════════════════════════════════════════════════════════════

  /// Легкий блюр (фоновые элементы)
  static const double blurSm = 4.0;

  /// Средний блюр (glassmorphism)
  static const double blurMd = 8.0;

  /// Сильный блюр (overlay)
  static const double blurLg = 16.0;

  /// Максимальный блюр
  static const double blurXl = 24.0;

  // ═══════════════════════════════════════════════════════════════
  // GLASSMORPHISM ЭФФЕКТЫ
  // ═══════════════════════════════════════════════════════════════

  /// Glassmorphism декорация для тёмной темы
  static BoxDecoration glassDark({double blur = blurMd, double opacity = 0.1}) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radiusXl),
      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: blur),
      ],
    );
  }

  /// Glassmorphism декорация для светлой темы
  static BoxDecoration glassLight({
    double blur = blurMd,
    double opacity = 0.7,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radiusXl),
      border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: blur),
      ],
    );
  }
}
