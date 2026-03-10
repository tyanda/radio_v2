import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sakha_live/core/design/design.dart';
import 'package:sakha_live/core/design/app_constants.dart';
import 'package:sakha_live/features/horoscope/domain/zodiac_sign.dart';
import 'package:sakha_live/core/providers.dart';
import 'package:sakha_live/widgets/scroll_scale_card.dart';
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
  int? _lastSelectedIndex; // Для предотвращения перезапуска анимации

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
    final isDark = ref.watch(
      themeProvider.select((s) => s.value?.isDarkTheme ?? true),
    );

    // Адаптивная сетка: 4 колонки на больших экранах, 3 на малых
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 360 ? 3 : 4;
    // Увеличенный childAspectRatio для более крупных тапов (минимум 48x48)
    final childAspectRatio = screenWidth < 360 ? 1.1 : 1.0;

    // Перезапуск анимации только при смене знака зодиака ИЛИ нового текста
    final currentHoroscopeText = horoscopeState.horoscopeData?.text;
    final hasNewText =
        currentHoroscopeText != null &&
        currentHoroscopeText != _lastHoroscopeText;
    final hasNewSign = _selectedIndex != _lastSelectedIndex;

    if (hasNewText || hasNewSign) {
      _lastHoroscopeText = currentHoroscopeText;
      _lastSelectedIndex = _selectedIndex;
      _animationController.forward(from: 0);
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        SakhaFuturism.horizontalMargin,
        AppSpacing.lg, // Верхний отступ 16px
        SakhaFuturism.horizontalMargin,
        bottomPlayerHeight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок "Гороскоп"
          Text(
            'Гороскоп',
            style: GoogleFonts.inter(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
              color: isDark
                  ? AppColors.textPrimary
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Подсказка "ВЫБЕРИТЕ ЗНАК"
          Text(
            AppLocalizations.of(context).select_zodiac_sign.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: isDark ? AppColors.textTertiary : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: zodiacSigns.length,
            itemBuilder: (context, index) {
              final zodiac = zodiacSigns[index];
              final isSelected = _selectedIndex == index;

              return ScrollScaleCard(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedIndex = index;
                  });
                  ref.read(horoscopeProvider.notifier).selectSign(zodiac);
                },
                child: Semantics(
                  label: 'Знак зодиака ${zodiac.name}',
                  hint: 'Нажмите для просмотра гороскопа',
                  selected: isSelected,
                  child: _AnimatedCard(
                    index: index,
                    controller: _animationController,
                    child: _buildZodiacMiniCard(zodiac, isSelected),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24),
          // Карточка с текстом гороскопа
          _buildPredictionCard(horoscopeState),
        ],
      ),
    );
  }

  /// Виджет карточки знака зодиака в сетке
  Widget _buildZodiacMiniCard(ZodiacSign zodiac, bool isSelected) {
    final isDark = ref.watch(
      themeProvider.select((s) => s.value?.isDarkTheme ?? true),
    );
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSelected
              ? [theme.primaryColor, theme.primaryColor.withValues(alpha: 0.78)]
              : [
                  SakhaFuturism.glassFill(isDark, opacity: 0.74),
                  SakhaFuturism.glassFill(isDark, opacity: 0.56),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected
              ? theme.primaryColor
              : SakhaFuturism.glassBorder(isDark, accent: theme.primaryColor),
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: SakhaFuturism.shadow(
          isDark,
          accent: theme.primaryColor,
          lift: isSelected ? 1.05 : 1,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              zodiac.name,
              style: GoogleFonts.inter(
                color: isSelected
                    ? Colors.black
                    : (isDark ? AppColors.textPrimary : AppColors.textName),
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
    final isDark = ref.watch(
      themeProvider.select((s) => s.value?.isDarkTheme ?? true),
    );
    final theme = Theme.of(context);
    final textScaler = MediaQuery.textScalerOf(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SakhaFuturism.glassFill(isDark, opacity: 0.76),
            SakhaFuturism.glassFill(isDark, opacity: 0.58),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: SakhaFuturism.glassBorder(isDark, accent: theme.primaryColor),
        ),
        boxShadow: SakhaFuturism.shadow(
          isDark,
          accent: theme.primaryColor,
          lift: 1.08,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${zodiacSigns.elementAtOrNull(_selectedIndex)?.name ?? ''} на сегодня',
                  style:
                      GoogleFonts.inter(
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.textName,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ).apply(
                        fontSizeFactor: textScaler.scale(1.0).clamp(0.8, 1.2),
                      ),
                ),
              ),
              if (horoscopeState.isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          if (horoscopeState.isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text(
                  AppLocalizations.of(context).loading_horoscope,
                  style:
                      GoogleFonts.inter(
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.textName,
                        fontSize: 16,
                      ).apply(
                        fontSizeFactor: textScaler.scale(1.0).clamp(0.8, 1.2),
                      ),
                ),
              ),
            )
          else if (horoscopeState.errorMessage != null)
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text(
                AppLocalizations.of(
                  context,
                ).error_loading_horoscope(horoscopeState.errorMessage ?? ''),
                style: GoogleFonts.inter(
                  color: theme.colorScheme.error,
                  fontSize: 16,
                ).apply(fontSizeFactor: textScaler.scale(1.0).clamp(0.8, 1.2)),
              ),
            )
          else if (horoscopeState.horoscopeData != null)
            horoscopeState.horoscopeData!.text.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      AppLocalizations.of(context).horoscope_not_found,
                      style:
                          GoogleFonts.inter(
                            color: isDark
                                ? AppColors.textTertiary
                                : AppColors.textSecondary,
                            fontSize: 16,
                          ).apply(
                            fontSizeFactor: textScaler
                                .scale(1.0)
                                .clamp(0.8, 1.2),
                          ),
                    ),
                  )
                : Text(
                    horoscopeState.horoscopeData!.text,
                    style:
                        GoogleFonts.inter(
                          color: isDark
                              ? AppColors.textPrimary
                              : AppColors.textName,
                          fontSize: 16,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ).apply(
                          fontSizeFactor: textScaler.scale(1.0).clamp(0.8, 1.2),
                        ),
                    maxLines: 12,
                    overflow: TextOverflow.ellipsis,
                  )
          else
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text(
                AppLocalizations.of(context).horoscope_unavailable,
                style: GoogleFonts.inter(
                  color: isDark ? AppColors.textPrimary : AppColors.textName,
                  fontSize: 16,
                ).apply(fontSizeFactor: textScaler.scale(1.0).clamp(0.8, 1.2)),
              ),
            ),
          SizedBox(height: AppSpacing.lg),
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
    final isDark = ref.watch(
      themeProvider.select((s) => s.value?.isDarkTheme ?? true),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: isDark ? AppColors.textPrimary : AppColors.textName,
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
    final beginTime = delay.clamp(0.0, 0.8);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final animationValue = controller.value;

        // Вычисляем прогресс с защитой от division by zero
        final progress = beginTime >= 1.0
            ? 1.0
            : ((animationValue - beginTime) / (1.0 - beginTime)).clamp(
                0.0,
                1.0,
              );

        // Применяем кривую анимации
        final curvedValue = Curves.easeOutCubic.transform(progress);

        return Transform.translate(
          offset: Offset(0, 30 * (1 - curvedValue)),
          child: Opacity(opacity: curvedValue, child: child),
        );
      },
      child: child,
    );
  }
}
