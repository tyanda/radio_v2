import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/design/design.dart';
import 'radio_card_v2.dart';

/// Переключатель видов (Плитка / Список / Горизонтальный)
class ViewTypeSelector extends StatelessWidget {
  final ViewType currentType;
  final ValueChanged<ViewType> onChanged;

  const ViewTypeSelector({
    super.key,
    required this.currentType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SakhaFuturism.glassFill(isDark, opacity: 0.52),
            SakhaFuturism.glassFill(isDark, opacity: 0.34),
          ],
        ),
        borderRadius: BorderRadius.circular(AppEffects.radiusFull),
        border: Border.all(color: SakhaFuturism.glassBorder(isDark)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ViewTypeButton(
            icon: Icons.grid_view_rounded,
            type: ViewType.grid,
            isSelected: currentType == ViewType.grid,
            onChanged: onChanged,
          ),
          _ViewTypeButton(
            icon: Icons.view_list_rounded,
            type: ViewType.list,
            isSelected: currentType == ViewType.list,
            onChanged: onChanged,
          ),
          _ViewTypeButton(
            icon: Icons.view_carousel_rounded,
            type: ViewType.horizontal,
            isSelected: currentType == ViewType.horizontal,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ViewTypeButton extends StatelessWidget {
  final IconData icon;
  final ViewType type;
  final bool isSelected;
  final ValueChanged<ViewType> onChanged;

  const _ViewTypeButton({
    required this.icon,
    required this.type,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onChanged(type);
      },
      child: AnimatedContainer(
        duration: AppEffects.durationNormal,
        curve: AppEffects.curve,
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [accentColor, accentColor.withValues(alpha: 0.78)],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(AppEffects.radiusFull),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.24),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected
              ? Colors.black
              : isDark
              ? Colors.white.withValues(alpha: 0.5)
              : Colors.black.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
