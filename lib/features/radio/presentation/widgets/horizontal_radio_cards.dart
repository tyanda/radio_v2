import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../../../../core/design/app_constants.dart';
import '../../../../core/providers/radio_providers.dart';
import '../../../../core/providers.dart';
import '../providers/player_provider.dart';
import '../../domain/station.dart';
import 'radio_card_v2.dart';
import 'station_context_menu.dart';

/// Горизонтальный скролл (Stories-стиль)
///
/// Карточки расположены горизонтально с возможностью скролла
class HorizontalRadioCards extends ConsumerStatefulWidget {
  const HorizontalRadioCards({super.key});

  @override
  ConsumerState<HorizontalRadioCards> createState() =>
      _HorizontalRadioCardsState();
}

class _HorizontalRadioCardsState extends ConsumerState<HorizontalRadioCards> {
  final ScrollController _scrollController = ScrollController();
  int? _lastActiveIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveStation();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActiveStation() {
    if (!_scrollController.hasClients) return;

    final playerState = ref.read(playerProvider).value;
    final stations = ref.read(stationListProvider);
    final currentStation = playerState?.currentStation;

    if (currentStation == null || stations.isEmpty) return;

    final activeIndex = stations.indexWhere((s) => s.id == currentStation.id);
    if (activeIndex < 0 || activeIndex == _lastActiveIndex) return;

    _lastActiveIndex = activeIndex;

    final cardWidth = 160.0 + AppSpacing.lg; // ширина карточки + отступ
    final targetOffset = (activeIndex * cardWidth) - (cardWidth / 2);

    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final allStations = ref.watch(stationListProvider);
    final playerAsync = ref.watch(playerProvider);
    final currentStation = playerAsync.value?.currentStation;
    final favoritesState = ref.watch(favoritesProvider);
    final favoriteNames = favoritesState.favoriteStationNames;

    // Авто-скролл к активной станции
    final isActiveChanged =
        currentStation != null &&
        _lastActiveIndex !=
            allStations.indexWhere((s) => s.id == currentStation.id);
    if (isActiveChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToActiveStation();
      });
    }

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        bottomPlayerHeight,
      ),
      child: Row(
        children: allStations.map((station) {
          final isActive = currentStation?.id == station.id;
          final isFavorite = favoriteNames.contains(station.name);

          return Padding(
            padding: EdgeInsets.only(right: AppSpacing.lg),
            child: SizedBox(
              width: 160,
              height: 240,
              child: RadioCardV2(
                station: station,
                isActive: isActive,
                isFavorite: isFavorite,
                viewType: ViewType.horizontal,
                onTap: () {
                  ref.read(playerProvider.notifier).playStation(station);
                },
                onFavoriteTap: () {
                  ref
                      .read(favoritesProvider.notifier)
                      .toggleFavorite(station.name);
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
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// List view для радиостанций
class ListRadioCards extends ConsumerStatefulWidget {
  const ListRadioCards({super.key});

  @override
  ConsumerState<ListRadioCards> createState() => _ListRadioCardsState();
}

class _ListRadioCardsState extends ConsumerState<ListRadioCards> {
  @override
  Widget build(BuildContext context) {
    final allStations = ref.watch(stationListProvider);
    final playerAsync = ref.watch(playerProvider);
    final currentStation = playerAsync.value?.currentStation;
    final favoritesState = ref.watch(favoritesProvider);
    final favoriteNames = favoritesState.favoriteStationNames;
    final isDark = ref.watch(themeProvider.select((s) => s.isDarkTheme));
    final accentColor = Theme.of(context).primaryColor;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        bottomPlayerHeight,
      ),
      child: Column(
        children: allStations.map((station) {
          final isActive = currentStation?.id == station.id;
          final isFavorite = favoriteNames.contains(station.name);

          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: _buildListCard(
              station: station,
              isActive: isActive,
              isFavorite: isFavorite,
              isDark: isDark,
              accentColor: accentColor,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListCard({
    required Station station,
    required bool isActive,
    required bool isFavorite,
    required bool isDark,
    required Color accentColor,
  }) {
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
                    // Название + LIVE бейдж
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

                    // Частота + описание
                    Row(
                      children: [
                        if (station.frequency.isNotEmpty &&
                            station.frequency != 'Online') ...[
                          Text(
                            station.frequency,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                              color: isActive
                                  ? Colors.black.withValues(alpha: 0.7)
                                  : AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            '•',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: isActive
                                  ? Colors.black.withValues(alpha: 0.5)
                                  : AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: AppSpacing.xs),
                        ],
                        Expanded(
                          child: Text(
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
                        ),
                      ],
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
}
