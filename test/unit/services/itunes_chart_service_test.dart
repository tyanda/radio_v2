import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_test/flutter_test.dart';
import 'package:sakha_live/features/charts/data/services/itunes_chart_service.dart';

void main() {
  group('ItunesChartService', () {
    final service = ItunesChartService();

    test('fetchTopTracks should parse iTunes RSS correctly', () async {
      // Это интеграционный тест, он делает реальный сетевой запрос.
      // В идеале мы должны замокать http.Client, но для быстрой проверки
      // воспользуемся реальным API.
      final tracks = await service.fetchTopTracks(limit: 5);

      expect(tracks, isNotEmpty);
      expect(tracks.length, lessThanOrEqualTo(5));

      final firstTrack = tracks.first;
      expect(firstTrack.id, isNotEmpty);
      expect(firstTrack.title, isNotEmpty);
      expect(firstTrack.artist, isNotEmpty);
      expect(firstTrack.rank, equals(1));
      expect(firstTrack.coverUrl, isNotEmpty);
      expect(firstTrack.coverUrl, contains('600x600bb')); // Проверка улучшения качества

      // Печатаем данные для визуальной проверки в логах
      debugPrint('First track: ${firstTrack.title} by ${firstTrack.artist}');
      debugPrint('Cover URL: ${firstTrack.coverUrl}');
      debugPrint('Preview URL: ${firstTrack.previewUrl}');
    });
  });
}
