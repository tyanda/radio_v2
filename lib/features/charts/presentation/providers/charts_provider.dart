import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/chart_item.dart';
import '../../data/services/deezer_chart_service.dart';
import '../../data/services/itunes_chart_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../services/ads_service.dart';

enum ChartCategory { russian, international }

/// Провайдер текущей категории чарта
final chartCategoryProvider = StateProvider<ChartCategory>(
  (ref) => ChartCategory.russian,
);

/// Провайдер источника данных (Deezer или iTunes)
final chartSourceProvider = StateProvider<ChartSource>(
  (ref) => ChartSource.itunes, // iTunes по умолчанию (лучше качество)
);

enum ChartSource { deezer, itunes }

/// Провайдер списка чарта (топ 10 треков)
final chartsProvider =
    StateNotifierProvider<ChartsNotifier, AsyncValue<List<ChartItem>>>(
      (ref) => ChartsNotifier(),
    );

/// StateNotifier для управления состоянием чарта
class ChartsNotifier extends StateNotifier<AsyncValue<List<ChartItem>>> {
  ChartCategory _currentCategory = ChartCategory.russian;
  ChartSource _currentSource = ChartSource.itunes;

  final DeezerChartService _deezerService = DeezerChartService();
  final ItunesChartService _itunesService = ItunesChartService();
  final AdsService _adsService = AdsService();

  ChartsNotifier() : super(const AsyncValue.loading()) {
    _loadCharts();
  }

  Future<void> _loadCharts() async {
    try {
      // Загружаем треки и рекламу параллельно
      final results = await Future.wait<List<ChartItem>>([
        _currentSource == ChartSource.itunes
            ? _loadFromItunes()
            : _loadFromDeezer(),
        _adsService.fetchVideoAds(),
      ]);

      List<ChartItem> tracks = results[0];
      final List<ChartItem> ads = results[1];

      // Фильтруем треки без previewUrl (не воспроизводимые)
      tracks = tracks
          .where(
            (track) => track.previewUrl != null && track.previewUrl!.isNotEmpty,
          )
          .toList();

      // Если API вернул пустой результат или мало треков (< 5), используем fallback
      if (tracks.isEmpty || tracks.length < 5) {
        Logger.log(
          '⚠️ Мало треков (${tracks.length}), используем fallback',
          tag: 'Charts',
        );
        state = AsyncValue.data(_getFallbackCharts());
        return;
      }

      // Берём максимум 10 треков
      if (tracks.length > 10) {
        tracks = tracks.take(10).toList();
      }

      Logger.log(
        '✅ Загружено ${tracks.length} треков для чарта',
        tag: 'Charts',
      );

      // Вставляем рекламу
      final List<ChartItem> combinedList = List.from(tracks);

      if (ads.isNotEmpty) {
        // Вставляем первое активное объявление на 5-ю позицию
        if (combinedList.length >= 5) {
          combinedList.insert(5, ads.first);
        } else {
          combinedList.add(ads.first);
        }
      } else {
        // Если из Firestore реклама не пришла, используем статический заглушечный вариант
        combinedList.insert(
          combinedList.length >= 5 ? 5 : combinedList.length,
          _getStaticAd(),
        );
      }

      state = AsyncValue.data(combinedList);
    } catch (e, stack) {
      Logger.error('❌ Ошибка загрузки чарта: $e', tag: 'Charts');
      debugPrint(stack.toString());
      state = AsyncValue.data(_getFallbackCharts());
    }
  }

  // Вспомогательный статический метод для fallback-рекламы
  ChartItem _getStaticAd() {
    return ChartItem(
      id: 'ad_static_v1',
      type: ChartItemType.videoAd,
      title: 'SakhaLive Radio',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      previewUrl: 'https://sakhalive.ru',
      actionText: 'Подробнее',
      duration: '30s',
    );
  }

  Future<List<ChartItem>> _loadFromItunes() async {
    if (_currentCategory == ChartCategory.russian) {
      // Русские хиты из России
      return await _itunesService.fetchTopRussiaTracks(limit: 10);
    } else {
      // Зарубежные хиты из США
      return await _itunesService.fetchTopGlobalTracks(limit: 10);
    }
  }

  Future<List<ChartItem>> _loadFromDeezer() async {
    if (_currentCategory == ChartCategory.russian) {
      // Русские хиты
      return await _deezerService.fetchTopRussianTracks(limit: 10);
    } else {
      // Зарубежные хиты (глобальный чарт)
      return await _deezerService.fetchTopTracks(limit: 10);
    }
  }

  /// Метод для смены категории чарта
  Future<void> setCategory(ChartCategory category) async {
    if (_currentCategory == category) return;
    _currentCategory = category;
    await refresh();
  }

  /// Метод для смены источника данных (iTunes/Deezer)
  Future<void> setSource(ChartSource source) async {
    if (_currentSource == source) return;
    _currentSource = source;
    Logger.log('🔄 Переключен источник чарта: $source', tag: 'Charts');
    await refresh();
  }

  /// Метод для обновления данных (по кнопке refresh)
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadCharts();
  }

  /// Fallback данные при ошибке API
  List<ChartItem> _getFallbackCharts() {
    final List<ChartItem> tracks = [
      ChartItem(
        id: 'm1',
        type: ChartItemType.song,
        title: 'Kousyun',
        artist: 'KitJah',
        rank: 1,
        coverUrl:
            'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=200',
        previewUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      ),
      ChartItem(
        id: 'm2',
        type: ChartItemType.song,
        title: 'Sana Kuch',
        artist: 'Jeada',
        rank: 2,
        coverUrl:
            'https://images.unsplash.com/photo-1493225255756-d9584f8606e9?w=200',
        previewUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      ),
      ChartItem(
        id: 'm3',
        type: ChartItemType.song,
        title: 'Уол огото',
        artist: 'Fiesta',
        rank: 3,
        coverUrl:
            'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=200',
        previewUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      ),
      ChartItem(
        id: 'm4',
        type: ChartItemType.song,
        title: 'Мин дойдум',
        artist: 'LUKOVNIKOV',
        rank: 4,
        coverUrl:
            'https://images.unsplash.com/photo-1459749411177-042180ce673c?w=200',
        previewUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
      ),
      ChartItem(
        id: 'm5',
        type: ChartItemType.song,
        title: 'Дыхание',
        artist: 'Vremya i Steklo',
        rank: 5,
        coverUrl:
            'https://images.unsplash.com/photo-1514525253440-b393452e8d26?w=200',
        previewUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
      ),
      _getStaticAd(),
      ChartItem(
        id: 'm6',
        type: ChartItemType.song,
        title: 'Айыыларым',
        artist: 'Sardaana',
        rank: 6,
        coverUrl:
            'https://images.unsplash.com/photo-1496293455970-f8581aae0e3c?w=200',
        previewUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
      ),
      ChartItem(
        id: 'm7',
        type: ChartItemType.song,
        title: 'Күнүм',
        artist: 'Tata',
        rank: 7,
        coverUrl:
            'https://images.unsplash.com/photo-1525926477800-7a3be5800fcb?w=200',
        previewUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
      ),
      ChartItem(
        id: 'm8',
        type: ChartItemType.song,
        title: 'Эһэм ырыата',
        artist: 'Ivan Step',
        rank: 8,
        coverUrl:
            'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=200',
        previewUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
      ),
      ChartItem(
        id: 'm9',
        type: ChartItemType.song,
        title: 'Sakha Rap',
        artist: 'Dmitriy',
        rank: 9,
        coverUrl:
            'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=200',
        previewUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
      ),
      ChartItem(
        id: 'm10',
        type: ChartItemType.song,
        title: 'Yakutsk Night',
        artist: 'Arctic Sound',
        rank: 10,
        coverUrl:
            'https://images.unsplash.com/photo-1459749411177-042180ce673c?w=200',
        previewUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
      ),
    ];
    return tracks;
  }
}
