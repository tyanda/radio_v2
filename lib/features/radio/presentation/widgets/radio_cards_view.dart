import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radio_v2/features/radio/presentation/providers/player_provider.dart';
import 'package:radio_v2/features/radio/presentation/providers/radio_providers.dart';
import 'package:radio_v2/features/radio/presentation/providers/favorites_provider.dart';
import 'package:radio_v2/features/radio/presentation/widgets/vertical_radio_card.dart';
import 'package:radio_v2/widgets/scroll_scale_card.dart';

class RadioCardsView extends ConsumerStatefulWidget {
  const RadioCardsView({super.key});

  @override
  ConsumerState<RadioCardsView> createState() => _RadioCardsViewState();
}

class _RadioCardsViewState extends ConsumerState<RadioCardsView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stations = ref.watch(stationListProvider);
    final playerState = ref.watch(playerProvider).value;
    final currentStation = playerState?.currentStation;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 200),
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
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
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

                      return ScrollScaleCard(
                        onTap: () {
                          ref.read(playerProvider.notifier).playStation(station);
                        },
                        child: _AnimatedCard(
                          index: index,
                          controller: _animationController,
                          child: VerticalRadioCard(
                            station: station,
                            isActive: isActive,
                            isFavorite: isFavorite,
                            onTap: () {
                              ref.read(playerProvider.notifier).playStation(station);
                            },
                            onFavoriteTap: () {
                              ref.read(favoritesProvider.notifier).toggleFavorite(station.name);
                            },
                            onLongPress: () {
                              ref.read(favoritesProvider.notifier).toggleFavorite(station.name);
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
    final delay = index * 0.08;
    final beginTime = delay.clamp(0.0, 1.0);
    final tween = Tween(begin: 0.0, end: 1.0).chain(
      CurveTween(curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final animationValue = controller.value;
        final progress = ((animationValue - beginTime) * (1 / (1 - beginTime))).clamp(0.0, 1.0);
        final value = tween.transform(progress);

        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
