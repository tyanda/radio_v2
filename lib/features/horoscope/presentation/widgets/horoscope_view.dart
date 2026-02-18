import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radio_v2/core/theme/app_colors.dart';
import 'package:radio_v2/features/horoscope/domain/zodiac_sign.dart';
import 'package:radio_v2/features/horoscope/presentation/providers/horoscope_provider.dart';

class HoroscopeView extends ConsumerStatefulWidget {
  const HoroscopeView({super.key});

  @override
  ConsumerState<HoroscopeView> createState() => _HoroscopeViewState();
}

class _HoroscopeViewState extends ConsumerState<HoroscopeView> {
  @override
  Widget build(BuildContext context) {
    final horoscopeState = ref.watch(horoscopeProvider);
    final zodiacSigns = ZodiacSign.all;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Сетка знаков зодиака
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.95,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          // Карточка с текстом гороскопа на сегодня
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
                    Expanded(
                      child: Text(
                        '${horoscopeState.selectedSign.name} на сегодня',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (horoscopeState.isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.accent,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                if (horoscopeState.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Загрузка гороскопа...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  )
                else if (horoscopeState.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Ошибка загрузки гороскопа: ${horoscopeState.errorMessage}',
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  )
                else if (horoscopeState.horoscopeData != null)
                  horoscopeState.horoscopeData!.text.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Гороскоп не найден. Попробуйте другой знак.',
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      )
                    : Text(
                        horoscopeState.horoscopeData!.text,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.90),
                          fontSize: 16,
                          height: 1.6,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                else
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Гороскоп временно недоступен',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _BuildSmallBadge('Прогноз на сегодня'),
                    const SizedBox(width: 8),
                    if (horoscopeState.horoscopeData?.source != null)
                      _BuildSmallBadge(
                        horoscopeState.horoscopeData!.source!,
                      ),
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
