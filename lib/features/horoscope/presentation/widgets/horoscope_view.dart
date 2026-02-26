import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:radio_v2/core/design/figma_design.dart';
import 'package:radio_v2/core/design/app_constants.dart';
import 'package:radio_v2/features/horoscope/domain/zodiac_sign.dart';
import 'package:radio_v2/core/providers/horoscope_provider.dart';
import 'package:radio_v2/widgets/scroll_scale_card.dart';
import 'package:radio_v2/core/utils/responsive_utils.dart';
import '../../../../l10n/app_localizations.dart';

class HoroscopeView extends ConsumerStatefulWidget {
  const HoroscopeView({super.key});

  @override
  ConsumerState<HoroscopeView> createState() => _HoroscopeViewState();
}

class _HoroscopeViewState extends ConsumerState<HoroscopeView>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late AnimationController _animationController;
  int _selectedIndex = 0;
  String? _lastHoroscopeText;

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
    final theme = Theme.of(context);

    final horoscopeState = ref.watch(horoscopeProvider);

    // Перезапуск анимации при изменении текста гороскопа
    final currentHoroscopeText = horoscopeState.horoscopeData?.text;
    if (currentHoroscopeText != null &&
        currentHoroscopeText != _lastHoroscopeText) {
      _lastHoroscopeText = currentHoroscopeText;
      _animationController.forward(from: 0);
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        16.0,
        16,
        16.0,
        kBottomBarTotalHeight,
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).select_zodiac_sign,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 6),
            // Сетка знаков зодиака
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 1.0,
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
            // Карточка с текстом гороскопа
            _buildPredictionCard(horoscopeState),
          ],
        ),
    );
  }

  /// Виджет карточки знака зодиака в сетке
  Widget _buildZodiacMiniCard(ZodiacSign zodiac, bool isSelected) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: isSelected ? theme.primaryColor : theme.cardColor,
        borderRadius: BorderRadius.circular(20), // Slightly rounded for mini cards
        border: Border.all(
          color: isSelected ? theme.primaryColor : (isDark ? Colors.transparent : Colors.black.withValues(alpha: 0.05)),
          width: 2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: theme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : (!isDark ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ] : null),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              zodiac.name,
              style: GoogleFonts.inter(
                color: isSelected ? Colors.black : theme.colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  /// Основная карточка с предсказанием
  Widget _buildPredictionCard(HoroscopeState horoscopeState) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(FigmaDesign.cardRadius),
        border: Border(
          left: BorderSide(color: theme.primaryColor, width: 10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: isDark ? 16 : 10,
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
                  '${zodiacSigns.elementAtOrNull(_selectedIndex)?.name ?? ''} на сегодня',
                  style: GoogleFonts.inter(
                    color: theme.colorScheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (horoscopeState.isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                  ),
                ),
            ],
          ),
          SizedBox(height: ResponsivePadding.medium(context)),
          if (horoscopeState.isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(ResponsivePadding.medium(context)),
                child: Text(
                  AppLocalizations.of(context).loading_horoscope,
                  style: GoogleFonts.inter(
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else if (horoscopeState.errorMessage != null)
            Padding(
              padding: EdgeInsets.all(ResponsivePadding.medium(context)),
              child: Text(
                AppLocalizations.of(context).error_loading_horoscope(
                  horoscopeState.errorMessage ?? '',
                ),
                style: GoogleFonts.inter(
                  color: theme.colorScheme.error,
                  fontSize: 16,
                ),
              ),
            )
          else if (horoscopeState.horoscopeData != null)
            horoscopeState.horoscopeData!.text.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(ResponsivePadding.medium(context)),
                    child: Text(
                      AppLocalizations.of(context).horoscope_not_found,
                      style: GoogleFonts.inter(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 16,
                      ),
                    ),
                  )
                : Text(
                    horoscopeState.horoscopeData!.text,
                    style: GoogleFonts.inter(
                      color: theme.colorScheme.onSurface,
                      fontSize: 16,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  )
          else
            Padding(
              padding: EdgeInsets.all(ResponsivePadding.medium(context)),
              child: Text(
                AppLocalizations.of(context).horoscope_unavailable,
                style: GoogleFonts.inter(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildSmallBadge('Прогноз на сегодня'),
              const SizedBox(width: 8),
              if (horoscopeState.horoscopeData?.source != null)
                _buildSmallBadge(horoscopeState.horoscopeData!.source!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBadge(String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: theme.colorScheme.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w700,
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
    final tween = Tween(
      begin: 0.0,
      end: 1.0,
    ).chain(CurveTween(curve: Curves.easeOutCubic));

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final animationValue = controller.value;
        final progress = ((animationValue - beginTime) * (1 / (1 - beginTime)))
            .clamp(0.0, 1.0);
        final value = tween.transform(progress);

        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}
