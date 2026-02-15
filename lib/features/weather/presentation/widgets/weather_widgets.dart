import 'package:flutter/material.dart';
import '../../models/weather_model.dart';

// Виджет для отображения основной информации о погоде
class WeatherSummaryCard extends StatelessWidget {
  final CurrentWeather weather;
  final Color accentColor;
  final Color cardColor;
  final Color textColor;
  final Color subTextColor;

  const WeatherSummaryCard({
    super.key,
    required this.weather,
    required this.accentColor,
    required this.cardColor,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final temp = weather.main.temp.round();
    final description = weather.weather.first.description;
    final wind = weather.wind.speed;
    final humidity = weather.main.humidity;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 35,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.near_me, size: 14, color: subTextColor),
              const SizedBox(width: 4),
              Text(
                'ЯКУТСК, СЕГОДНЯ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: subTextColor,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            alignment: Alignment.centerRight,
            clipBehavior: Clip.none,
            children: [
              Text(
                '$temp',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                  height: 0.9,
                ),
              ),
              Positioned(
                right: -28,
                top: 10,
                child: Text(
                  '°C',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          Text(
            description[0].toUpperCase() + description.substring(1),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: accentColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),

          // Ветер + Влажность
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              WeatherMiniCard(
                icon: Icons.air,
                value: '${wind.toStringAsFixed(1)} м/с',
                label: 'Ветер',
                accent: accentColor,
                cardColor: cardColor,
                subText: subTextColor,
              ),
              WeatherMiniCard(
                icon: Icons.water_drop,
                value: '$humidity%',
                label: 'Влажность',
                accent: accentColor,
                cardColor: cardColor,
                subText: subTextColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Мини-карточка для отображения параметров погоды
class WeatherMiniCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accent;
  final Color cardColor;
  final Color subText;

  const WeatherMiniCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
    required this.cardColor,
    required this.subText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: subText,
            ),
          ),
        ],
      ),
    );
  }
}

// Виджет для отображения списка прогноза на несколько дней
class WeatherForecastList extends StatelessWidget {
  final List<ForecastWeather> forecast;
  final Color cardColor;
  final Color subTextColor;
  final Color? iconColor;

  const WeatherForecastList({
    super.key,
    required this.forecast,
    required this.cardColor,
    required this.subTextColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ПРОГНОЗ ПО ДНЯМ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: subTextColor.withValues(alpha: 0.6),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: forecast.length,
            itemBuilder: (context, i) {
              final day = forecast[i];
              final dt = day.dateTime;
              final dayTemp = day.main.temp.round();
              final icon = day.weather.first.icon;

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  width: 105,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 15,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${dt.day}.${dt.month}",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: subTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Image.network(
                        'https://openweathermap.org/img/wn/$icon@2x.png',
                        width: 40,
                        height: 40,
                        errorBuilder: (exception, stackTrace, widget) => Icon(
                          Icons.cloud,
                          size: 32,
                          color:
                              iconColor ??
                              subTextColor, // Используем iconColor, если задан, иначе subTextColor
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$dayTemp°',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
