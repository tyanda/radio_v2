import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:radio_v2/widgets/scroll_scale_card.dart';
import 'package:radio_v2/core/providers/weather_provider.dart';
import 'package:radio_v2/core/utils/responsive_utils.dart';
import 'package:radio_v2/core/utils/snackbar_helper.dart';
import 'package:radio_v2/l10n/app_localizations.dart';
import 'package:radio_v2/features/radio/presentation/providers/player_provider.dart';
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

    final weatherAsync = ref.watch(weatherProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: weatherAsync.when(
        data: (weatherData) => weatherData != null
            ? _buildWeatherContent(weatherData)
            : _buildLoadingView(),
        loading: () => _buildLoadingView(),
        error: (err, _) => _buildErrorView(err.toString()),
      ),
    );
  }

  // Основной контент погоды с горизонтальным списком
  Widget _buildWeatherContent(WeatherData weatherData) {
    final current = weatherData.current;
    final forecastList = weatherData.forecast;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Динамический отступ снизу: больше если плеер виден, меньше если скрыт
    final playerState = ref.watch(playerProvider);
    final playerData = playerState.asData?.value;
    final isPlayerVisible = playerData != null &&
        playerData.currentStation != null &&
        (playerData.isPlaying || playerData.isBuffering);
    final bottomPadding = isPlayerVisible ? 200.0 : 80.0;

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

    // Адаптивность для веба
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = isWeb && screenWidth > 800 ? 80.0 : 16.0;
    final maxCardWidth = isWeb && screenWidth > 600 ? 600.0 : double.infinity;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        16,
        horizontalPadding,
        bottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ГЛАВНЫЙ ВИДЖЕТ (КАРТОЧКА)
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxCardWidth),
              child: Container(
                padding: EdgeInsets.all(ResponsivePadding.large(context)),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.05),
                      blurRadius: isDark ? 20 : 10,
                      offset: const Offset(0, 10),
                    ),
                  ],
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
                        Text(
                          '${current.main.temp.round()}°',
                          style: GoogleFonts.inter(
                            fontSize: 110,
                            fontWeight: FontWeight.w300,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -4,
                            height: 1.0,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 12,
                              bottom: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  current.weather[0].description.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: theme.primaryColor,
                                    letterSpacing: 1,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ощущается как ${current.main.feelsLike.round()}°',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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

          const SizedBox(height: 20),

          // Тонкий разделитель
          Divider(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.12)
                : theme.dividerColor, 
            height: 1,
          ),

          // БЛОК ВОСХОДА/ЗАКАТА
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSunInfo('ВОСХОД', dfTime.format(sunrise)),
                _buildSunInfo('ЗАКАТ', dfTime.format(sunset)),
              ],
            ),
          ),

          // ЗАГОЛОВОК
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              'ПРОГНОЗ НА НЕДЕЛЮ',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 2.0,
              ),
            ),
          ),

          // СПИСОК ПРОГНОЗА
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxCardWidth),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 7,
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

                  final forecastForDay = forecastList.firstWhere(
                    (element) {
                      final elementDate = DateTime.fromMillisecondsSinceEpoch(
                        element.dt * 1000,
                      );
                      return elementDate.day == date.day &&
                          elementDate.month == date.month &&
                          elementDate.year == date.year;
                    },
                    orElse: () => forecastList.length > dayOffset
                        ? forecastList[dayOffset]
                        : forecastList.isNotEmpty
                        ? forecastList[forecastList.length - 1]
                        : forecastList.first,
                  );

                  final tempMax = forecastForDay.main.temp.round();
                  final tempMin = forecastForDay.main.tempMin.round();

                  return ScrollScaleCard(
                    onTap: () {},
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.symmetric(
                        horizontal: isWeb ? 16 : 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark 
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.05),
                        ),
                        boxShadow: isDark ? null : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 45.0,
                            child: Text(
                              shortDayName,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              dayName,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _getWeatherIcon(forecastForDay.weather[0].main),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 35.0,
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
                          SizedBox(
                            width: 35.0,
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
          const SizedBox(height: 40),
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

  Widget _buildLoadingView() {
    return Center(
      child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
    );
  }

  Widget _buildErrorView(String error) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          Icon(
            Icons.wifi_off_outlined,
            color: theme.primaryColor,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).error_network,
            style: GoogleFonts.inter(
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () =>
                ref.read(weatherProvider.notifier).refreshWeather(),
            style: FilledButton.styleFrom(backgroundColor: theme.primaryColor),
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
