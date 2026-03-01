import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design/design.dart';
import '../../../../core/design/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/providers/radio_providers.dart';
import '../../../../core/providers.dart';
import '../providers/player_provider.dart';
import '../../domain/station.dart';
import 'radio_card_v2.dart';
import 'view_type_selector.dart';
import 'station_context_menu.dart';
import 'horizontal_radio_cards.dart';

/// Улучшенный RadioCardsView со всеми новыми функциями
///
/// Особенности:
/// - Переключение видов: Плитка / Список / Горизонтальный
/// - Поиск по названию станции
/// - Фильтр: Все / Избранные
/// - Каскадная анимация появления
/// - 3D tilt эффект при наведении
/// - LIVE бейдж для активной станции
/// - Частота на карточке
/// - Контекстное меню по long press (Share, Favorites)
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
  final Map<int, GlobalKey> _cardKeys = {}; // Ключи для карточек в списке

  bool _showFavoritesOnly = false;
  ViewType _currentViewType = ViewType.grid;

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
    _cardKeys.clear();
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

    if (_currentViewType == ViewType.grid) {
      final row = (activeIndex / 2).floor();
      final rowHeight = 196.0;
      final targetOffset = (row * rowHeight) - AppSpacing.md;

      _scrollController!.animateTo(
        targetOffset.clamp(0.0, _scrollController!.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else if (_currentViewType == ViewType.list) {
      // Для списка скроллим к активной карточке через GlobalKey
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final key = _cardKeys[activeIndex];
        if (key != null && key.currentContext != null) {
          Scrollable.ensureVisible(
            key.currentContext!,
            alignment: 0.5, // Центрируем активную карточку
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  List<Station> _filterStations(
    List<Station> stations,
    Set<String> favoriteNames,
  ) {
    var filtered = stations;

    // Фильтр избранных
    if (_showFavoritesOnly && favoriteNames.isNotEmpty) {
      // Очищаем ключи при изменении фильтра
      _cardKeys.clear();
      filtered = filtered.where((s) => favoriteNames.contains(s.name)).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final allStations = ref.watch(stationListProvider);
    final playerAsync = ref.watch(playerProvider);
    final currentStation = playerAsync.value?.currentStation;
    final favoritesState = ref.watch(favoritesProvider);
    final favoriteNames = favoritesState.favoriteStationNames;

    // Фильтрация станций
    final stations = _filterStations(allStations, favoriteNames);

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
        return Column(
          children: [
            // Верхняя панель с фильтрами и переключателем видов
            _buildTopBar(),
            // Контент
            Expanded(
              child: stations.isEmpty
                  ? _buildEmptyState()
                  : _buildContentView(stations, currentStation, favoriteNames),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Переключатель видов
          ViewTypeSelector(
            currentType: _currentViewType,
            onChanged: (type) {
              setState(() {
                _currentViewType = type;
              });
            },
          ),
          SizedBox(height: AppSpacing.md),
          // Фильтры
          SingleChildScrollView(
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
        ],
      ),
    );
  }

  Widget _buildContentView(
    List<Station> stations,
    Station? currentStation,
    Set<String> favoriteNames,
  ) {
    if (_currentViewType == ViewType.horizontal) {
      return const HorizontalRadioCards();
    } else if (_currentViewType == ViewType.list) {
      return _buildListView(stations, currentStation, favoriteNames);
    } else {
      return _buildGridView(stations, currentStation, favoriteNames);
    }
  }

  Widget _buildGridView(
    List<Station> stations,
    Station? currentStation,
    Set<String> favoriteNames,
  ) {
    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        bottomPlayerHeight,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.lg,
        mainAxisSpacing: AppSpacing.lg,
        childAspectRatio: 0.88,
      ),
      clipBehavior: Clip.antiAlias,
      primary: false,
      itemCount: stations.length,
      itemBuilder: (context, index) {
        final station = stations[index];
        final bool isActive = currentStation?.id == station.id;
        final isFavorite = favoriteNames.contains(station.name);

        return _AnimatedCard(
          index: index,
          controller: _animationController,
          child: RadioCardV2(
            station: station,
            isActive: isActive,
            isFavorite: isFavorite,
            viewType: ViewType.grid,
            onTap: () {
              Logger.log(
                "RadioCardsView: onTap for station ${station.name}, isActive: $isActive",
                tag: 'RadioUI',
              );
              ref.read(playerProvider.notifier).playStation(station);
            },
            onFavoriteTap: () {
              ref.read(favoritesProvider.notifier).toggleFavorite(station.name);
            },
            onLongPress: () {
              StationContextMenu.show(
                context: context,
                station: station,
                isFavorite: isFavorite,
                onToggleFavorite: () {
                  ref
                      .read(favoritesProvider.notifier)
                      .toggleFavorite(station.name);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildListView(
    List<Station> stations,
    Station? currentStation,
    Set<String> favoriteNames,
  ) {
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        bottomPlayerHeight,
      ),
      child: Column(
        children: stations.asMap().entries.map((entry) {
          final index = entry.key;
          final station = entry.value;
          final isActive = currentStation?.id == station.id;
          final isFavorite = favoriteNames.contains(station.name);

          // Создаём GlobalKey для каждой карточки
          if (!_cardKeys.containsKey(index)) {
            _cardKeys[index] = GlobalKey();
          }

          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: KeyedSubtree(
              key: _cardKeys[index],
              child: _buildListCard(station, isActive, isFavorite),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListCard(Station station, bool isActive, bool isFavorite) {
    final isDark = ref.watch(themeProvider.select((s) => s.isDarkTheme));
    final accentColor = Theme.of(context).primaryColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          ref.read(playerProvider.notifier).playStation(station);
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          StationContextMenu.show(
            context: context,
            station: station,
            isFavorite: isFavorite,
            onToggleFavorite: () {
              ref.read(favoritesProvider.notifier).toggleFavorite(station.name);
            },
          );
        },
        child: AnimatedContainer(
          duration: AppEffects.durationNormal,
          curve: AppEffects.curve,
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: [accentColor, accentColor.withValues(alpha: 0.9)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: isActive
                ? null
                : isDark
                ? AppColors.cardBackground
                : Colors.white,
            borderRadius: BorderRadius.circular(AppEffects.radiusLg),
            border: Border.all(
              color: isActive
                  ? accentColor
                  : isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Изображение
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppEffects.radiusMd),
                  color: const Color(0xFF000000),
                ),
                child: station.art.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppEffects.radiusMd,
                        ),
                        child: Image.asset(
                          station.art,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                station.icon,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text(
                          station.icon,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
              ),

              SizedBox(width: AppSpacing.md),

              // Информация
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            station.name.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: isActive
                                  ? Colors.black
                                  : isDark
                                  ? Colors.white
                                  : Colors.black,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isActive) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.black.withValues(alpha: 0.2)
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(
                                AppEffects.radiusSm,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Text(
                                  'LIVE',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 8,
                                    color: isActive
                                        ? Colors.black.withValues(alpha: 0.7)
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: 2),

                    // Описание
                    Text(
                      station.desc,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        color: isActive
                            ? Colors.black.withValues(alpha: 0.6)
                            : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Кнопка избранного
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref
                      .read(favoritesProvider.notifier)
                      .toggleFavorite(station.name);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isFavorite
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_outline_rounded,
                    color: isFavorite
                        ? Colors.red
                        : isActive
                        ? Colors.black.withValues(alpha: 0.5)
                        : AppColors.iconGrey,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
              _showFavoritesOnly
                  ? Icons.favorite_outline_rounded
                  : Icons.radio_rounded,
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
    // Каскадная задержка для последовательного появления
    final delay = index * 0.05;
    final beginTime = delay.clamp(0.0, 0.8);

    // Плавная кривая анимации с естественным движением
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
