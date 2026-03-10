import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/design/design.dart';
import '../../../core/providers.dart';

/// QuickActionsBar — панель быстрых действий
///
/// Особенности:
/// - 4 основные кнопки (Избранное, Поиск, Темы, Настройки)
/// - Hover эффекты для desktop/web
/// - Haptic feedback при нажатии
/// - Анимированные иконки
class QuickActionsBar extends ConsumerStatefulWidget {
  final Function(String action)? onAction;

  const QuickActionsBar({super.key, this.onAction});

  @override
  ConsumerState<QuickActionsBar> createState() => _QuickActionsBarState();
}

class _QuickActionsBarState extends ConsumerState<QuickActionsBar> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(
      themeProvider.select((s) => s.value?.isDarkTheme ?? true),
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.star_rounded,
            label: 'Избранное',
            color: AppColors.primary,
            onTap: () => widget.onAction?.call('favorites'),
          ),
          _buildActionButton(
            icon: Icons.search_rounded,
            label: 'Поиск',
            color: AppColors.info,
            onTap: () => widget.onAction?.call('search'),
          ),
          _buildActionButton(
            icon: isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
            label: isDark ? 'Светлая' : 'Тёмная',
            color: isDark ? AppColors.warning : AppColors.textSecondary,
            onTap: () {
              HapticFeedback.mediumImpact();
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          _buildActionButton(
            icon: Icons.settings_rounded,
            label: 'Настройки',
            color: AppColors.textSecondary,
            onTap: () => widget.onAction?.call('settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = ref.watch(
      themeProvider.select((s) => s.value?.isDarkTheme ?? true),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredIndex = icon.hashCode),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: AnimatedContainer(
          duration: AppEffects.durationNormal,
          curve: AppEffects.curve,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: _hoveredIndex == icon.hashCode
                ? color.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppEffects.radiusFull),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: AppEffects.durationNormal,
                curve: AppEffects.curve,
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: _hoveredIndex == icon.hashCode
                      ? color
                      : (isDark
                            ? AppColors.cardBackground
                            : Colors.grey.shade200),
                  shape: BoxShape.circle,
                  boxShadow: _hoveredIndex == icon.hashCode
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: _hoveredIndex == icon.hashCode
                      ? Colors.black
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
