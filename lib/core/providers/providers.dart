import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:radio_v2/services/rss_service.dart';
import 'package:radio_v2/features/weather/data/weather_service.dart';
import 'package:radio_v2/features/weather/data/weather_repository.dart';

final dioProvider = Provider((ref) => Dio());

final httpClientProvider = Provider((ref) => http.Client());

final rssServiceProvider = Provider((ref) {
  final client = ref.watch(httpClientProvider);
  return RssService(client);
});

final weatherServiceProvider = Provider((ref) => WeatherService());

final weatherRepositoryProvider = Provider(
  (ref) => WeatherRepositoryImpl(ref.watch(weatherServiceProvider)),
);
