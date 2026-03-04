import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppEffects.radiusFull),
      ),
      child: Row(
        children: [
          _ViewTypeButton(
            icon: Icons.grid_view_rounded,
            label: 'Плитка',
            type: ViewType.grid,
            isSelected: currentType == ViewType.grid,
            onChanged: onChanged,
          ),
          _ViewTypeButton(
            icon: Icons.view_list_rounded,
            label: 'Список',
            type: ViewType.list,
            isSelected: currentType == ViewType.list,
            onChanged: onChanged,
          ),
          _ViewTypeButton(
            icon: Icons.view_carousel_rounded,
            label: 'Лента',
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
  final String label;
  final ViewType type;
  final bool isSelected;
  final ValueChanged<ViewType> onChanged;

  const _ViewTypeButton({
    required this.icon,
    required this.label,
    required this.type,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = Theme.of(context).primaryColor;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onChanged(type);
        },
        child: AnimatedContainer(
          duration: AppEffects.durationNormal,
          curve: AppEffects.curve,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected ? accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppEffects.radiusFull),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? Colors.black
                      : isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.5),
                ),
                if (MediaQuery.of(context).size.width > 360) ...[
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: isSelected
                          ? Colors.black
                          : isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
