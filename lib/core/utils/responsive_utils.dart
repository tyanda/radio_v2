import 'package:flutter/material.dart';

/// Утилиты для адаптивных отступов
///
/// Базовая ширина для расчётов: 393px (iPhone 14 Pro)
/// Коэффициенты подобраны для сохранения визуального баланса
class ResponsivePadding {
  /// Базовая ширина дизайна
  static const double baseWidth = 393.0;

  /// Получить ширину экрана
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Рассчитать адаптивный отступ
  /// [px] - фиксированный отступ в пикселях на базовой ширине
  static double padding(BuildContext context, double px) {
    return screenWidth(context) * (px / baseWidth);
  }

  /// Малый отступ (~8px на базовой ширине)
  static double small(BuildContext context) {
    return screenWidth(context) * 0.02; // 8px на 393px
  }

  /// Средний отступ (~16px на базовой ширине)
  static double medium(BuildContext context) {
    return screenWidth(context) * 0.04; // 16px на 393px
  }

  /// Большой отступ (~24px на базовой ширине)
  static double large(BuildContext context) {
    return screenWidth(context) * 0.06; // 24px на 393px
  }

  /// Очень большой отступ (~32px на базовой ширине)
  static double xlarge(BuildContext context) {
    return screenWidth(context) * 0.08; // 32px на 393px
  }

  /// Адаптивный EdgeInsets.all
  static EdgeInsets all(BuildContext context, double px) {
    return EdgeInsets.all(padding(context, px));
  }

  /// Адаптивный EdgeInsets.symmetric
  static EdgeInsets symmetric({
    BuildContext? context,
    double horizontal = 0,
    double vertical = 0,
  }) {
    if (context != null) {
      return EdgeInsets.symmetric(
        horizontal: padding(context, horizontal),
        vertical: padding(context, vertical),
      );
    }
    // Если контекст не передан, используем фиксированные значения
    return EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: vertical,
    );
  }
}
