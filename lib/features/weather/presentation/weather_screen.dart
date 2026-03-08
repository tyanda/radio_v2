import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:sakha_live/widgets/scroll_scale_card.dart';
import 'package:sakha_live/core/utils/responsive_utils.dart';
import 'package:sakha_live/core/utils/snackbar_helper.dart';
import 'package:sakha_live/core/design/design.dart';
import 'package:sakha_live/core/design/app_constants.dart';
import 'package:sakha_live/core/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../models/weather_model.dart';

class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Инициализация автообновления данных
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoRefresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Обновление при возобновлении работы приложения
    if (state == AppLifecycleState.resumed) {
      ref.read(weatherProvider.notifier).refreshWeather();
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      if (mounted) {
        ref.read(weatherProvider.notifier).refreshWeather();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Требуется для AutomaticKeepAliveClientMixin

    final isDark = ref.watch(
      themeProvider.select((s) => s.value?.isDarkTheme ?? true),
    );
    final weatherAsync = ref.watch(weatherProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(weatherProvider.notifier).refreshWeather(),
      child: weatherAsync.when(
        data: (weatherData) => weatherData != null
            ? _buildWeatherContent(weatherData, isDark)
            : _buildLoadingView(isDark),
        loading: () => _buildLoadingView(isDark),
        error: (err, _) => _buildErrorView(err.toString(), isDark),
      ),
    );
  }

  // Основной контент погоды с горизонтальным списком
  Widget _buildWeatherContent(WeatherData weatherData, bool isDark) {
    final current = weatherData.current;
    final forecastList = weatherData.forecast;
    final theme = Theme.of(context);

    final sunrise = current.sys.sunrise > 0
        ? DateTime.fromMillisecondsSinceEpoch(
            current.sys.sunrise * 1000,
          ).toLocal()
        : DateTime.now();
    final sunset = current.sys.sunset > 0
        ? DateTime.fromMillisecondsSinceEpoch(
            current.sys.sunset * 1000,
          ).toLocal()
        : DateTime.now().add(const Duration(hours: 12));

    final dfTime = DateFormat.Hm('ru');
    final dfDate = DateFormat('EEEE, d MMM', 'ru');

    final isWeb = kIsWeb;
    final horizontalPadding = SakhaFuturism.horizontalMargin;
    final maxCardWidth = isWeb && MediaQuery.of(context).size.width > 840
        ? 680.0
        : double.infinity;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        AppSpacing.lg, // Верхний отступ 16px
        horizontalPadding,
        bottomPlayerHeight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок "Погода"
          Text(
            'Погода',
            style: GoogleFonts.inter(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
              color: isDark
                  ? AppColors.textPrimary
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxCardWidth),
              child: Container(
                padding: EdgeInsets.all(ResponsivePadding.large(context)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      SakhaFuturism.glassFill(isDark, opacity: 0.76),
                      SakhaFuturism.glassFill(isDark, opacity: 0.58),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: SakhaFuturism.glassBorder(
                      isDark,
                      accent: theme.primaryColor,
                    ),
                  ),
                  boxShadow: SakhaFuturism.shadow(
                    isDark,
                    accent: theme.primaryColor,
                    lift: 1.1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              current.name.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              dfDate.format(DateTime.now()),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        _getWeatherIconWithGlow(
                          current.weather[0].main,
                          size: 56,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Цифра температуры
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${current.main.temp.round()}°',
                              style: GoogleFonts.inter(
                                fontSize: 72,
                                fontWeight: FontWeight.w300,
                                color: theme.colorScheme.onSurface,
                                letterSpacing: -2,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                        // Колонка с описанием и ощущением
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12, bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Теперь описание не обрежется, а сожмется
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    current.weather[0].description
                                        .toUpperCase(),
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: theme.primaryColor,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                // Ощущается как... тоже под защитой
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Ощущается как ${current.main.feelsLike.round()}°',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.only(top: 24),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailItem(
                            'ВЕТЕР',
                            '${current.wind.speed.round()} м/с',
                          ),
                          _buildDetailItem(
                            'ВЛАЖНОСТЬ',
                            '${current.main.humidity}%',
                          ),
                          _buildDetailItem(
                            'ДАВЛЕНИЕ',
                            '${current.main.pressure}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxCardWidth),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      SakhaFuturism.glassFill(isDark, opacity: 0.72),
                      SakhaFuturism.glassFill(isDark, opacity: 0.52),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: SakhaFuturism.glassBorder(
                      isDark,
                      accent: theme.primaryColor,
                    ),
                  ),
                  boxShadow: SakhaFuturism.shadow(
                    isDark,
                    accent: theme.primaryColor,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSunInfo('ВОСХОД', dfTime.format(sunrise)),
                    _buildSunInfo('ЗАКАТ', dfTime.format(sunset)),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'ПРОГНОЗ НА НЕДЕЛЮ',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: theme.primaryColor.withValues(alpha: 0.86),
                letterSpacing: 2.4,
              ),
            ),
          ),

          // СПИСОК ПРОГНОЗА
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxCardWidth),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: forecastList.isEmpty ? 0 : 7,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final dayOffset = index + 1;

                  final date = DateTime.now().add(Duration(days: dayOffset));
                  final dayName = DateFormat(
                    'EEEE',
                    'ru',
                  ).format(date).toUpperCase();
                  final shortDayName = DateFormat(
                    'E',
                    'ru',
                  ).format(date).toUpperCase();

                  // Защита от пустого списка прогноза
                  if (forecastList.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final forecastForDay = forecastList.firstWhere(
                    (element) {
                      final elementDate = DateTime.fromMillisecondsSinceEpoch(
                        element.dt * 1000,
                      );
                      return elementDate.day == date.day &&
                          elementDate.month == date.month &&
                          elementDate.year == date.year;
                    },
                    orElse: () {
                      // Защита от выхода за границы списка
                      final safeIndex = dayOffset < forecastList.length
                          ? dayOffset
                          : forecastList.length - 1;
                      return forecastList[safeIndex];
                    },
                  );

                  final tempMax = forecastForDay.main.temp.round();
                  final tempMin = forecastForDay.main.tempMin.round();

                  return ScrollScaleCard(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWeb ? 16 : 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            SakhaFuturism.glassFill(isDark, opacity: 0.74),
                            SakhaFuturism.glassFill(isDark, opacity: 0.54),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: SakhaFuturism.glassBorder(
                            isDark,
                            accent: theme.primaryColor,
                          ),
                        ),
                        boxShadow: SakhaFuturism.shadow(
                          isDark,
                          accent: theme.primaryColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Слот 1: Короткое название (ПН, ВТ) — фиксированная ширина
                          SizedBox(
                            width: 35.0,
                            child: Text(
                              shortDayName,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Слот 2: Полное название — теперь оно сжимается, если не влезает
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                dayName,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Слот 3: Иконка и температура — зафиксированы справа
                          _getWeatherIcon(forecastForDay.weather[0].main),
                          const SizedBox(width: 12),
                          // Минимальная температура
                          SizedBox(
                            width: 38.0,
                            child: Text(
                              '$tempMin°',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Максимальная температура
                          SizedBox(
                            width: 38.0,
                            child: Text(
                              '$tempMax°',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Вспомогательный виджет для деталей в главной карточке
  Widget _buildDetailItem(String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // Возвращает иконку в зависимости от состояния погоды
  Widget _getWeatherIcon(String main, {double size = 28}) {
    final theme = Theme.of(context);
    IconData iconData;
    switch (main.toLowerCase()) {
      case 'clear':
        iconData = Icons.wb_sunny_outlined;
        break;
      case 'clouds':
        iconData = Icons.wb_cloudy_outlined;
        break;
      case 'rain':
        iconData = Icons.umbrella_outlined;
        break;
      case 'snow':
        iconData = Icons.ac_unit_outlined;
        break;
      default:
        iconData = Icons.wb_cloudy_outlined;
    }
    return Icon(iconData, color: theme.primaryColor, size: size);
  }

  // Возвращает иконку с мягким внешним свечением
  Widget _getWeatherIconWithGlow(String main, {double size = 28}) {
    final theme = Theme.of(context);
    IconData iconData;
    switch (main.toLowerCase()) {
      case 'clear':
        iconData = Icons.wb_sunny_outlined;
        break;
      case 'clouds':
        iconData = Icons.wb_cloudy_outlined;
        break;
      case 'rain':
        iconData = Icons.umbrella_outlined;
        break;
      case 'snow':
        iconData = Icons.ac_unit_outlined;
        break;
      default:
        iconData = Icons.wb_cloudy_outlined;
    }
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Icon(iconData, color: theme.primaryColor, size: size),
    );
  }

  Widget _buildSunInfo(String label, String time) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          time,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingView(bool isDark) {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).primaryColor,
        backgroundColor: isDark
            ? AppColors.cardBackground
            : AppColors.backgroundLight,
      ),
    );
  }

  Widget _buildErrorView(String error, bool isDark) {
    final theme = Theme.of(context);

    // Показываем snackbar с ошибкой
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        SnackbarHelper.showError(
          context: context,
          message: error.split(': ').last,
        );
      }
    });

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_outlined, color: theme.primaryColor, size: 48),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).error_network,
            style: GoogleFonts.inter(
              color: isDark
                  ? AppColors.textPrimary
                  : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () =>
                ref.read(weatherProvider.notifier).refreshWeather(),
            style: FilledButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.black,
            ),
            child: Text(
              AppLocalizations.of(context).retry,
              style: GoogleFonts.inter(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
