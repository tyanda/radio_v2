import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marquee/marquee.dart';
import 'package:radio_v2/core/theme/app_colors.dart';
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
      body: SafeArea(
        child: Column(
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
                  WeatherScreen(),
                  const HoroscopeView(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return MainNavBar(
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        bottomPadding > 0 ? bottomPadding : 20,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                _buildNavItem(Icons.sensors_rounded, "ЭФИР", 0),
                _buildNavItem(Icons.filter_drama_rounded, "ПОГОДА", 1),
                _buildNavItem(Icons.auto_awesome_rounded, "ГОРОСКОП", 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool active = widget.currentTab == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => widget.onTabChanged(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (active)
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    AnimatedScale(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      scale: active ? 1.1 : 1.0,
                      child: Icon(
                        icon,
                        color: active
                            ? AppColors.accent
                            : Colors.white.withValues(alpha: 0.2),
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: active
                        ? AppColors.primaryText
                        : Colors.white.withValues(alpha: 0.2),
                    fontSize: 10,
                    fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(top: 4),
                  height: 3,
                  width: active ? 3 : 0,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
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

class _AppHeader extends ConsumerWidget {
  const _AppHeader();

  // Логика выбора иконки в зависимости от времени суток
  IconData _getTimeBasedIcon() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      return Icons.wb_twilight_rounded; // Утро
    } else if (hour >= 12 && hour < 18) {
      return Icons.wb_sunny_rounded; // День
    } else if (hour >= 18 && hour < 22) {
      return Icons.wb_cloudy_rounded; // Вечер
    } else {
      return Icons.nights_stay_rounded; // Ночь
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greetingAsync = ref.watch(greetingProvider);

    final greeting = greetingAsync.when(
      data: (data) => data.toUpperCase(),
      loading: () => "ЗАГРУЗКА...",
      error: (_, _) => "ДОБРО ПОЖАЛОВАТЬ",
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                  children: [
                    TextSpan(text: "Sakha"),
                    TextSpan(
                      text: "Live",
                      style: TextStyle(color: AppColors.accent),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Та самая большая иконка справа
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.cardBackground,
              child: Icon(
                _getTimeBasedIcon(), // Используем нашу новую логику времени
                color: AppColors.accent,
                size: 20,
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
      height: 36,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Marquee(
        text:
            "SAKHALIVE  |  ${marqueeText.toUpperCase()}  |  ОСТАВАЙТЕСЬ С НАМИ  ",
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w900,
          fontSize: 12,
          letterSpacing: 1.0,
        ),
        velocity: 30,
        blankSpace: 100,
        accelerationDuration: const Duration(seconds: 1),
        accelerationCurve: Curves.easeIn,
      ),
    );
  }
}
