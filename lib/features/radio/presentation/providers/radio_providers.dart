import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radio_v2/core/providers/providers.dart';
import 'package:radio_v2/features/radio/domain/station.dart';
import 'package:radio_v2/features/horoscope/domain/zodiac_sign.dart';

final stationListProvider = Provider<List<Station>>((ref) {
  return [
    Station(
      name: 'Виктория',
      desc: 'Главное радио Якутии',
      art: 'assets/images/viktoria.jpg',
      icon: 'V',
      url:
          'https://stream2.sakhafm.ru/stream/viktoria/af62bbdf-2e52-45da-9ef5-a2f60a66ef8a/e625247a-13b8-4c31-aaeb-06415c8b1657',
    ),
    Station(
      name: 'Тэтим',
      desc: 'НВК Саха',
      art: 'assets/images/tetim.jpg',
      icon: 'T',
      url: 'https://icecast-saha.cdnvideo.ru/saha',
    ),
    Station(
      name: 'IR Radio',
      desc: 'Молодежные хиты',
      art: 'assets/images/ir_radio.jpg',
      icon: 'I',
      url: 'https://5.129.229.244.nip.io/legacy/stream',
    ),
    Station(
      name: 'Европа Плюс',
      desc: 'Мировые хиты',
      art: 'assets/images/europa_plus.jpg',
      icon: 'E',
      url: 'https://ep256.hostingradio.ru:8052/europaplus256.mp3',
    ),
    Station(
      name: 'Супердискотека 90-х',
      desc: 'Хиты 90-х годов',
      art: 'assets/images/superdisco.jpg', // Изображение для новой радиостанции
      icon: 'S',
      url: 'https://radiorecord.hostingradio.ru/sd9096.aacp',
    ),
  ];
});

final zodiacSignsProvider = Provider<List<ZodiacSign>>((ref) {
  return ZodiacSign.all;
});

final greetingProvider = StreamProvider<String>((ref) async* {
  String getGreeting() {
    final hour = DateTime.now().hour;
    String emoji = (hour < 6)
        ? "🌙"
        : (hour < 12)
        ? "☀️"
        : (hour < 18)
        ? "🌤️"
        : "🌆";
    String base = (hour < 6)
        ? "ДОБРОЙ НОЧИ"
        : (hour < 12)
        ? "ДОБРОЕ УТРО"
        : (hour < 18)
        ? "ДОБРЫЙ ДЕНЬ"
        : "ДОБРЫЙ ВЕЧЕР";
    return "$base $emoji";
  }

  yield getGreeting();
  yield* Stream.periodic(const Duration(minutes: 1), (_) => getGreeting());
});

final newsProvider = FutureProvider<List<String>>((ref) {
  // Keep alive for 15 minutes, then auto-dispose.
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 15), () {
    link.close();
  });
  ref.onDispose(() => timer.cancel());

  final rssService = ref.watch(rssServiceProvider);
  return rssService.fetchNewsTitles(limit: 10);
});

final tickerProvider = StreamProvider<String>((ref) {
  try {
    final database = FirebaseDatabase.instance.ref('ticker_message');
    return database.onValue.map(
      (event) => event.snapshot.value as String? ?? "",
    );
  } catch (e) {
    // Return a stream with an error
    return Stream.error(e);
  }
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
    data: (data) => data.map((title) => "🔥 $title").toList(),
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
