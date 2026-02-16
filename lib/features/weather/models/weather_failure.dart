// Классы для обработки ошибок погодного модуля

class WeatherFailure {
  final String message;

  WeatherFailure(this.message);

  @override
  String toString() => 'WeatherFailure: $message';
}

class NetworkFailure extends WeatherFailure {
  NetworkFailure(super.message);
}

class ServerFailure extends WeatherFailure {
  ServerFailure(super.message);
}

class UnknownFailure extends WeatherFailure {
  UnknownFailure(super.message);
}
