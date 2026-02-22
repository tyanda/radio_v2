import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radio_v2/core/theme/app_colors.dart';
import 'package:radio_v2/features/horoscope/domain/zodiac_sign.dart';
import 'package:radio_v2/features/horoscope/presentation/providers/horoscope_provider.dart';
import 'package:radio_v2/widgets/scroll_scale_card.dart';

class HoroscopeView extends ConsumerStatefulWidget {
  const HoroscopeView({super.key});

  @override
  ConsumerState<HoroscopeView> createState() => _HoroscopeViewState();
}

class _HoroscopeViewState extends ConsumerState<HoroscopeView>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late AnimationController _animationController;
  int _selectedIndex = 0;

  final List<ZodiacSign> zodiacSigns = ZodiacSign.all;

  @override
  bool get wantKeepAlive => true;

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
    super.build(context);

    final horoscopeState = ref.watch(horoscopeProvider);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'ВЫБЕРИТЕ ЗНАК',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.secondaryText,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Сетка знаков зодиака
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: zodiacSigns.length,
              itemBuilder: (context, index) {
                final zodiac = zodiacSigns[index];
                final isSelected = _selectedIndex == index;

                return ScrollScaleCard(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                    ref.read(horoscopeProvider.notifier).selectSign(zodiac);
                  },
                  child: _AnimatedCard(
                    index: index,
                    controller: _animationController,
                    child: _buildZodiacMiniCard(zodiac, isSelected),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            // Карточка с текстом гороскопа
            _buildPredictionCard(horoscopeState),
          ],
        ),
      ),
    );
  }

  /// Виджет карточки знака зодиака в сетке
  Widget _buildZodiacMiniCard(ZodiacSign zodiac, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accent : AppColors.cardBackground,
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
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          zodiac.name,
          style: TextStyle(
            fontFamily: 'Inter',
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  /// Основная карточка с предсказанием
  Widget _buildPredictionCard(HoroscopeState horoscopeState) {
    return Container(
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
              Expanded(
                child: Text(
                  '${zodiacSigns[_selectedIndex].name} на сегодня',
                  style: const TextStyle(
                    fontFamily: 'Inter',
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
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else if (horoscopeState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Ошибка загрузки гороскопа: ${horoscopeState.errorMessage}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.error,
                  fontSize: 16,
                ),
              ),
            )
          else if (horoscopeState.horoscopeData != null)
            horoscopeState.horoscopeData!.text.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Гороскоп не найден. Попробуйте другой знак.',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  )
                : Text(
                    horoscopeState.horoscopeData!.text,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  )
          else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Гороскоп временно недоступен',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white,
                  fontSize: 16,
                ),
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

class _BuildSmallBadge extends StatelessWidget {
  final String label;
  const _BuildSmallBadge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
