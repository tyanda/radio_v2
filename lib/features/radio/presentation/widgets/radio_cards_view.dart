import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:radio_v2/core/theme/app_colors.dart';
import 'package:radio_v2/core/theme/figma_design.dart';
import 'package:radio_v2/features/radio/presentation/providers/player_provider.dart';
import 'package:radio_v2/features/radio/presentation/providers/radio_providers.dart';
import 'package:radio_v2/features/radio/presentation/providers/favorites_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RadioCardsView extends ConsumerWidget {
  const RadioCardsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stations = ref.watch(stationListProvider);
    final playerState = ref.watch(playerProvider).value;
    final currentStation = playerState?.currentStation;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (stations.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: FigmaDesign.gridSpacing,
                  mainAxisSpacing: FigmaDesign.gridSpacing,
                  childAspectRatio: FigmaDesign.cardWidth / FigmaDesign.cardHeight,
                ),
                itemCount: stations.length,
                itemBuilder: (context, index) {
                  final station = stations[index];
                  final bool isActive = currentStation?.id == station.id;

                  return Consumer(
                    builder: (context, ref, child) {
                      final isFavorite = ref.watch(
                        favoritesProvider.select(
                          (state) => state == station.name,
                        ),
                      );

                      return GestureDetector(
                        onTap: () {
                          ref.read(playerProvider.notifier).playStation(station);
                        },
                        onLongPress: () {
                          HapticFeedback.mediumImpact();
                          ref.read(favoritesProvider.notifier).toggleFavorite(station.name);
                        },
                        child: _RadioCard(
                          station: station,
                          isActive: isActive,
                          isFavorite: isFavorite,
                          onFavoriteToggle: () {
                            HapticFeedback.mediumImpact();
                            ref.read(favoritesProvider.notifier).toggleFavorite(station.name);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _RadioCard extends StatelessWidget {
  final dynamic station;
  final bool isActive;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const _RadioCard({
    required this.station,
    required this.isActive,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: FigmaDesign.cardWidth,
      height: FigmaDesign.cardHeight,
      decoration: BoxDecoration(
        color: isActive ? AppColors.accent : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(FigmaDesign.cardRadius),
        border: Border.all(
          color: isActive ? Colors.transparent : Colors.white.withValues(alpha: 0.05),
        ),
        boxShadow: isActive
            ? FigmaDesign.cardActiveShadow
            : FigmaDesign.cardShadow,
      ),
      child: Stack(
        children: [
          // Иконка избранного
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: onFavoriteToggle,
              child: SvgPicture.asset(
                'assets/icon/Icon - Heart.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  isFavorite ? const Color(0xFFFF0000) : Colors.white.withValues(alpha: 0.3),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          // Анимация для активной станции
          if (isActive)
            Positioned(
              right: -5,
              bottom: -5,
              child: Opacity(
                opacity: 0.45,
                child: Lottie.network(
                  'https://lottie.host/8e89f648-7d43-4177-8742-99079f53526c/rRzYqXlXjU.json',
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Частота
                Text(
                  station.frequency ?? '',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: FigmaDesign.fontSizeStationFrequency,
                    color: isActive ? Colors.white : const Color(0xFF808080),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Название станции
                Text(
                  station.name,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: FigmaDesign.fontSizeStationName,
                    color: isActive ? const Color(0xFF2A2A2A) : const Color(0xFFB6B6B6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                // Изображение
                Container(
                  width: double.infinity,
                  height: 79,
                  decoration: BoxDecoration(
                    color: const Color(0xFF000000),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: station.art.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            station.art,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.radio,
                                color: Colors.grey,
                                size: 20,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.radio,
                          color: Colors.grey,
                          size: 20,
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
