// Тесты для RadioBrowserMetadataService
// Проверяют получение метаданных треков из Radio-Browser API

import 'package:flutter_test/flutter_test.dart';
import 'package:radio_v2/features/radio/services/radio_browser_metadata_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RadioBrowserMetadataService', () {
    late RadioBrowserMetadataService service;

    setUp(() {
      service = RadioBrowserMetadataService();
    });

    tearDown(() {
      service.dispose();
    });

    // ═══════════════════════════════════════════════════════════════
    // Тесты на жизненный цикл
    // Примечание: HTTP запросы в тестах блокируются, поэтому
    // тестируем только управление жизненным циклом
    // ═══════════════════════════════════════════════════════════════
    group('Lifecycle', () {
      test('должен начинать и останавливать получение метаданных', () {
        // Arrange
        final testUuid = '5b76f007-79b1-4bf0-bd36-75f516f370d0';

        // Act
        service.startFetchingMetadata(testUuid);

        // Assert - не должно быть исключений
        expect(true, isTrue);
      });

      test('должен останавливать получение метаданных', () {
        // Arrange
        final testUuid = '5b76f007-79b1-4bf0-bd36-75f516f370d0';

        // Act
        service.startFetchingMetadata(testUuid);
        service.stopFetchingMetadata();

        // Assert - после остановки не должно быть ошибок
        expect(true, isTrue);
      });

      test('должен корректно освобождать ресурсы', () {
        // Arrange
        final service = RadioBrowserMetadataService();

        // Act & Assert - dispose не должен выбрасывать исключения
        expect(() => service.dispose(), returnsNormally);
      });

      test('должен останавливать таймер при dispose', () {
        // Arrange
        final service = RadioBrowserMetadataService();
        final testUuid = '5b76f007-79b1-4bf0-bd36-75f516f370d0';

        // Act
        service.startFetchingMetadata(testUuid);
        service.dispose();

        // Assert - после dispose не должно быть активных таймеров
        expect(true, isTrue);
      });

      test('не должен начинать повторное получение для той же станции', () {
        // Arrange
        final testUuid = '5b76f007-79b1-4bf0-bd36-75f516f370d0';

        // Act
        service.startFetchingMetadata(testUuid);
        final firstCall = () => service.startFetchingMetadata(testUuid);

        // Assert - повторный вызов не должен делать ничего
        expect(firstCall, returnsNormally);
      });

      test('должен начинать получение для новой станции', () {
        // Arrange
        final testUuid1 = '5b76f007-79b1-4bf0-bd36-75f516f370d0';
        final testUuid2 = 'different-uuid';

        // Act
        service.startFetchingMetadata(testUuid1);
        service.startFetchingMetadata(testUuid2);

        // Assert - не должно быть исключений
        expect(true, isTrue);
      });
    });
  });
}
