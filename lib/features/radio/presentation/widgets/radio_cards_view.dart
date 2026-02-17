import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:radio_v2/features/radio/presentation/providers/player_provider.dart';
import 'package:radio_v2/features/radio/presentation/providers/radio_providers.dart';
import 'package:radio_v2/features/radio/presentation/providers/favorites_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RadioCardsView extends ConsumerWidget {
  const RadioCardsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Получаем список станций напрямую, так как провайдер возвращает List
    final stations = ref.watch(stationListProvider);

    // Получаем состояние плеера. Используем .value для доступа к PlayerState из AsyncValue
    final playerState = ref.watch(playerProvider).value;
    final currentStation = playerState?.currentStation;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Сетка радиостанций
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
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
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
                          ref
                              .read(playerProvider.notifier)
                              .playStation(station);
                        },
                        onLongPress: () {
                          HapticFeedback.mediumImpact();
                          ref
                              .read(favoritesProvider.notifier)
                              .toggleFavorite(station.name);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFFFD700)
                                : const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: isActive
                                  ? Colors.transparent
                                  : Colors.white.withValues(alpha: 0.05),
                            ),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFFD700,
                                      ).withValues(alpha: 0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Stack(
                            children: [
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
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const SizedBox.shrink();
                                          },
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Верхняя часть: изображение и кнопка избранного
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Изображение радиостанции
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: AspectRatio(
                                              aspectRatio: 1,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: isActive
                                                      ? Colors.black.withValues(
                                                          alpha: 0.1,
                                                        )
                                                      : Colors.white.withValues(
                                                          alpha: 0.03,
                                                        ),
                                                ),
                                                child: station.art.isNotEmpty
                                                    ? Image.asset(
                                                        station.art,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) {
                                                              return Container(
                                                                color: isActive
                                                                    ? Colors.black
                                                                          .withValues(
                                                                            alpha:
                                                                                0.1,
                                                                          )
                                                                    : Colors.white
                                                                          .withValues(
                                                                            alpha:
                                                                                0.03,
                                                                          ),
                                                                child: const Icon(
                                                                  Icons.radio,
                                                                  color:
                                                                      Colors.grey,
                                                                  size: 20,
                                                                ),
                                                              );
                                                            },
                                                      )
                                                    : Container(
                                                        color: isActive
                                                            ? Colors.black
                                                                  .withValues(
                                                                    alpha: 0.1,
                                                                  )
                                                            : Colors.white
                                                                  .withValues(
                                                                    alpha: 0.03,
                                                                  ),
                                                        child: const Icon(
                                                          Icons.radio,
                                                          color: Colors.grey,
                                                          size: 20,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Кнопка избранного
                                        GestureDetector(
                                          onTap: () {
                                            HapticFeedback.mediumImpact();
                                            ref
                                                .read(
                                                  favoritesProvider.notifier,
                                                )
                                                .toggleFavorite(station.name);
                                          },
                                          child: Icon(
                                            isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            size: 20,
                                            color: isFavorite
                                                ? (isActive
                                                      ? Colors.red
                                                      : const Color(0xFFFFD700))
                                                : (isActive
                                                      ? Colors.black45
                                                      : Colors.white24),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          station.name,
                                          style: TextStyle(
                                            color: isActive
                                                ? Colors.black
                                                : Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          station.desc,
                                          style: TextStyle(
                                            color: isActive
                                                ? Colors.black.withValues(
                                                    alpha: 0.6,
                                                  )
                                                : Colors.white38,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
