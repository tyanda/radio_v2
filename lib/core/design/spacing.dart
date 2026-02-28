// lib/core/design/spacing.dart

/// Отступы (Spacing Scale)
/// 
/// Основано на 4px базовой сетке
/// 
/// ## Использование
/// ```dart
/// padding: EdgeInsets.all(AppSpacing.lg),
/// SizedBox(height: AppSpacing.md),
/// ```
class AppSpacing {
  const AppSpacing._();

  /// 4px - Минимальный (иконки, плотная компоновка)
  static const xs = 4.0;

  /// 8px - Малый (между связанными элементами)
  static const sm = 8.0;

  /// 12px - Средний малый
  static const md = 12.0;

  /// 16px - Средний (стандартный отступ)
  static const lg = 16.0;

  /// 20px - Большой
  static const xl = 20.0;

  /// 24px - Очень большой
  static const xxl = 24.0;

  /// 32px - Максимальный (секции)
  static const xxxl = 32.0;

  /// 48px - Экстра большой (между секциями)
  static const huge = 48.0;
}
