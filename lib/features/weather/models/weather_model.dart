class WeatherData {
  final CurrentWeather current;
  final List<ForecastWeather> forecast;

  WeatherData({
    required this.current,
    required this.forecast,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current'];
    final forecastJson = json['forecast'];

    return WeatherData(
      current: CurrentWeather.fromJson(currentJson),
      forecast: List<ForecastWeather>.from(
        forecastJson.map((item) => ForecastWeather.fromJson(item)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current': current.toJson(),
      'forecast': forecast.map((e) => e.toJson()).toList(),
    };
  }
}

class CurrentWeather {
  final double temp;
  final double feelsLike;
  final int pressure;
  final int humidity;
  final double windSpeed;
  final int windDeg;
  final List<WeatherDescription> weather;
  final String cityName;
  final int timezone;
  final Sys sys;

  CurrentWeather({
    required this.temp,
    required this.feelsLike,
    required this.pressure,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.weather,
    required this.cityName,
    required this.timezone,
    required this.sys,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temp: json['main']['temp'].toDouble(),
      feelsLike: json['main']['feels_like'].toDouble(),
      pressure: json['main']['pressure'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      windDeg: json['wind']['deg'],
      weather: List<WeatherDescription>.from(
        json['weather'].map((item) => WeatherDescription.fromJson(item)),
      ),
      cityName: json['name'],
      timezone: json['timezone'],
      sys: Sys.fromJson(json['sys']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'main': {
        'temp': temp,
        'feels_like': feelsLike,
        'pressure': pressure,
        'humidity': humidity,
      },
      'wind': {
        'speed': windSpeed,
        'deg': windDeg,
      },
      'weather': weather.map((e) => e.toJson()).toList(),
      'name': cityName,
      'timezone': timezone,
      'sys': sys.toJson(),
    };
  }
}

class ForecastWeather {
  final double temp;
  final int humidity;
  final double windSpeed;
  final List<WeatherDescription> weather;
  final DateTime dateTime;

  ForecastWeather({
    required this.temp,
    required this.humidity,
    required this.windSpeed,
    required this.weather,
    required this.dateTime,
  });

  factory ForecastWeather.fromJson(Map<String, dynamic> json) {
    return ForecastWeather(
      temp: json['main']['temp'].toDouble(),
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      weather: List<WeatherDescription>.from(
        json['weather'].map((item) => WeatherDescription.fromJson(item)),
      ),
      dateTime: DateTime.parse(json['dt_txt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'main': {
        'temp': temp,
        'humidity': humidity,
      },
      'wind': {
        'speed': windSpeed,
      },
      'weather': weather.map((e) => e.toJson()).toList(),
      'dt_txt': dateTime.toIso8601String(),
    };
  }
}

class WeatherDescription {
  final int id;
  final String main;
  final String description;
  final String icon;

  WeatherDescription({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory WeatherDescription.fromJson(Map<String, dynamic> json) {
    return WeatherDescription(
      id: json['id'],
      main: json['main'],
      description: json['description'],
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'main': main,
      'description': description,
      'icon': icon,
    };
  }
}

class Sys {
  final int sunrise;
  final int sunset;

  Sys({
    required this.sunrise,
    required this.sunset,
  });

  factory Sys.fromJson(Map<String, dynamic> json) {
    return Sys(
      sunrise: json['sunrise'],
      sunset: json['sunset'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sunrise': sunrise,
      'sunset': sunset,
    };
  }
}