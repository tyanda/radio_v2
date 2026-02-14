import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';
import 'widgets/weather_widgets.dart';

// Глобальный ValueNotifier для хранения текста бегущей строки
final ValueNotifier<String?> globalMarqueeTextNotifier = ValueNotifier<String?>(
  null,
);

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
      // Запускаем автоматическое обновление каждые 15 минут
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

    if (state == AppLifecycleState.resumed) {
      // Обновляем погоду при возвращении в приложение
      Provider.of<WeatherProvider>(context, listen: false).refreshWeather();
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      Provider.of<WeatherProvider>(context, listen: false).refreshWeather();
    });
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Доброй ночи';
    if (hour < 12) return 'Доброе утро';
    if (hour < 18) return 'Добрый день';
    return 'Добрый вечер';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Call super.build for AutomaticKeepAliveClientMixin

    // Цветовая палитра SakhaLive
    const accent = Color(0xFFFFD700);
    const bgColor = Colors.black;
    const cardColor = Color(0xFF111111);
    const textColor = Colors.white;
    const subText = Color(0xFFA3A3A3);

    return Scaffold(
      backgroundColor: bgColor,
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          return weatherProvider.error != null
              ? _buildErrorView(weatherProvider, accent)
              : weatherProvider.weatherData != null
              ? _buildWeatherContent(
                  weatherProvider.weatherData!,
                  accent,
                  cardColor,
                  textColor,
                  subText,
                )
              : _buildLoadingView(accent, textColor);
        },
      ),
    );
  }

  // Виджет ошибки
  Widget _buildErrorView(WeatherProvider provider, Color accent) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_outlined,
              size: 48,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 20),
            const Text(
              'НЕТ СВЯЗИ',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => provider.refreshWeather(),
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.black,
              ),
              child: const Text('ОБНОВИТЬ'),
            ),
          ],
        ),
      ),
    );
  }

  // Виджет загрузки
  Widget _buildLoadingView(Color accent, Color textColor) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_download_outlined, color: accent, size: 40),
          const SizedBox(height: 20),
          CircularProgressIndicator(color: accent),
          const SizedBox(height: 20),
          Text(
            'ЗАГРУЗКА ПОГОДЫ...',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: textColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherContent(
    WeatherData weatherData,
    Color accent,
    Color cardColor,
    Color textColor,
    Color subText,
  ) {
    final current = weatherData.current;
    final forecastList = weatherData.forecast;

    final sunrise = current.sys.sunrise > 0
        ? DateTime.fromMillisecondsSinceEpoch(
            (current.sys.sunrise * 1000),
          ).toLocal()
        : DateTime.now(); // значение по умолчанию
    final sunset = current.sys.sunset > 0
        ? DateTime.fromMillisecondsSinceEpoch(
            (current.sys.sunset * 1000),
          ).toLocal()
        : DateTime.now().add(
            const Duration(hours: 12),
          ); // значение по умолчанию
    final dfTime = DateFormat.Hm('ru');

    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<WeatherProvider>(
          context,
          listen: false,
        ).refreshWeather();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WeatherSummaryCard(
              weather: current,
              accentColor: accent,
              cardColor: cardColor,
              textColor: textColor,
              subTextColor: subText,
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.white12, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSunInfo('ВОСХОД', dfTime.format(sunrise), subText),
                  _buildSunInfo('ЗАКАТ', dfTime.format(sunset), subText),
                ],
              ),
            ),
            const SizedBox(height: 20),
            WeatherForecastList(
              forecast: forecastList,
              cardColor: cardColor,
              subTextColor: subText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSunInfo(String label, String time, Color subText) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: subText,
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}