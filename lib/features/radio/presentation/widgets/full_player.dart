import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radio_v2/core/design/app_colors.dart';
import 'package:radio_v2/core/design/figma_design.dart';
import 'package:radio_v2/features/radio/domain/station.dart';
import 'package:radio_v2/features/radio/presentation/providers/player_provider.dart';
import 'package:radio_v2/core/providers/radio_providers.dart';

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
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
      height: FigmaDesign.fullPlayerHeight,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(FigmaDesign.cardRadius),
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Обложка альбома (107x93 по Figma)
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: FigmaDesign.fullPlayerArtWidth,
                    height: FigmaDesign.fullPlayerArtHeight,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      currentStation.art,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade800,
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white54,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Информация о станции и управление
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      // Название станции
                      Text(
                        currentStation.name,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: FigmaDesign.fontSizeFullPlayerTitle,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Статус
                      Text(
                        playerState.isPlaying ? "ПРЯМОЙ ЭФИР" : "ПАУЗА",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: playerState.isPlaying
                              ? AppColors.accent
                              : Colors.white60,
                          fontSize: FigmaDesign.fontSizeMiniPlayerStatus,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Кнопка Play/Pause (58x58 по Figma)
                      GestureDetector(
                        onTap: () {
                          if (playerState.isPlaying) {
                            ref.read(playerProvider.notifier).stop();
                          } else {
                            ref
                                .read(playerProvider.notifier)
                                .playStation(currentStation);
                          }
                        },
                        child: Container(
                          width: FigmaDesign.fullPlayerButtonSize,
                          height: FigmaDesign.fullPlayerButtonSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            playerState.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.black,
                            size: 32,
                          ),
                        ),
                      ),
                      const Spacer(),
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
}
