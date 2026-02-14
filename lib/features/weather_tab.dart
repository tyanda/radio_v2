import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'weather/presentation/weather_screen.dart';
import 'weather/providers/weather_provider.dart';

class WeatherTab extends StatelessWidget {
  const WeatherTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WeatherProvider()..fetchWeather(),
      child: const WeatherScreen(),
    );
  }
}
