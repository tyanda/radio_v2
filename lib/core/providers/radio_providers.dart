import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radio_v2/core/providers/global_providers.dart';
import 'package:radio_v2/features/radio/domain/station.dart';
import 'package:radio_v2/features/horoscope/domain/zodiac_sign.dart';
import 'package:radio_v2/services/news_service.dart';
import 'package:radio_v2/features/radio/domain/repositories/favorites_repository.dart';
import 'package:radio_v2/features/radio/presentation/providers/favorites_provider.dart';
import 'package:radio_v2/features/radio/data/repositories/favorites_repository_impl.dart';

final stationListProvider = Provider<List<Station>>((ref) {
  return [
    Station(
      id: '1',
      name: 'Виктория',
      desc: 'Главное радио Якутии',
      art: 'assets/images/viktoria.jpg',
      icon: 'V',
      url: 'https://stream2.sakhafm.ru/stream/viktoria/af62bbdf-2e52-45da-9ef5-a2f60a66ef8a/e625247a-13b8-4c31-aaeb-06415c8b1657',
      frequency: '101.8 FM',
    ),
    Station(
      id: '2',
      name: 'Тэтим',
      desc: 'НВК Саха',
      art: 'assets/images/tetim.jpg',
      icon: 'T',
      url: 'https://icecast-saha.cdnvideo.ru/saha',
      frequency: '103.4 FM',
    ),
    Station(
      id: '3',
      name: 'IR Radio',
      desc: 'Молодежные хиты',
      art: 'assets/images/ir_radio.jpg',
      icon: 'I',
      url: 'https://5.129.229.244.nip.io/legacy/stream',
      frequency: '104.5 FM',
    ),
    Station(
      id: '4',
      name: 'Европа Плюс',
      desc: 'Мировые хиты',
      art: 'assets/images/europa_plus.jpg',
      icon: 'E',
      url: 'http://ep256.hostingradio.ru:8052/europaplus256.mp3',
      frequency: '105.2 FM',
    ),
    Station(
      id: '5',
      name: 'Супердискотека 90-х',
      desc: 'Хиты 90-х годов',
      art: 'assets/images/superdisco.jpg',
      icon: 'S',
      url: 'https://radiorecord.hostingradio.ru/sd9096.aacp',
      frequency: '106.7 FM',
    ),
    Station(
      id: '6',
      name: 'Radio Paradise',
      desc: 'Eclectic music mix',
      art: 'assets/images/load.png',
      icon: 'R',
      url: 'https://stream.radioparadise.com/mp3-128',
      frequency: 'Online',
    ),
    Station(
      id: '7',
      name: 'Русское Радио',
      desc: 'Музыка только на русском языке',
      art: 'assets/images/load.png',
      icon: 'Р',
      url: 'https://rusradio.hostingradio.ru/rusradio96.aacp',
      frequency: '105.7 FM',
    ),
    Station(
      id: '8',
      name: 'Радио Record',
      desc: 'Танцевальная музыка',
      art: 'assets/images/load.png',
      icon: 'R',
      url: 'https://radiorecord.hostingradio.ru/rr_main96.aacp',
      frequency: '106.3 FM',
    ),
    Station(
      id: '10',
      name: 'Record Хиты Всех Времен',
      desc: 'Лучшие хиты всех времён',
      art: 'assets/images/load.png',
      icon: 'H',
      url: 'https://radiorecord.hostingradio.ru/gold96.aacp',
      frequency: 'Online',
    ),
    Station(
      id: '11',
      name: 'Record Russian Hits',
      desc: 'Русские хиты',
      art: 'assets/images/load.png',
      icon: 'RH',
      url: 'https://radiorecord.hostingradio.ru/rus96.aacp',
      frequency: 'Online',
    ),
    Station(
      id: '12',
      name: 'СТВ-Радио',
      desc: 'Светлое радио',
      art: 'assets/images/load.png',
      icon: 'С',
      url: 'http://stream2.radiotoday.ru:8000/stv',
      frequency: 'Online',
    ),
  ];
});

final zodiacSignsProvider = Provider<List<ZodiacSign>>((ref) {
  return ZodiacSign.all;
});

final greetingProvider = StreamProvider<String>((ref) async* {
  String getGreeting() {
    final hour = DateTime.now().hour;
    String base = (hour < 6)
        ? "ДОБРОЙ НОЧИ"
        : (hour < 12)
        ? "ДОБРОЕ УТРО"
        : (hour < 18)
        ? "ДОБРЫЙ ДЕНЬ"
        : "ДОБРЫЙ ВЕЧЕР";
    return base;
  }

  yield getGreeting();
  yield* Stream.periodic(const Duration(minutes: 1), (_) => getGreeting());
});

final newsProvider = FutureProvider<List<String>>((ref) async {
  // Keep alive for 15 minutes, then auto-dispose.
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 15), () {
    link.close();
  });
  ref.onDispose(() => timer.cancel());

  final dio = ref.watch(dioProvider);
  final newsService = NewsService(dio);
  return newsService.fetchNewsTitles(limit: 10);
});

final tickerProvider = StreamProvider<String>((ref) {
  final database = FirebaseDatabase.instance.ref('ticker_message');
  return database.onValue.map((event) {
    final value = event.snapshot.value;
    if (value is String) {
      return value;
    }
    return "";
  }).handleError((error) {
    // Логируем ошибку, но не прерываем поток
    return "";
  });
});

final marqueeTextProvider = Provider<String>((ref) {
  final news = ref.watch(newsProvider);
  final ticker = ref.watch(tickerProvider);

  final tickerText = ticker.when(
    data: (data) => data.isNotEmpty ? data.toUpperCase() : null,
    loading: () => null,
    error: (_, _) => null,
  );

  final newsText = news.when(
    data: (data) => data.map((title) => title).toList(),
    loading: () => [],
    error: (_, _) => [],
  );

  final combined = tickerText != null
      ? [tickerText, ...newsText]
      : [...newsText];

  if (combined.isEmpty) {
    return news.isLoading ? "ЗАГРУЖАЮ НОВОСТИ..." : "НЕТ АКТУАЛЬНЫХ НОВОСТЕЙ";
  }

  return combined.join("  •  ");
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  // В реальном приложении здесь будет создание репозитория с зависимостями
  return FavoritesRepositoryImpl();
});

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
      final repository = ref.watch(favoritesRepositoryProvider);
      return FavoritesNotifier(repository);
    });
