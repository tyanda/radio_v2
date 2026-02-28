import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marquee/marquee.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design/design.dart';
import '../../core/providers.dart';
import '../../core/providers/radio_providers.dart';
import '../horoscope/presentation/widgets/horoscope_view.dart';
import '../radio/presentation/widgets/mini_player.dart';
import '../radio/presentation/widgets/radio_view.dart';
import '../weather/presentation/weather_screen.dart';
import '../settings/settings_screen.dart';

/// Улучшенный HomeScreen с расширенной навигацией
///
/// Особенности:
/// - Плавные анимации переходов между вкладками
/// - Улучшенный bottom bar с hover-эффектами
/// - Анимированный хедер с пульсирующим логотипом
/// - Интеграция StationGrid для быстрого доступа
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
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkTheme;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Основной контент
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
                      HoroscopeView(),
                    ],
                  ),
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
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          SizedBox(height: AppSpacing.md),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.cardBackground.withValues(alpha: 0.98)
                  : Colors.white.withValues(alpha: 1.0),
              borderRadius: BorderRadius.circular(AppEffects.radiusFull),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
              ),
              boxShadow: isDarkMode
                  ? null
                  : AppEffects.shadowMd,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.sensors_rounded, 0, 'Радио'),
                _buildNavItem(Icons.filter_drama_rounded, 1, 'Погода'),
                _buildNavItem(Icons.auto_awesome_rounded, 2, 'Звезды'),
                _buildSettingsButton(
                  isDarkMode ? Icons.settings_rounded : Icons.settings_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Возвращает цвет иконки в зависимости от состояния и темы
  Color _getIconColor(bool isActive, bool isDark) {
    if (isActive) return Colors.black;
    return isDark
        ? Colors.white.withValues(alpha: 0.5)
        : AppColors.iconGrey;
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    final bool active = _currentTab == index;
    final accentColor = Theme.of(context).primaryColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Consumer(
        builder: (context, ref, _) {
          final isDark = ref.watch(themeProvider.select((s) => s.isDarkTheme));
          return GestureDetector(
            onTap: () => _onTabChanged(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: AppEffects.durationNormal,
              curve: AppEffects.curve,
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
                    size: 26,
                    color: _getIconColor(active, isDark),
                  ),
                  if (active) ...[
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsButton(IconData icon) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SettingsScreen(),
            ),
          );
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppEffects.radiusFull),
          ),
          child: Icon(
            icon,
            size: 26,
            color: ref.watch(themeProvider.select((s) => s.isDarkTheme))
                ? Colors.white.withValues(alpha: 0.5)
                : AppColors.iconGrey,
          ),
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
  late Animation<double> _rotateAnimation;

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
    
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * 3.14159,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Виджет SVG-иконки приветствия на основе времени суток
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
      // Fallback если SVG файл не найден
      return Icon(
        hour >= 6 && hour < 18 ? Icons.wb_sunny : Icons.nightlight_round,
        size: 20,
        color: isDarkMode ? AppColors.primaryLight : AppColors.primaryDark,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final greetingAsync = ref.watch(greetingProvider);
    final isDark = ref.watch(themeProvider).isDarkTheme;
    final topPadding = MediaQuery.of(context).padding.top + AppSpacing.sm;

    final greeting = greetingAsync.when(
      data: (data) => data.toUpperCase(),
      loading: () => "ЗАГРУЗКА...",
      error: (_, _) => "ДОБРО ПОЖАЛОВАТЬ",
    );

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: topPadding,
        bottom: AppSpacing.md,
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
                    color: isDark ? AppColors.textPrimary : AppColors.textName,
                    fontSize: 28,
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
              SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    greeting,
                    style: GoogleFonts.inter(
                      color: isDark ? AppColors.textTertiary : AppColors.textName,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 4.0,
                      height: 1.0,
                    ),
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  _buildGreetingSvg(isDark),
                ],
              ),
            ],
          ),
          // Анимированный логотип "Дыхание" с вращением
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotateAnimation.value * 0.05,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withValues(alpha: 0.3),
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                          blurRadius: _blurAnimation.value,
                          spreadRadius: _controller.value * 2,
                        ),
                      ],
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: isDark
                          ? AppColors.cardBackground
                          : Theme.of(context).scaffoldBackgroundColor,
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
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Marquee(
        text:
            "SAKHALIVE  |  ${marqueeText.toUpperCase()}  |  ОСТАВАЙТЕСЬ С НАМИ  ",
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.black,
        ),
        velocity: 30,
        blankSpace: 100,
        accelerationDuration: const Duration(seconds: 1),
        accelerationCurve: Curves.easeIn,
      ),
    );
  }
}
