import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marquee/marquee.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:radio_v2/core/design/app_colors.dart';
import 'package:radio_v2/core/design/figma_design.dart';
import 'package:radio_v2/features/horoscope/presentation/widgets/horoscope_view.dart';
import 'package:radio_v2/core/providers/radio_providers.dart';
import 'package:radio_v2/features/radio/presentation/widgets/mini_player.dart';
import 'package:radio_v2/features/radio/presentation/widgets/radio_view.dart';
import 'package:radio_v2/features/weather/presentation/weather_screen.dart';
import 'package:radio_v2/core/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentTab = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Основной контент
          Column(
            children: [
              const _AppHeader(),
              const _MarqueeSection(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentTab = index;
                    });
                  },
                  children: [
                    const RadioView(),
                    const WeatherScreen(),
                    const HoroscopeView(),
                  ],
                ),
              ),
            ],
          ),
          // Плавающая нижняя панель
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(top: false, bottom: true, child: _buildBottomBar()),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final themeState = ref.watch(themeProvider);
    final isDarkMode = themeState.isDarkTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.cardBackground.withValues(alpha: 0.98)
                  : Colors.white.withValues(alpha: 1.0), // СТРОГО БЕЛЫЙ #FFFFFF
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
              ),
              boxShadow: isDarkMode
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.sensors_rounded, 0, 'Радио'),
                _buildNavItem(Icons.filter_drama_rounded, 1, 'Погода'),
                _buildNavItem(Icons.auto_awesome_rounded, 2, 'Звезды'),
                _buildThemeNavItem(
                  isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    final bool active = _currentTab == index;
    final isDark = ref.read(themeProvider).isDarkTheme;
    final accentColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _currentTab = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: active ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          icon,
          size: 26,
          color: active
              ? Colors
                    .black // Контраст на желтом
              : (isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : const Color(0xFFA7B0B8)), // iconGrey для светлой
        ),
      ),
    );
  }

  Widget _buildThemeNavItem(IconData icon) {
    final isDark = ref.read(themeProvider).isDarkTheme;
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        ref.read(themeProvider.notifier).toggleTheme();
        if (kDebugMode) print('Тема переключена');
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          icon,
          size: 26,
          color: isDark
              ? Colors.white.withValues(alpha: 0.5)
              : const Color(0xFFA7B0B8), // iconGrey для светлой
        ),
      ),
    );
  }
}

class _AppHeader extends ConsumerStatefulWidget {
  const _AppHeader();

  @override
  ConsumerState<_AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends ConsumerState<_AppHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _blurAnimation = Tween<double>(
      begin: 4.0,
      end: 16.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final greetingAsync = ref.watch(greetingProvider);
    final isDark = ref.watch(themeProvider).isDarkTheme;

    final greeting = greetingAsync.when(
      data: (data) => data.toUpperCase(),
      loading: () => "ЗАГРУЗКА...",
      error: (_, _) => "ДОБРО ПОЖАЛОВАТЬ",
    );

    return Padding(
      padding: EdgeInsets.only(
        left: FigmaDesign.horizontalPadding,
        right: FigmaDesign.horizontalPadding,
        top: 50.0,
        bottom: 12.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1D1D1F),
                    fontSize: FigmaDesign.headerTitleSize,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    height: 1.0,
                    fontFamily: 'Inter',
                  ),
                  children: [
                    const TextSpan(text: "Sakha"),
                    TextSpan(
                      text: "Live",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                greeting,
                style: GoogleFonts.inter(
                  color: isDark ? Theme.of(context).primaryColor : const Color(0xFF1D1D1F),
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  fontSize: FigmaDesign.fontSizeGreeting,
                  letterSpacing: 4.0,
                  height: 1.0,
                ),
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
              ),
            ],
          ),
          // Анимированный логотип "Дыхание"
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.3),
                        blurRadius: _blurAnimation.value,
                        spreadRadius: _controller.value * 2,
                      ),
                    ],
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: FigmaDesign.headerLogoSize / 2,
                    backgroundColor: isDark
                        ? AppColors.cardBackground
                        : Colors.white,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/load.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
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
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
      alignment: Alignment.center,
      child: Marquee(
        text:
            "SAKHALIVE  |  ${marqueeText.toUpperCase()}  |  ОСТАВАЙТЕСЬ С НАМИ  ",
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.black, // Контраст на желтом
        ),
        velocity: 30,
        blankSpace: 100,
        accelerationDuration: const Duration(seconds: 1),
        accelerationCurve: Curves.easeIn,
      ),
    );
  }
}
