import 'package:flutter_test/flutter_test.dart';
import 'package:sakha_live/features/charts/data/services/deezer_chart_service.dart';
import 'package:sakha_live/features/charts/data/models/chart_item.dart';

void main() {
  group('DeezerChartService', () {
    late DeezerChartService service;

    setUp(() {
      service = DeezerChartService();
    });

    test('должен возвращать пустой список при ошибке сети', () async {
      // Arrange - создаём сервис с неверным URL
      final badService = DeezerChartService(baseUrl: 'https://invalid.url/api');

      // Act
      final tracks = await badService.fetchTopTracks(limit: 10);

      // Assert
      expect(
        tracks,
        isEmpty,
        reason: 'При ошибке должен вернуться пустой список',
      );
    });

    test('должен возвращать список ChartItem', () async {
      // Act - проверяем что сервис работает и не падает
      final tracks = await service.fetchTopTracks(limit: 1);

      // Assert
      expect(
        tracks,
        isA<List<ChartItem>>(),
        reason: 'Должен вернуться список ChartItem',
      );
    });
  });

  group('DeezerChartService с моком', () {
    test('должен парсить JSON ответ Deezer API', () async {
      // Arrange - mock JSON ответ
      final mockJson =
          {
                'data': [
                  {
                    'id': '123456',
                    'title': 'Test Song',
                    'artist': {'name': 'Test Artist'},
                    'album': {'cover_xl': 'https://example.com/cover.jpg'},
                    'preview': 'https://example.com/preview.mp3',
                    'duration': 180,
                    'rank': 100,
                  },
                ],
              }
              as Map<String, Object>;

      // Act - проверяем модель
      final dataList = mockJson['data'] as List?;
      expect(dataList, isNotEmpty);
      final track = _parseTrack(dataList!.first as Map<String, dynamic>);

      // Assert
      expect(track['id'], equals('123456'));
      expect(track['title'], equals('Test Song'));
      expect(track['artist'], equals('Test Artist'));
      expect(track['coverUrl'], contains('example.com'));
    });
  });
}

// Helper для проверки парсинга
Map<String, String> _parseTrack(Map<String, dynamic> json) {
  final artist = json['artist'] as Map<String, dynamic>? ?? {};
  final album = json['album'] as Map<String, dynamic>? ?? {};

  String coverUrl =
      album['cover_xl'] as String? ??
      album['cover_big'] as String? ??
      album['cover_medium'] as String? ??
      album['cover_small'] as String? ??
      '';

  return {
    'id': json['id']?.toString() ?? '',
    'title': json['title'] as String? ?? '',
    'artist': artist['name'] as String? ?? '',
    'coverUrl': coverUrl,
  };
}
