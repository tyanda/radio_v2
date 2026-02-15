import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../providers/weather_provider.dart';
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

  // Константы дизайна, соответствующие вашему MyApp (main.dart)
  static const Color accentColor = Color(0xFFFFD700); // Золотой
  static const Color backgroundColor = Color(0xFF000000); // Чистый черный
  static const Color cardBackgroundColor = Color(0xFF111111); // Глубокий серый для карточек
  static const Color primaryTextColor = Colors.white;
  static const Color secondaryTextColor = Color(0xFFA3A3A3);

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
      backgroundColor: backgroundColor,
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

    final sunrise = current.sys.sunrise > 0
        ? DateTime.fromMillisecondsSinceEpoch(current.sys.sunrise * 1000).toLocal()
        : DateTime.now();
    final sunset = current.sys.sunset > 0
        ? DateTime.fromMillisecondsSinceEpoch(current.sys.sunset * 1000).toLocal()
        : DateTime.now().add(const Duration(hours: 12));
    
    final dfTime = DateFormat.Hm('ru');
    final dfDate = DateFormat('EEEE, d MMM', 'ru');

    return RefreshIndicator(
      color: backgroundColor,
      backgroundColor: accentColor,
      onRefresh: () async {
        await ref.read(weatherProvider.notifier).refreshWeather();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),
            
            // ОБНОВЛЕННЫЙ ГЛАВНЫЙ ВИДЖЕТ (КАРТОЧКА)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
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
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: primaryTextColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            dfDate.format(DateTime.now()),
                            style: const TextStyle(
                              fontSize: 14,
                              color: secondaryTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      _getWeatherIcon(current.weather[0].main, size: 48),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${current.main.temp.round()}°',
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w200,
                          color: primaryTextColor,
                          letterSpacing: -4,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              current.weather[0].description.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              'Ощущается как ${current.main.feelsLike.round()}°',
                              style: const TextStyle(
                                fontSize: 12,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
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
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailItem('ВЕТЕР', '${current.wind.speed.round()} м/с'),
                        _buildDetailItem('ВЛАЖНОСТЬ', '${current.main.humidity}%'),
                        _buildDetailItem('ДАВЛЕНИЕ', '${current.main.pressure}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Тонкий разделитель
            Divider(
              color: Colors.white.withValues(alpha: 0.12), 
              height: 1
            ),
            
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
            
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 16),
              child: Text(
                'ПРОГНОЗ ПО ДНЯМ',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: secondaryTextColor,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            
            // ГОРИЗОНТАЛЬНЫЙ СПИСОК КАРТОЧЕК
            SizedBox(
              height: 165,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: forecastList.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final day = forecastList[index];
                  final date = DateTime.fromMillisecondsSinceEpoch(day.dt * 1000);
                  final dayName = DateFormat('E', 'ru').format(date).toUpperCase();

                  return Container(
                    width: 95,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: cardBackgroundColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayName,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _getWeatherIcon(day.weather[0].main),
                        const SizedBox(height: 16),
                        Text(
                          '${day.main.temp.round()}°',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.main.tempMin.round()}°',
                          style: const TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),

            // Кнопка обновления
            Center(
              child: SizedBox(
                width: 160,
                child: FilledButton(
                  onPressed: () => ref.read(weatherProvider.notifier).refreshWeather(),
                  style: FilledButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'ОБНОВИТЬ',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Вспомогательный виджет для деталей в главной карточке
  Widget _buildDetailItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: secondaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
      ],
    );
  }

  // Возвращает желтую иконку в зависимости от состояния погоды
  Widget _getWeatherIcon(String main, {double size = 28}) {
    IconData iconData;
    switch (main.toLowerCase()) {
      case 'clear': iconData = Icons.wb_sunny_outlined; break;
      case 'clouds': iconData = Icons.wb_cloudy_outlined; break;
      case 'rain': iconData = Icons.umbrella_outlined; break;
      case 'snow': iconData = Icons.ac_unit_outlined; break;
      default: iconData = Icons.wb_cloudy_outlined;
    }
    return Icon(iconData, color: accentColor, size: size);
  }

  Widget _buildSunInfo(String label, String time) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: secondaryTextColor,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          time,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: primaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(color: accentColor),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_outlined, color: accentColor, size: 48),
          const SizedBox(height: 16),
          const Text(
            'ОШИБКА СЕТИ',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => ref.read(weatherProvider.notifier).refreshWeather(),
            style: FilledButton.styleFrom(backgroundColor: accentColor),
            child: const Text('ПОВТОРИТЬ', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
