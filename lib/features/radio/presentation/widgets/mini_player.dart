import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radio_v2/core/theme/app_colors.dart';
import 'package:radio_v2/features/radio/domain/station.dart';
import 'package:radio_v2/features/radio/presentation/providers/player_provider.dart';
import 'package:radio_v2/features/radio/presentation/providers/radio_providers.dart';
import 'package:radio_v2/widgets/equalizer_animation.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Слайдер громкости (анимация)
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 280),
          crossFadeState: playerState.showVolumeSlider
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.volume_mute_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                  Expanded(
                    child: Slider(
                      value: playerState.volume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 20,
                      activeColor: AppColors.accent,
                      inactiveColor: Colors.white24,
                      thumbColor: AppColors.accent,
                      onChanged: (v) =>
                          ref.read(playerProvider.notifier).setVolume(v),
                    ),
                  ),
                  const Icon(
                    Icons.volume_up_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Основной контейнер мини-плеера
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: const Color(0xFF121212).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 40,
                offset: const Offset(0, 20),
                spreadRadius: 10,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              // Обложка альбома
              GestureDetector(
                onTap: () =>
                    ref.read(playerProvider.notifier).toggleVolumeSlider(),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 52,
                        height: 52,
                        child: Image.asset(
                          currentStation.art,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.music_note,
                                color: Colors.white54,
                                size: 24,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (playerState.isPlaying)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.black.withValues(alpha: 0.40),
                          ),
                          child: const Center(
                            child: EqualizerAnimation(isActive: true, size: 28),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Информация о станции
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentStation.name,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: -0.5,
                        height: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      playerState.isPlaying ? "ПРЯМОЙ ЭФИР" : "ПАУЗА",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: playerState.isPlaying
                            ? AppColors.accent
                            : Colors.white60,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Кнопка Play/Pause
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
                  width: 52,
                  height: 52,
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
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
