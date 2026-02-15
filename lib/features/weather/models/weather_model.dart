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

class MainWeather {
  final double temp;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int pressure;
  final int humidity;

  MainWeather({
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
  });

  factory MainWeather.fromJson(Map<String, dynamic> json) {
    return MainWeather(
      temp: json['temp'].toDouble(),
      feelsLike: json['feels_like'].toDouble(),
      tempMin: json['temp_min'].toDouble(),
      tempMax: json['temp_max'].toDouble(),
      pressure: json['pressure'],
      humidity: json['humidity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temp': temp,
      'feels_like': feelsLike,
      'temp_min': tempMin,
      'temp_max': tempMax,
      'pressure': pressure,
      'humidity': humidity,
    };
  }
}

class Wind {
  final double speed;
  final int deg;

  Wind({
    required this.speed,
    required this.deg,
  });

  factory Wind.fromJson(Map<String, dynamic> json) {
    return Wind(
      speed: json['speed'].toDouble(),
      deg: json['deg'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speed': speed,
      'deg': deg,
    };
  }
}

class CurrentWeather {
  final MainWeather main;
  final Wind wind;
  final List<WeatherDescription> weather;
  final String name;
  final int timezone;
  final Sys sys;

  CurrentWeather({
    required this.main,
    required this.wind,
    required this.weather,
    required this.name,
    required this.timezone,
    required this.sys,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      main: MainWeather.fromJson(json['main']),
      wind: Wind.fromJson(json['wind']),
      weather: List<WeatherDescription>.from(
        json['weather'].map((item) => WeatherDescription.fromJson(item)),
      ),
      name: json['name'],
      timezone: json['timezone'],
      sys: Sys.fromJson(json['sys']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'main': main.toJson(),
      'wind': wind.toJson(),
      'weather': weather.map((e) => e.toJson()).toList(),
      'name': name,
      'timezone': timezone,
      'sys': sys.toJson(),
    };
  }
}

class ForecastWeather {
  final MainWeather main;
  final Wind wind;
  final List<WeatherDescription> weather;
  final int dt; // Unix timestamp
  final DateTime dateTime;

  ForecastWeather({
    required this.main,
    required this.wind,
    required this.weather,
    required this.dt,
    required this.dateTime,
  });

  factory ForecastWeather.fromJson(Map<String, dynamic> json) {
    return ForecastWeather(
      main: MainWeather.fromJson(json['main']),
      wind: Wind.fromJson(json['wind']),
      weather: List<WeatherDescription>.from(
        json['weather'].map((item) => WeatherDescription.fromJson(item)),
      ),
      dt: json['dt'],
      dateTime: DateTime.parse(json['dt_txt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'main': main.toJson(),
      'wind': wind.toJson(),
      'weather': weather.map((e) => e.toJson()).toList(),
      'dt': dt,
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