// ═══════════════════════════════════════════════════════════════
// DEPRECATED: Этот файл устарел!
// ═══════════════════════════════════════════════════════════════
//
// Используйте новый файл: lib/core/design/design_tokens.dart
//
// Пример миграции:
//   БЫЛО: AppColors.accent
//   СТАЛО: AppColors.primary
//
//   БЫЛО: AppColors.background
//   СТАЛО: AppColors.background (совместимо)
//
//   БЫЛО: AppColors.cardBackground
//   СТАЛО: AppColors.cardBackground (совместимо)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

// Экспортируем новые дизайн-токены для обратной совместимости
export 'design_tokens.dart';

/// @deprecated Используйте [AppColors] из design_tokens.dart
class AppColors {
  @Deprecated('Используйте AppColors.primary из design_tokens.dart')
  static const Color accent = Color(0xFFF2C94C);

  @Deprecated('Используйте AppColors.primaryDark из design_tokens.dart')
  static const Color brand = Color(0xFFC9A53A);

  @Deprecated('Используйте AppColors.background из design_tokens.dart')
  static const Color background = Color(0xFF0F0F0F);

  @Deprecated('Используйте AppColors.cardBackground из design_tokens.dart')
  static const Color cardBackground = Color(0xFF1A1A1A);

  @Deprecated('Используйте AppColors.error из design_tokens.dart')
  static const Color error = Color(0xFFEF4444);

  @Deprecated('Используйте AppColors.textSecondary из design_tokens.dart')
  static const Color subText = Color(0xFFA3A3A3);

  @Deprecated('Используйте AppColors.textPrimary из design_tokens.dart')
  static const Color primaryText = Colors.white;

  @Deprecated('Используйте AppColors.textSecondary из design_tokens.dart')
  static const Color secondaryText = Color(0xFFA3A3A3);

  @Deprecated('Используйте AppColors.divider из design_tokens.dart')
  static const Color divider = Color(0xFF222222);

  @Deprecated('Используйте AppColors.textName из design_tokens.dart')
  static const Color textName = Color(0xFF2A2A2A);

  @Deprecated('Используйте AppColors.shadowYellow из design_tokens.dart')
  static const Color shadowYellow = Color(0xFFFFE9A7);

  @Deprecated('Используйте AppColors.iconGrey из design_tokens.dart')
  static const Color iconGrey = Color(0xFFA7B0B8);
}
