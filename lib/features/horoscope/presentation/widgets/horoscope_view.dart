import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radio_v2/core/theme/app_colors.dart';
import 'package:radio_v2/features/horoscope/presentation/providers/horoscope_provider.dart';
import 'package:radio_v2/features/radio/presentation/providers/player_provider.dart';
import 'package:radio_v2/features/radio/presentation/providers/radio_providers.dart';

class HoroscopeView extends ConsumerWidget {
  const HoroscopeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final horoscopeState = ref.watch(horoscopeProvider);
    final zodiacSigns = ref.watch(zodiacSignsProvider);
    final playerState =
        ref.watch(playerProvider).asData?.value ?? const PlayerState();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            itemCount: zodiacSigns.length,
            itemBuilder: (context, index) {
              final zodiac = zodiacSigns[index];
              final isSelected = zodiac.id == horoscopeState.selectedSign.id;

              return GestureDetector(
                onTap: () =>
                    ref.read(horoscopeProvider.notifier).selectSign(zodiac),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accent
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      zodiac.name,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(36),
              border: const Border(
                left: BorderSide(color: AppColors.accent, width: 10),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_stories,
                      color: AppColors.accent,
                      size: 34,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      horoscopeState.selectedSign.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  _getHoroscopeText(
                    horoscopeState.selectedSign.name,
                    playerState.currentStation?.name ?? 'любимую станцию',
                  ),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.90),
                    fontSize: 16,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                const Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _BuildSmallBadge('Удача: 92%'),
                    _BuildSmallBadge('Энергия: Высокая'),
                    _BuildSmallBadge('Совет дня: Шарф обязателен'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _getHoroscopeText(String zodiacName, String stationName) {
    return 'Сегодня для знака $zodiacName якутское небо сулит удачу в делах. '
        'Вечер идеален для прослушивания $stationName в компании близких. '
        'Звёзды советуют сохранять тепло в сердце и не забывать про шарф!';
  }
}

class _BuildSmallBadge extends StatelessWidget {
  final String label;
  const _BuildSmallBadge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
