import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design/design.dart';
import '../../core/providers.dart';
import '../../widgets/common/app_header.dart';
import '../charts/presentation/charts_screen.dart';
import '../horoscope/presentation/widgets/horoscope_view.dart';
import '../radio/presentation/widgets/mini_player.dart';
import '../radio/presentation/widgets/radio_view.dart';
import '../weather/presentation/weather_screen.dart';

/// Улучшенный HomeScreen с расширенной навигацией
///
/// Оптимизация производительности:
/// - Lazy loading для вкладок (загружаются только при переключении)
/// - AutomaticKeepAliveClientMixin для сохранения состояния
/// - RepaintBoundary для изоляции перерисовки
/// - Вынесенные виджеты для навигации
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

  // Lazy loading: загружаем только первую вкладку сразу
  final Map<int, bool> _loadedTabs = {0: true, 1: false, 2: false, 3: false};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _fadeController = AnimationController(
      vsync: this,
      duration: AppEffects.durationNormal,
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
    _fadeController.reverse().then((_) {
      setState(() {
        _currentTab = index;
        _loadedTabs[index] = true;
      });
      _fadeController.forward();
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
          // Фон: для веба упрощённый (без орбов), для мобильных полный
          kIsWeb
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? const [Color(0xFF0A0A0A), Color(0xFF0E1117)]
                          : const [Color(0xFFF5F5F7), Color(0xFFEEF1F6)],
                    ),
                  ),
                )
              : SakhaFuturism.ambientBackground(context),
          Column(
            children: [
              const AppHeaderWithMarquee(),
              Expanded(
                child: RepaintBoundary(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentTab = index;
                        _loadedTabs[index] = true;
                      });
                    },
                    children: [
                      // Радио — загружается сразу (keepAlive = true)
                      KeepAliveWrapper(
                        key: const PageStorageKey('radio'),
                        keepAlive: true,
                        child: const RadioView(),
                      ),
                      // Погода — lazy loading (keepAlive = true)
                      KeepAliveWrapper(
                        key: const PageStorageKey('weather'),
                        keepAlive: true,
                        child: _loadedTabs[1] ?? false
                            ? const WeatherScreen()
                            : const _EmptyTab(),
                      ),
                      // Гороскоп — lazy loading (keepAlive = false)
                      KeepAliveWrapper(
                        key: const PageStorageKey('horoscope'),
                        keepAlive: false,
                        child: _loadedTabs[2] ?? false
                            ? const HoroscopeView()
                            : const _EmptyTab(),
                      ),
                      // Чарты — lazy loading (keepAlive = false)
                      KeepAliveWrapper(
                        key: const PageStorageKey('charts'),
                        keepAlive: false,
                        child: _loadedTabs[3] ?? false
                            ? const ChartsScreen()
                            : const _EmptyTab(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Вынесенная навигация в отдельный виджет
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomNavigationBar(
              currentTab: _currentTab,
              onTabChanged: _onTabChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// Вынесенная навигация для оптимизации
/// Оптимизированная версия для веба (без BackdropFilter)
class _BottomNavigationBar extends ConsumerWidget {
  final int currentTab;
  final ValueChanged<int> onTabChanged;

  const _BottomNavigationBar({
    required this.currentTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(
      themeProvider.select((s) => s.value?.isDarkTheme ?? true),
    );
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final accentColor = Theme.of(context).primaryColor;

    // Для веба: упрощённая версия без BackdropFilter
    if (kIsWeb) {
      return SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            SakhaFuturism.horizontalMargin,
            AppSpacing.md,
            SakhaFuturism.horizontalMargin,
            AppSpacing.md + bottomPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const RepaintBoundary(child: MiniPlayer()),
              SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.sensors_rounded,
                      index: 0,
                      label: 'Радио',
                      active: currentTab == 0,
                      accentColor: accentColor,
                      isDark: isDarkMode,
                      onTap: onTabChanged,
                    ),
                    _NavItem(
                      icon: Icons.filter_drama_rounded,
                      index: 1,
                      label: 'Погода',
                      active: currentTab == 1,
                      accentColor: accentColor,
                      isDark: isDarkMode,
                      onTap: onTabChanged,
                    ),
                    _NavItem(
                      icon: Icons.auto_awesome_rounded,
                      index: 2,
                      label: 'Звезды',
                      active: currentTab == 2,
                      accentColor: accentColor,
                      isDark: isDarkMode,
                      onTap: onTabChanged,
                    ),
                    _NavItem(
                      icon: Icons.music_note_rounded,
                      index: 3,
                      label: 'Топ',
                      active: currentTab == 3,
                      accentColor: accentColor,
                      isDark: isDarkMode,
                      onTap: onTabChanged,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Для мобильных: полная версия с BackdropFilter
    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          SakhaFuturism.horizontalMargin,
          AppSpacing.md,
          SakhaFuturism.horizontalMargin,
          AppSpacing.md + bottomPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const RepaintBoundary(child: MiniPlayer()),
            SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
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
                      _NavItem(
                        icon: Icons.sensors_rounded,
                        index: 0,
                        label: 'Радио',
                        active: currentTab == 0,
                        accentColor: accentColor,
                        isDark: isDarkMode,
                        onTap: onTabChanged,
                      ),
                      _NavItem(
                        icon: Icons.filter_drama_rounded,
                        index: 1,
                        label: 'Погода',
                        active: currentTab == 1,
                        accentColor: accentColor,
                        isDark: isDarkMode,
                        onTap: onTabChanged,
                      ),
                      _NavItem(
                        icon: Icons.auto_awesome_rounded,
                        index: 2,
                        label: 'Звезды',
                        active: currentTab == 2,
                        accentColor: accentColor,
                        isDark: isDarkMode,
                        onTap: onTabChanged,
                      ),
                      _NavItem(
                        icon: Icons.music_note_rounded,
                        index: 3,
                        label: 'Топ',
                        active: currentTab == 3,
                        accentColor: accentColor,
                        isDark: isDarkMode,
                        onTap: onTabChanged,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Элемент навигации с кэшированием
class _NavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final String label;
  final bool active;
  final Color accentColor;
  final bool isDark;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.index,
    required this.label,
    required this.active,
    required this.accentColor,
    required this.isDark,
    required this.onTap,
  });

  // Кэшированный стиль текста
  static final _labelStyle = GoogleFonts.inter(
    fontWeight: FontWeight.w700,
    fontSize: 12,
    letterSpacing: 0.2,
  );

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: active ? 'Текущая вкладка' : 'Перейти на вкладку $label',
      selected: active,
      button: true,
      child: GestureDetector(
        onTap: () => onTap(index),
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
                Text(label, style: _labelStyle.copyWith(color: Colors.black)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Пустая заглушка для lazy loading вкладок
class _EmptyTab extends StatelessWidget {
  const _EmptyTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF2C94C)),
        ),
      ),
    );
  }
}

/// Wrapper для сохранения состояния виджетов с AutomaticKeepAliveClientMixin
class KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  final bool keepAlive;

  const KeepAliveWrapper({
    super.key,
    required this.child,
    this.keepAlive = true,
  });

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
