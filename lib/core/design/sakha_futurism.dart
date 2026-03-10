import 'dart:ui';

import 'package:flutter/material.dart';

import 'design_tokens.dart';
import 'effects.dart';
import 'spacing.dart';

class SakhaFuturism {
  const SakhaFuturism._();

  static const double horizontalMargin = AppSpacing.lg;
  // Оптимизация: уменьшено с 18.0 до 12.0 для снижения нагрузки на GPU
  static const double glassBlur = 12.0;
  static const double cardRadius = 28.0;

  static EdgeInsets get screenPadding =>
      const EdgeInsets.symmetric(horizontal: horizontalMargin);

  static Color glassFill(bool isDark, {double opacity = 0.68}) {
    return (isDark ? const Color(0xFF131313) : Colors.white).withValues(
      alpha: opacity,
    );
  }

  static Color glassBorder(bool isDark, {Color? accent}) {
    final base = isDark ? Colors.white : Colors.black;
    return Color.alphaBlend(
      (accent ?? Colors.transparent).withValues(alpha: 0.12),
      base.withValues(alpha: isDark ? 0.14 : 0.06),
    );
  }

  static List<BoxShadow> shadow(bool isDark, {Color? accent, double lift = 1}) {
    final glow = accent ?? AppColors.primary;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.34 : 0.10),
        blurRadius: 32 * lift,
        offset: Offset(0, 16 * lift),
      ),
      BoxShadow(
        color: glow.withValues(alpha: isDark ? 0.16 : 0.10),
        blurRadius: 28 * lift,
        offset: Offset(0, 10 * lift),
      ),
    ];
  }

  static BoxDecoration decoration(
    BuildContext context, {
    Color? accent,
    bool active = false,
    double opacity = 0.72,
    double radius = cardRadius,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          glassFill(isDark, opacity: opacity + (active ? 0.08 : 0)),
          glassFill(isDark, opacity: opacity - 0.12),
        ],
      ),
      border: Border.all(
        color: glassBorder(isDark, accent: accent),
        width: active ? 1.35 : 1,
      ),
      boxShadow: shadow(isDark, accent: accent, lift: active ? 1.15 : 1),
    );
  }

  static Widget glass(
    BuildContext context, {
    required Widget child,
    Color? accent,
    bool active = false,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppSpacing.lg),
    double radius = cardRadius,
    Clip clipBehavior = Clip.antiAlias,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: clipBehavior,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: glassBlur, sigmaY: glassBlur),
        child: Container(
          padding: padding,
          decoration: decoration(
            context,
            accent: accent,
            active: active,
            radius: radius,
          ),
          child: child,
        ),
      ),
    );
  }

  static Widget ambientBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? const [
                        Color(0xFF06070A),
                        Color(0xFF0E1117),
                        Color(0xFF08090D),
                      ]
                    : const [
                        Color(0xFFF9FAFC),
                        Color(0xFFF2F3F8),
                        Color(0xFFEEF1F6),
                      ],
              ),
            ),
          ),
          Positioned(
            top: -60,
            left: -20,
            child: _orb(
              color: AppColors.primary.withValues(alpha: isDark ? 0.16 : 0.14),
              size: 220,
            ),
          ),
          Positioned(
            top: 160,
            right: -70,
            child: _orb(
              color: const Color(
                0xFF6EC5FF,
              ).withValues(alpha: isDark ? 0.16 : 0.10),
              size: 240,
            ),
          ),
          Positioned(
            bottom: -40,
            left: 40,
            child: _orb(
              color: const Color(
                0xFFFF8D5C,
              ).withValues(alpha: isDark ? 0.11 : 0.08),
              size: 180,
            ),
          ),
        ],
      ),
    );
  }

  static Widget ornamentLine(BuildContext context, {Color? accent}) {
    final color = accent ?? Theme.of(context).primaryColor;
    return SizedBox(
      height: 8,
      child: Row(
        children: List.generate(
          24,
          (index) => Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index == 23 ? 0 : 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppEffects.radiusFull),
                gradient: LinearGradient(
                  colors: index.isEven
                      ? [
                          color.withValues(alpha: 0.18),
                          color.withValues(alpha: 0.72),
                        ]
                      : [Colors.transparent, color.withValues(alpha: 0.40)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _orb({required Color color, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
