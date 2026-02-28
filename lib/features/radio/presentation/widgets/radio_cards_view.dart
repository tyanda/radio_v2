import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design/design.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/providers/radio_providers.dart';
import '../../../../core/providers.dart';
import '../providers/player_provider.dart';
import '../../domain/station.dart';
import 'vertical_radio_card.dart';
import '../../../../widgets/scroll_scale_card.dart';

/// RadioCardsView с фильтрацией и поиском
///
/// Особенности:
/// - Поиск по названию станции
/// - Фильтр: Все / Избранные
/// - Анимированное появление карточек
/// - Плавный скролл к активной станции
class RadioCardsView extends ConsumerStatefulWidget {
  const RadioCardsView({super.key});

  @override
  ConsumerState<RadioCardsView> createState() => _RadioCardsViewState();
}

class _RadioCardsViewState extends ConsumerState<RadioCardsView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  ScrollController? _scrollController;
  int? _lastActiveIndex;

  bool _showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: AppEffects.durationSlow,
    );

    // Запускаем анимацию с небольшой задержкой для плавности
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward().then((_) {
        _scrollToActiveStation();
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  void _scrollToActiveStation() {
    if (_scrollController == null || !_scrollController!.hasClients) return;

    final playerState = ref.read(playerProvider).value;
    final stations = ref.read(stationListProvider);
    final currentStation = playerState?.currentStation;

    if (currentStation == null || stations.isEmpty) return;

    final activeIndex = stations.indexWhere((s) => s.id == currentStation.id);
    if (activeIndex < 0 || activeIndex == _lastActiveIndex) return;

    _lastActiveIndex = activeIndex;

    final row = (activeIndex / 2).floor();
    final rowHeight = 196.0;
    final targetOffset = (row * rowHeight) - AppSpacing.md;

    _scrollController!.animateTo(
      targetOffset.clamp(0.0, _scrollController!.position.maxScrollExtent),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  List<Station> _filterStations(List<Station> stations, String? favoriteName) {
    var filtered = stations;

    // Фильтр избранных
    if (_showFavoritesOnly && favoriteName != null) {
      filtered = filtered.where((s) => s.name == favoriteName).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final allStations = ref.watch(stationListProvider);
    final playerAsync = ref.watch(playerProvider);
    final currentStation = playerAsync.value?.currentStation;
    final favoriteName = ref.watch(favoritesProvider.select(
      (state) => state.favoriteStationName,
    ));

    // Фильтрация станций
    final stations = _filterStations(allStations, favoriteName);

    // Авто-скролл к активной станции
    final isActiveChanged =
        currentStation != null &&
        _lastActiveIndex !=
            stations.indexWhere((s) => s.id == currentStation.id);
    if (isActiveChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToActiveStation();
      });
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            140.0, // kBottomBarTotalHeight
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Поиск и фильтры
              _buildSearchBar(),
              SizedBox(height: AppSpacing.md),
              // Сетка станций
              if (stations.isEmpty)
                _buildEmptyState()
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.lg,
                    mainAxisSpacing: AppSpacing.lg,
                    childAspectRatio: 0.88,
                  ),
                  clipBehavior: Clip.none,
                  itemCount: stations.length,
                  itemBuilder: (context, index) {
                    final station = stations[index];
                    final bool isActive = currentStation?.id == station.id;

                    return Consumer(
                      builder: (context, ref, child) {
                        final isFavorite = ref.watch(
                          favoritesProvider.select(
                            (state) =>
                                state.favoriteStationName == station.name,
                          ),
                        );

                        return ScrollScaleCard(
                          onTap: null,
                          child: _AnimatedCard(
                            index: index,
                            controller: _animationController,
                            child: VerticalRadioCard(
                              station: station,
                              isActive: isActive,
                              isFavorite: isFavorite,
                              onTap: () {
                                Logger.log(
                                  "RadioCardsView: onTap for station ${station.name}, isActive: $isActive",
                                  tag: 'RadioUI',
                                );
                                ref
                                    .read(playerProvider.notifier)
                                    .playStation(station);
                              },
                              onFavoriteTap: () {
                                ref
                                    .read(favoritesProvider.notifier)
                                    .toggleFavorite(station.name);
                              },
                              onLongPress: () {
                                ref
                                    .read(favoritesProvider.notifier)
                                    .toggleFavorite(station.name);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        // Фильтры
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  icon: Icons.list_rounded,
                  label: 'Все',
                  isSelected: !_showFavoritesOnly,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _showFavoritesOnly = false);
                  },
                ),
                SizedBox(width: AppSpacing.sm),
                _buildFilterChip(
                  icon: Icons.favorite_rounded,
                  label: 'Избранные',
                  isSelected: _showFavoritesOnly,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _showFavoritesOnly = true);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = ref.watch(themeProvider.select((s) => s.isDarkTheme));
    final accentColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppEffects.durationNormal,
        curve: AppEffects.curve,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppEffects.radiusFull),
          border: Border.all(
            color: isSelected
                ? accentColor
                : isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.black
                  : isDark
                      ? Colors.white.withValues(alpha: 0.6)
                      : Colors.black.withValues(alpha: 0.6),
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isSelected
                    ? Colors.black
                    : isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : Colors.black.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = ref.watch(themeProvider.select((s) => s.isDarkTheme));

    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _showFavoritesOnly ? Icons.favorite_outline_rounded : Icons.radio_rounded,
              size: 64,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.2),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              _showFavoritesOnly
                  ? 'Нет избранных станций'
                  : 'Радиостанции не найдены',
              style: GoogleFonts.inter(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.5),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedCard extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Widget child;

  const _AnimatedCard({
    required this.index,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Уменьшенная задержка для более плавного последовательного появления
    final delay = index * 0.05;
    final beginTime = delay.clamp(0.0, 0.8);

    // Более плавная кривая анимации с естественным движением
    final tween = Tween(
      begin: 0.0,
      end: 1.0,
    ).chain(CurveTween(curve: Curves.easeOutCubic));

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final animationValue = controller.value;
        // Плавный расчёт прогресса без резких переходов
        final progress = beginTime >= 1.0
            ? 1.0
            : ((animationValue - beginTime) / (1.0 - beginTime)).clamp(
                0.0,
                1.0,
              );
        final value = tween.transform(progress);

        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}
