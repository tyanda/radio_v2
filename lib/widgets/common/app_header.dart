import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';

import '../../core/design/design.dart';
import '../../core/providers.dart';
import '../../features/settings/settings_screen.dart';

/// Общий хедер приложения с логотипом, приветствием и кнопкой настроек
/// Оптимизированная версия для веба (без BackdropFilter)
class AppHeader extends ConsumerWidget {
  const AppHeader({super.key});

  // Вынесенный const виджет для SVG иконки
  static Widget _buildGreetingSvg(bool isDarkMode) {
    final hour = DateTime.now().hour;
    String assetName;
    if (hour >= 6 && hour < 12) {
      assetName = 'morning';
    } else if (hour >= 12 && hour < 18) {
      assetName = 'day';
    } else if (hour >= 18 && hour < 24) {
      assetName = 'evening';
    } else {
      assetName = 'night';
    }

    try {
      return SvgPicture.asset(
        'assets/icons/$assetName.svg',
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(
          isDarkMode ? AppColors.primaryLight : AppColors.primaryDark,
          BlendMode.srcIn,
        ),
      );
    } catch (e) {
      return Icon(
        hour >= 6 && hour < 18 ? Icons.wb_sunny : Icons.nightlight_round,
        size: 20,
        color: isDarkMode ? AppColors.primaryLight : AppColors.primaryDark,
      );
    }
  }

  // Кэшированный стиль для заголовка
  static final _titleStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.4,
    fontFamily: 'Inter',
  );

  // Кэшированный стиль для приветствия
  static final _greetingStyle = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 10,
    letterSpacing: 0.5,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greetingAsync = ref.watch(greetingProvider);
    final isDark = ref.watch(
      themeProvider.select((s) => s.value?.isDarkTheme ?? true),
    );
    final topPadding = MediaQuery.of(context).padding.top + AppSpacing.xs;
    final primaryColor = Theme.of(context).primaryColor;

    final greeting = greetingAsync.when(
      data: (data) => data.toUpperCase(),
      loading: () => "ЗАГРУЗКА...",
      error: (_, _) => "ДОБРО ПОЖАЛОВАТЬ",
    );

    // Для веба: упрощённая версия без BackdropFilter
    if (kIsWeb) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          SakhaFuturism.horizontalMargin,
          topPadding,
          SakhaFuturism.horizontalMargin,
          AppSpacing.xs,
        ),
        child: RepaintBoundary(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: _titleStyle.copyWith(
                            color: isDark ? AppColors.textPrimary : AppColors.textName,
                          ),
                          children: [
                            const TextSpan(text: "Sakha"),
                            TextSpan(text: "Live", style: TextStyle(color: primaryColor)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              greeting,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _greetingStyle.copyWith(
                                color: isDark ? AppColors.textTertiary : AppColors.textName,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          _buildGreetingSvg(isDark),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const _SettingsButton(),
              ],
            ),
          ),
        ),
      );
    }

    // Для мобильных: полная версия с SakhaFuturism.glass
    return Padding(
      padding: EdgeInsets.fromLTRB(
        SakhaFuturism.horizontalMargin,
        topPadding,
        SakhaFuturism.horizontalMargin,
        AppSpacing.xs,
      ),
      child: RepaintBoundary(
        child: SakhaFuturism.glass(
          context,
          accent: primaryColor,
          radius: 30,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: _titleStyle.copyWith(
                          color: isDark ? AppColors.textPrimary : AppColors.textName,
                        ),
                        children: [
                          const TextSpan(text: "Sakha"),
                          TextSpan(text: "Live", style: TextStyle(color: primaryColor)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            greeting,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _greetingStyle.copyWith(
                              color: isDark ? AppColors.textTertiary : AppColors.textName,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        _buildGreetingSvg(isDark),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const _SettingsButton(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Кнопка настроек - вынесена в отдельный const виджет для оптимизации
class _SettingsButton extends StatelessWidget {
  const _SettingsButton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
      },
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withValues(
            alpha: isDark ? 0.06 : 0.05,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: isDark ? 0.10 : 0.55),
          ),
        ),
        child: Icon(
          isDark ? Icons.tune_rounded : Icons.tune_outlined,
          color: isDark ? AppColors.textPrimary : AppColors.textName,
        ),
      ),
    );
  }
}

/// Бегущая строка с новостями/информацией
/// Оптимизированная версия для веба (без BackdropFilter и ShaderMask)
class AppMarquee extends ConsumerWidget {
  const AppMarquee({super.key});

  // Кэшированный TextStyle для бегущей строки
  static final _marqueeStyle = GoogleFonts.inter(
    fontWeight: FontWeight.w800,
    fontSize: 12,
    letterSpacing: 1.5,
    height: 1.0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marqueeText = ref.watch(marqueeTextProvider);
    final isDark = ref.watch(
      themeProvider.select((s) => s.value?.isDarkTheme ?? true),
    );
    final primaryColor = Theme.of(context).primaryColor;

    // Для веба: упрощённая версия без BackdropFilter и ShaderMask
    if (kIsWeb) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          SakhaFuturism.horizontalMargin,
          0,
          SakhaFuturism.horizontalMargin,
          AppSpacing.sm,
        ),
        child: RepaintBoundary(
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Row(
              children: [
                _StaticIndicatorDot(primaryColor: primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: RepaintBoundary(
                    child: Marquee(
                      text:
                          "SAKHALIVE  //  ${marqueeText.toUpperCase()}  //  НОВОСТИ И ЭФИР БЕЗ ПАУЗ  ",
                      style: _marqueeStyle.copyWith(color: Colors.white),
                      velocity: 24,
                      blankSpace: 80,
                      startPadding: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Для мобильных: полная версия с эффектами
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SakhaFuturism.horizontalMargin,
        0,
        SakhaFuturism.horizontalMargin,
        AppSpacing.sm,
      ),
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0B0D12).withValues(alpha: isDark ? 0.90 : 0.80),
                    primaryColor.withValues(alpha: 0.30),
                    const Color(0xFF090B10).withValues(alpha: isDark ? 0.92 : 0.80),
                  ],
                ),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.35),
                ),
                boxShadow: [
                  ...SakhaFuturism.shadow(isDark, accent: primaryColor),
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.18),
                    blurRadius: 28,
                    spreadRadius: -4,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  _StaticIndicatorDot(primaryColor: primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white,
                          Colors.white,
                          Colors.transparent,
                        ],
                        stops: [0, 0.08, 0.92, 1],
                      ).createShader(bounds),
                      blendMode: BlendMode.dstIn,
                      child: RepaintBoundary(
                        child: Marquee(
                          text:
                              "SAKHALIVE  //  ${marqueeText.toUpperCase()}  //  НОВОСТИ И ЭФИР БЕЗ ПАУЗ  ",
                          style: _marqueeStyle.copyWith(color: Colors.white),
                          velocity: 24,
                          blankSpace: 80,
                          startPadding: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Статичный индикатор (точка) - вынесен в отдельный const виджет
class _StaticIndicatorDot extends StatelessWidget {
  final Color primaryColor;

  const _StaticIndicatorDot({required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: primaryColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.8),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

/// Полный хедер с бегущей строкой
/// Объединяет AppHeader и AppMarquee
class AppHeaderWithMarquee extends StatelessWidget {
  const AppHeaderWithMarquee({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: const [AppHeader(), AppMarquee()]);
  }
}
