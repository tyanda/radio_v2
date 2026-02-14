import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radio_v2/core/theme/app_colors.dart';
import 'package:radio_v2/features/radio/domain/station.dart';
import 'package:radio_v2/features/radio/presentation/providers/player_provider.dart';
import 'package:radio_v2/features/radio/presentation/providers/favorites_provider.dart';
import 'package:radio_v2/features/radio/presentation/providers/radio_providers.dart';
import 'package:radio_v2/widgets/blinking_dot.dart';

class RadioView extends ConsumerWidget {
  const RadioView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stations = ref.watch(stationListProvider);

    return Column(
      children: [
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              BlinkingDot(color: AppColors.error, size: 8.0),
              SizedBox(width: 8),
              Text(
                "В ЭФИРЕ",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            itemCount: stations.length,
            // Use RepaintBoundary to isolate list items for better performance
            addRepaintBoundaries: true,
            itemBuilder: (context, index) {
              return _StationCard(station: stations[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _StationCard extends ConsumerWidget {
  final Station station;

  const _StationCard({required this.station});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Select strictly what we need to minimize rebuilds
    final isPlayingThisStation = ref.watch(
      playerProvider.select((state) {
        final data = state.asData?.value;
        return data?.currentStation?.name == station.name &&
            (data?.isPlaying ?? false);
      }),
    );

    final isCurrentStation = ref.watch(
      playerProvider.select((state) {
        final data = state.asData?.value;
        return data?.currentStation?.name == station.name;
      }),
    );

    final isFavorite = ref.watch(
      favoritesProvider.select((state) {
        return state == station.name;
      }),
    );

    return GestureDetector(
      onTap: () async {
        // Prevent rapid tapping
        ref.read(playerProvider.notifier).playStation(station);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCurrentStation ? AppColors.accent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: Image.asset(
                      station.art,
                      fit: BoxFit.cover,
                      // Optimize image decoding for smaller size
                      cacheWidth: 150,
                      errorBuilder: (_, _, _) => Center(
                        child: Text(
                          station.icon,
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isPlayingThisStation)
                    const Positioned(
                      right: 4,
                      bottom: 4,
                      child: BlinkingDot(color: AppColors.accent, size: 12.0),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    station.desc,
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.white70,
              ),
              onPressed: () => ref
                  .read(favoritesProvider.notifier)
                  .toggleFavorite(station.name),
            ),
            Icon(
              isPlayingThisStation
                  ? Icons.volume_up
                  : Icons.play_arrow_outlined,
              color: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }
}
