import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marquee/marquee.dart';
import 'package:radio_v2/core/theme/app_colors.dart';
import 'package:radio_v2/core/theme/figma_design.dart';
import 'package:radio_v2/features/radio/presentation/providers/radio_providers.dart';
import 'package:radio_v2/features/weather/presentation/weather_screen.dart';
import 'package:radio_v2/features/radio/presentation/widgets/radio_view.dart';
import 'package:radio_v2/features/horoscope/presentation/widgets/horoscope_view.dart';
import 'package:radio_v2/features/radio/presentation/widgets/mini_player.dart';

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
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Основной контент
          Column(
            children: [
              const _AppHeader(),
              const _MarqueeSection(),
              // Контент начинается сразу после полосы
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
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Мини-плеер (спереди, «парящий»)
          const MiniPlayer(),
          const SizedBox(height: 8),
          // Навигационная панель (с фоном)
          MainNavBar(
            currentTab: _currentTab,
            onTabChanged: (int tabIndex) {
              setState(() {
                _currentTab = tabIndex;
              });
              _pageController.animateToPage(
                tabIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

class MainNavBar extends StatefulWidget {
  final int currentTab;
  final Function(int) onTabChanged;

  const MainNavBar({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
  });

  @override
  State<MainNavBar> createState() => _MainNavBarState();
}

class _MainNavBarState extends State<MainNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(FigmaDesign.navBarRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: FigmaDesign.navBarShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: _buildNavItem(Icons.sensors_rounded, "ЭФИР", 0)),
          Expanded(child: _buildNavItem(Icons.filter_drama_rounded, "ПОГОДА", 1)),
          Expanded(child: _buildNavItem(Icons.auto_awesome_rounded, "ГОРОСКОП", 2)),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool active = widget.currentTab == index;

    return SizedBox(
      height: FigmaDesign.navActiveHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Фон для активной вкладки
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: active ? 1.0 : 0.0,
            child: Container(
              width: FigmaDesign.navActiveWidth,
              height: FigmaDesign.navActiveHeight,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(FigmaDesign.buttonRadius),
              ),
            ),
          ),
          // Иконка
          Positioned(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => widget.onTabChanged(index),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  child: Icon(
                    icon,
                    color: active
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.2),
                    size: FigmaDesign.navIconSize,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppHeader extends ConsumerStatefulWidget {
  const _AppHeader();

  @override
  ConsumerState<_AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends ConsumerState<_AppHeader> with SingleTickerProviderStateMixin {
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

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _blurAnimation = Tween<double>(begin: 4.0, end: 16.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final greetingAsync = ref.watch(greetingProvider);

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
        bottom: 0.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: FigmaDesign.headerTitleSize,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    height: 1.0,
                  ),
                  children: [
                    TextSpan(text: "Sakha"),
                    TextSpan(
                      text: "Live",
                      style: TextStyle(
                        color: AppColors.accent,
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
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.accent,
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
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: _blurAnimation.value,
                        spreadRadius: _controller.value * 2,
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: FigmaDesign.headerLogoSize / 2,
                    backgroundColor: AppColors.cardBackground,
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
      height: FigmaDesign.marqueeHeight,
      decoration: const BoxDecoration(
        color: AppColors.accent,
      ),
      child: Marquee(
        text:
            "SAKHALIVE  |  ${marqueeText.toUpperCase()}  |  ОСТАВАЙТЕСЬ С НАМИ  ",
        style: const TextStyle(
          fontFamily: 'Inter',
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
