// ═══════════════════════════════════════════════════════════════
// DEPRECATED: Этот файл устарел!
// ═══════════════════════════════════════════════════════════════
// 
// Используйте новый файл: lib/core/design/spacing.dart
// 
// Пример миграции:
//   БЫЛО: AppPadding.horizontal (16.0)
//   СТАЛО: AppSpacing.lg (16.0)
//
//   БЫЛО: AppPadding.small (8.0)
//   СТАЛО: AppSpacing.sm (8.0)
//
//   БЫЛО: AppPadding.large (24.0)
//   СТАЛО: AppSpacing.xxl (24.0)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

// Экспортируем новые дизайн-токены для обратной совместимости
export 'spacing.dart';

/// @deprecated Используйте [AppSpacing] из spacing.dart
class AppPadding {
  @Deprecated('Используйте AppSpacing.lg')
  static const double horizontal = 16.0;

  @Deprecated('Используйте AppSpacing.lg')
  static const double vertical = 16.0;

  @Deprecated('Используйте AppSpacing.sm')
  static const double small = 8.0;

  @Deprecated('Используйте AppSpacing.xxl')
  static const double large = 24.0;

  @Deprecated('Используйте EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg)')
  static const EdgeInsets symmetric = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 16.0,
  );

  @Deprecated('Используйте EdgeInsets.symmetric(horizontal: AppSpacing.lg)')
  static const EdgeInsets horizontalSymmetric = EdgeInsets.symmetric(
    horizontal: 16.0,
  );

  @Deprecated('Используйте EdgeInsets.symmetric(vertical: AppSpacing.lg)')
  static const EdgeInsets verticalSymmetric = EdgeInsets.symmetric(
    vertical: 16.0,
  );

  @Deprecated('Используйте EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm)')
  static const EdgeInsets screenPadding = EdgeInsets.fromLTRB(
    16.0,
    16.0,
    16.0,
    8.0,
  );
}
