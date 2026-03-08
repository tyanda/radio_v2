import 'dart:ui';

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
/// Используется на всех основных экранах
class AppHeader extends ConsumerWidget {
  const AppHeader({super.key});

  Widget _buildGreetingSvg(bool isDarkMode) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greetingAsync = ref.watch(greetingProvider);
    final isDark = ref.watch(
      themeProvider.select((s) => s.value?.isDarkTheme ?? true),
    );
    final topPadding = MediaQuery.of(context).padding.top + AppSpacing.sm;

    final greeting = greetingAsync.when(
      data: (data) => data.toUpperCase(),
      loading: () => "ЗАГРУЗКА...",
      error: (_, _) => "ДОБРО ПОЖАЛОВАТЬ",
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        SakhaFuturism.horizontalMargin,
        topPadding,
        SakhaFuturism.horizontalMargin,
        AppSpacing.sm,
      ),
      child: SakhaFuturism.glass(
        context,
        accent: Theme.of(context).primaryColor,
        radius: 30,
        padding: const EdgeInsets.fromLTRB(18, 18, 10, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SAKHA FUTURISM / RADIO',
                        style: GoogleFonts.inter(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 2.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textPrimary
                                : AppColors.textName,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.4,
                            fontFamily: 'Inter',
                          ),
                          children: [
                            const TextSpan(text: "Sakha"),
                            TextSpan(
                              text: "Live",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withValues(
                        alpha: isDark ? 0.06 : 0.05,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: isDark ? 0.10 : 0.55,
                        ),
                      ),
                    ),
                    child: Icon(
                      isDark ? Icons.tune_rounded : Icons.tune_outlined,
                      color: isDark
                          ? AppColors.textPrimary
                          : AppColors.textName,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SakhaFuturism.ornamentLine(context),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  greeting,
                  style: GoogleFonts.inter(
                    color: isDark ? AppColors.textTertiary : AppColors.textName,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 2.6,
                  ),
                ),
                const SizedBox(width: 8),
                _buildGreetingSvg(isDark),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(AppEffects.radiusFull),
                  ),
                  child: Text(
                    'YAKUTSK / LIVE',
                    style: GoogleFonts.inter(
                      color: isDark ? Colors.white : AppColors.textName,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      letterSpacing: 1.8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Бегущая строка с новостями/информацией
class AppMarquee extends ConsumerWidget {
  const AppMarquee({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marqueeText = ref.watch(marqueeTextProvider);
    final isDark = ref.watch(
      themeProvider.select((s) => s.value?.isDarkTheme ?? true),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SakhaFuturism.horizontalMargin,
        0,
        SakhaFuturism.horizontalMargin,
        AppSpacing.sm,
      ),
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
                  const Color(
                    0xFF0B0D12,
                  ).withValues(alpha: isDark ? 0.90 : 0.80),
                  Theme.of(context).primaryColor.withValues(alpha: 0.30),
                  const Color(
                    0xFF090B10,
                  ).withValues(alpha: isDark ? 0.92 : 0.80),
                ],
              ),
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.35),
              ),
              boxShadow: [
                ...SakhaFuturism.shadow(
                  isDark,
                  accent: Theme.of(context).primaryColor,
                ),
                BoxShadow(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.18),
                  blurRadius: 28,
                  spreadRadius: -4,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.8),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
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
                    child: Marquee(
                      text:
                          "SAKHALIVE  //  ${marqueeText.toUpperCase()}  //  НОВОСТИ И ЭФИР БЕЗ ПАУЗ  ",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                      velocity: 24,
                      blankSpace: 80,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
