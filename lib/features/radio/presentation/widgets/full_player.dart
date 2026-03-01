import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design/design.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/providers/radio_providers.dart';
import '../../domain/station.dart';
import '../providers/player_provider.dart';
import '../../../../../l10n/app_localizations.dart';

class FullPlayer extends ConsumerWidget {
  const FullPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(playerProvider);
    final stations = ref.watch(stationListProvider);

    return playerAsync.when(
      data: (playerState) {
        final currentStation = playerState.currentStation ?? stations.first;
        return _buildPlayerUI(context, ref, playerState, currentStation);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildPlayerUI(
    BuildContext context,
    WidgetRef ref,
    PlayerState playerState,
    Station currentStation,
  ) {
    // Используем обложку из метаданных или картинку станции
    final albumArtUrl = playerState.albumArt;
    final hasAlbumArt = albumArtUrl != null && albumArtUrl.isNotEmpty;

    return Container(
      margin: EdgeInsets.fromLTRB(
        ResponsivePadding.medium(context),
        0,
        ResponsivePadding.medium(context),
        AppSpacing.md,
      ),
      height: 136,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppEffects.radiusXl),
        border: Border.all(color: AppColors.cardBackground, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 28,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(ResponsivePadding.medium(context)),
            child: Row(
              children: [
                // Обложка альбома (107x93 по Figma)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppEffects.radiusLg),
                  child: Container(
                    width: 107,
                    height: 93,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: hasAlbumArt
                        ? Image.network(
                            albumArtUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return _buildLoadingContainer(
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded
                                            .toDouble() /
                                        loadingProgress.expectedTotalBytes!
                                            .toDouble()
                                    : null,
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback на картинку станции
                              return _buildStationImage(currentStation);
                            },
                          )
                        : _buildStationImage(currentStation),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                // Информация о станции и кнопки
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentStation.name,
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        AppLocalizations.of(context).live_broadcast,
                        style: GoogleFonts.inter(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildIconButton(
                            context,
                            icon: playerState.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            onPressed: () {
                              if (playerState.isPlaying) {
                                ref.read(playerProvider.notifier).stop();
                              } else {
                                ref
                                    .read(playerProvider.notifier)
                                    .playStation(currentStation);
                              }
                            },
                            isPrimary: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: isPrimary ? 58 : 40,
          height: isPrimary ? 58 : 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPrimary ? AppColors.primary : AppColors.surfaceVariant,
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color: isPrimary ? Colors.black : AppColors.textPrimary,
            size: isPrimary ? 28 : 20,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingContainer(double? progress) {
    return Container(
      color: AppColors.cardBackground,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            value: progress,
          ),
        ),
      ),
    );
  }

  Widget _buildStationImage(Station station) {
    if (station.art.isNotEmpty) {
      return Image.asset(
        station.art,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.cardBackground,
            child: const Icon(
              Icons.music_note,
              color: Colors.white54,
              size: 24,
            ),
          );
        },
      );
    }
    return Container(
      color: AppColors.cardBackground,
      child: const Icon(
        Icons.music_note,
        color: Colors.white54,
        size: 24,
      ),
    );
  }
}
