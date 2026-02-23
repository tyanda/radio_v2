import 'package:flutter/material.dart';

/// Глобальные константы отступов для всего приложения
class AppPadding {
  /// Стандартный горизонтальный отступ для всех экранов и виджетов
  static const double horizontal = 16.0;

  /// Стандартный вертикальный отступ
  static const double vertical = 16.0;

  /// Малый отступ (для компактных элементов)
  static const double small = 8.0;

  /// Большой отступ (для основных разделов)
  static const double large = 24.0;

  /// Стандартный симметричный padding
  static const EdgeInsets symmetric = EdgeInsets.symmetric(
    horizontal: horizontal,
    vertical: vertical,
  );

  /// Горизонтальный padding
  static const EdgeInsets horizontalSymmetric = EdgeInsets.symmetric(
    horizontal: horizontal,
  );

  /// Вертикальный padding
  static const EdgeInsets verticalSymmetric = EdgeInsets.symmetric(
    vertical: vertical,
  );

  /// Стандартный padding для экранов (SafeArea + контент)
  /// Используется внутри SafeArea для верхнего отступа 16px
  static const EdgeInsets screenPadding = EdgeInsets.fromLTRB(
    horizontal,
    horizontal,
    horizontal,
    small,
  );
}
