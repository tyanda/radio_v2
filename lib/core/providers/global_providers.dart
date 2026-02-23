import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:radio_v2/features/weather/data/weather_repository.dart';
import 'package:radio_v2/features/weather/data/weather_service.dart';

final dioProvider = Provider((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ),
  );

  return dio;
});

final weatherServiceProvider = Provider(
  (ref) => WeatherService(ref.watch(dioProvider)),
);

final weatherRepositoryProvider = Provider(
  (ref) => WeatherRepositoryImpl(ref.watch(weatherServiceProvider)),
);
