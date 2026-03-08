import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';

import '../../core/design/design.dart';
import '../../core/providers.dart';
import '../../core/providers/radio_providers.dart';
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
        AppSpacing.lg,
        topPadding,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimary : AppColors.textName,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    fontFamily: 'Inter',
                  ),
                  children: [
                    const TextSpan(text: "Sakha"),
                    TextSpan(
                      text: "Live",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    greeting,
                    style: GoogleFonts.inter(
                      color: isDark
                          ? AppColors.textTertiary
                          : AppColors.textName,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      letterSpacing: 3.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildGreetingSvg(isDark),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardBackground
                    : Colors.black.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDark ? Icons.settings_rounded : Icons.settings_outlined,
                color: isDark ? AppColors.textPrimary : AppColors.textName,
              ),
            ),
          ),
        ],
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

    return Container(
      height: 32.0,
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
      alignment: Alignment.center,
      child: Marquee(
        text:
            "SAKHALIVE  |  ${marqueeText.toUpperCase()}  |  ОСТАВАЙТЕСЬ С НАМИ  ",
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: Colors.black,
        ),
        velocity: 30,
        blankSpace: 100,
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
