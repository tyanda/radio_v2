import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import '../../core/design/design.dart';
import '../../core/providers.dart';
import '../../widgets/common/app_header.dart';
import '../charts/presentation/charts_screen.dart';
import '../horoscope/presentation/widgets/horoscope_view.dart';
import '../radio/presentation/widgets/mini_player.dart';
import '../radio/presentation/widgets/radio_view.dart';
import '../weather/presentation/weather_screen.dart';

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
          SakhaFuturism.ambientBackground(context),
          Column(
            children: [
              const AppHeaderWithMarquee(),
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
                      RadioView(), // 0 - Радио
                      WeatherScreen(), // 1 - Погода
                      HoroscopeView(), // 2 - Гороскоп
                      ChartsScreen(), // 3 - Топ Чарт (последний)
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
    final accentColor = Theme.of(context).primaryColor;

    return Container(
      padding: EdgeInsets.fromLTRB(
        SakhaFuturism.horizontalMargin,
        AppSpacing.md,
        SakhaFuturism.horizontalMargin,
        AppSpacing.md + bottomPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: SakhaFuturism.glassBlur + 2,
                sigmaY: SakhaFuturism.glassBlur + 2,
              ),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (isDarkMode ? const Color(0xFF14161A) : Colors.white)
                          .withValues(alpha: 0.86),
                      (isDarkMode
                              ? const Color(0xFF101113)
                              : const Color(0xFFF8F8FA))
                          .withValues(alpha: 0.74),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(
                    color: Colors.white.withValues(
                      alpha: isDarkMode ? 0.12 : 0.65,
                    ),
                  ),
                  boxShadow: SakhaFuturism.shadow(
                    isDarkMode,
                    accent: accentColor,
                    lift: 1.15,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.sensors_rounded, 0, 'Радио'),
                    _buildNavItem(Icons.filter_drama_rounded, 1, 'Погода'),
                    _buildNavItem(Icons.auto_awesome_rounded, 2, 'Звезды'),
                    _buildNavItem(Icons.music_note_rounded, 3, 'Топ'),
                  ],
                ),
              ),
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
        duration: AppEffects.durationSlow,
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: active ? AppSpacing.lg : AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(
                  colors: [accentColor, accentColor.withValues(alpha: 0.78)],
                )
              : null,
          color: active ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(AppEffects.radiusFull),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.34),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: active
                  ? Colors.black
                  : (isDark ? Colors.white54 : AppColors.iconGrey),
            ),
            if (active) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.2,
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
