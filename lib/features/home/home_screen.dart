import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marquee/marquee.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design/design.dart';
import '../../core/providers.dart';
import '../../core/providers/radio_providers.dart';
import '../charts/presentation/charts_screen.dart';
import '../horoscope/presentation/widgets/horoscope_view.dart';
import '../radio/presentation/widgets/mini_player.dart';
import '../radio/presentation/widgets/radio_view.dart';
import '../weather/presentation/weather_screen.dart';
import '../settings/settings_screen.dart';

/// Улучшенный HomeScreen с расширенной навигацией
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  int _currentTab = 0;
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _fadeController = AnimationController(
      vsync: this,
      duration: AppEffects.durationNormal,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _fadeController.reverse().then((_) {
        setState(() {
          _currentTab = index;
        });
        _fadeController.forward();
      });
    });

    _pageController.animateToPage(
      index,
      duration: AppEffects.durationSlow,
      curve: AppEffects.curveEmphasis,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(
      themeProvider.select((s) => s.value?.isDarkTheme ?? true),
    );

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: isDark
          ? AppColors.background
          : AppColors.backgroundLight,
      body: Stack(
        children: [
          Column(
            children: [
              const _AppHeader(),
              const _MarqueeSection(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentTab = index;
                      });
                    },
                    children: const [
                      RadioView(),
                      WeatherScreen(),
                      ChartsScreen(),
                      HoroscopeView(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              bottom: false,
              child: _buildBottomBar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isDarkMode = ref.watch(
      themeProvider.select((s) => s.value?.isDarkTheme ?? true),
    );
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + bottomPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.cardBackground.withValues(alpha: 0.98)
                  : Colors.white,
              borderRadius: BorderRadius.circular(AppEffects.radiusFull),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
              ),
              boxShadow: isDarkMode ? null : AppEffects.shadowMd,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.sensors_rounded, 0, 'Радио'),
                _buildNavItem(Icons.filter_drama_rounded, 1, 'Погода'),
                _buildNavItem(Icons.music_note_rounded, 2, 'Топ'),
                _buildNavItem(Icons.auto_awesome_rounded, 3, 'Звезды'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    final bool active = _currentTab == index;
    final accentColor = Theme.of(context).primaryColor;
    final isDark = ref.watch(
      themeProvider.select((s) => s.value?.isDarkTheme ?? true),
    );

    return GestureDetector(
      onTap: () => _onTabChanged(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppEffects.durationNormal,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: active ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppEffects.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              size: 24, 
              color: active 
                ? Colors.black 
                : (isDark ? Colors.white54 : AppColors.iconGrey)
            ),
            if (active) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AppHeader extends ConsumerWidget {
  const _AppHeader();

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
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, topPadding, AppSpacing.lg, AppSpacing.md),
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
                      color: isDark ? AppColors.textTertiary : AppColors.textName,
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
                color: isDark ? AppColors.cardBackground : Colors.black.withValues(alpha: 0.05),
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

class _MarqueeSection extends ConsumerWidget {
  const _MarqueeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marqueeText = ref.watch(marqueeTextProvider);
    return Container(
      height: 32.0,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      alignment: Alignment.center,
      child: Marquee(
        text: "SAKHALIVE  |  ${marqueeText.toUpperCase()}  |  ОСТАВАЙТЕСЬ С НАМИ  ",
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
