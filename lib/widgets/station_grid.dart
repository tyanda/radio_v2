import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/design/design.dart';
import '../core/providers.dart';
import '../core/providers/radio_providers.dart';
import '../features/radio/domain/station.dart';
import '../features/radio/presentation/providers/player_provider.dart';

/// StationGrid — Grid-раскладка избранных станций
///
/// Особенности:
/// - Компактное отображение избранных станций
/// - Быстрый доступ к любимым радиостанциям
/// - Анимации при наведении и выборе
/// - Индикатор воспроизведения
///
/// Использование:
/// ```dart
/// StationGrid(
///   maxStations: 6,
///   onTap: (station) => ...,
/// )
/// ```
class StationGrid extends ConsumerStatefulWidget {
  final int maxStations;
  final Function(Station)? onTap;
  final bool showPlayIndicator;
  final bool compact;

  const StationGrid({
    super.key,
    this.maxStations = 6,
    this.onTap,
    this.showPlayIndicator = true,
    this.compact = false,
  });

  @override
  ConsumerState<StationGrid> createState() => _StationGridState();
}

class _StationGridState extends ConsumerState<StationGrid>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppEffects.durationSlow,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final allStations = ref.watch(stationListProvider);
    final currentStation = ref.watch(playerProvider).value?.currentStation;

    // Получаем избранные станции
    final favoriteStations = allStations
        .where((s) => favorites.isFavorite(s.name))
        .take(widget.maxStations)
        .toList();

    if (favoriteStations.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.compact) ...[
          _buildHeader(favoriteStations.length),
          SizedBox(height: AppSpacing.md),
        ],
        _buildGrid(favoriteStations, currentStation),
      ],
    );
  }

  Widget _buildHeader(int count) {
    final isDark = ref.watch(themeProvider.select((s) => s.isDarkTheme));

    return Row(
      children: [
        Icon(
          Icons.favorite_rounded,
          size: 18,
          color: AppColors.primary,
        ),
        SizedBox(width: AppSpacing.xs),
        Text(
          'Избранные',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppEffects.radiusFull),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(List<Station> stations, Station? currentStation) {
    final columns = widget.compact ? 3 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: widget.compact ? 1.5 : 1.2,
      ),
      itemCount: stations.length,
      itemBuilder: (context, index) {
        final station = stations[index];
        final isActive = currentStation?.id == station.id;

        return _buildStationCard(station, index, isActive);
      },
    );
  }

  Widget _buildStationCard(Station station, int index, bool isActive) {
    final isDark = ref.watch(themeProvider.select((s) => s.isDarkTheme));
    final delay = index * 0.05;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final progress =
            ((_animationController.value - delay) / (1.0 - delay)).clamp(0.0, 1.0);
        final value = Curves.easeOutCubic.transform(progress);

        return Transform.translate(
          offset: Offset(0, 16 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: _buildCard(station, isActive, isDark),
          ),
        );
      },
    );
  }

  Widget _buildCard(Station station, bool isActive, bool isDark) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredIndex = station.hashCode),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (widget.onTap != null) {
            widget.onTap!(station);
          } else {
            ref.read(playerProvider.notifier).playStation(station);
          }
        },
        child: AnimatedContainer(
          duration: AppEffects.durationNormal,
          curve: AppEffects.curve,
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : _hoveredIndex == station.hashCode
                    ? LinearGradient(
                        colors: isDark
                            ? [
                                AppColors.cardBackground.withValues(alpha: 0.98),
                                AppColors.surface.withValues(alpha: 0.95),
                              ]
                            : [
                                Colors.white.withValues(alpha: 1.0),
                                Colors.white.withValues(alpha: 0.95),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
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
                  ? AppColors.primary
                  : _hoveredIndex == station.hashCode
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05),
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : _hoveredIndex == station.hashCode
                    ? AppEffects.shadowMd
                    : AppEffects.shadowSm,
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    // Логотип станции
                    Expanded(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppEffects.radiusMd),
                            child: Container(
                              width: double.infinity,
                              color: isDark
                                  ? AppColors.surface
                                  : Colors.grey.shade100,
                              child: station.art.isNotEmpty
                                  ? Image.asset(
                                      station.art,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Center(
                                          child: Icon(
                                            Icons.radio,
                                            color: isDark
                                                ? Colors.white.withValues(
                                                    alpha: 0.3)
                                                : Colors.black.withValues(
                                                    alpha: 0.3),
                                            size: 24,
                                          ),
                                        );
                                      },
                                    )
                                  : Center(
                                      child: Icon(
                                        Icons.radio,
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.3)
                                            : Colors.black.withValues(alpha: 0.3),
                                        size: 24,
                                      ),
                                    ),
                            ),
                          ),
                          // Индикатор воспроизведения
                          if (isActive && widget.showPlayIndicator)
                            Positioned(
                              right: 4,
                              bottom: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.black.withValues(alpha: 0.8)
                                      : AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    // Название
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        station.name,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: widget.compact ? 11 : 13,
                          color: isActive
                              ? Colors.black
                              : isDark
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Активный угол
              if (isActive)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppEffects.radiusLg),
                        bottomRight: Radius.circular(AppEffects.radiusMd),
                      ),
                    ),
                    child: const Icon(
                      Icons.equalizer_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = ref.watch(themeProvider.select((s) => s.isDarkTheme));

    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardBackground.withValues(alpha: 0.5)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppEffects.radiusLg),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite_outline_rounded,
            size: 40,
            color: isDark
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.2),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Нет избранных',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Нажмите ⭐ чтобы добавить',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 11,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
