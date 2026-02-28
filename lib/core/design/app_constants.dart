/// Константы дизайна приложения
library;

// import 'design.dart'; // не используется напрямую

/// Высота нижней панели с мини-плеером и навигацией
/// Вычисляется динамически на основе дизайн-токенов
double get kBottomBarTotalHeight {
  // MiniPlayer (64) + spacing (12) + bottom bar (56) + padding (8)
  return 140.0;
}

/// Максимальная ширина контента для responsive дизайна
const double kMaxContentWidth = 1200.0;

/// Стандартные breakpoint'ы для responsive
class Breakpoints {
  static const double mobile = 375.0;
  static const double tablet = 768.0;
  static const double desktop = 1024.0;
  static const double largeDesktop = 1440.0;
}

