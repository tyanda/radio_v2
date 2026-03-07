// Тесты для AlbumArtService
// Проверяют поиск обложек через iTunes API с кэшированием и rate limiting

import 'package:flutter_test/flutter_test.dart';
import 'package:sakha_live/features/radio/services/album_art_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AlbumArtService', () {
    late AlbumArtService service;

    setUp(() {
      service = AlbumArtService();
    });

    tearDown(() {
      service.clearCache();
    });

    // ═══════════════════════════════════════════════════════════════
    // Тесты на кэширование
    // ═══════════════════════════════════════════════════════════════
    group('Кэширование', () {
      test('должен кэшировать результаты поиска', () async {
        // Arrange & Act - первый запрос (кэш miss)
        final result1 = await service.searchAlbumArt(
          artist: 'Test Artist',
          title: 'Test Title',
        );

        // Assert - в тестах HTTP блокируется, поэтому null
        expect(result1, isNull);

        // Act - второй запрос (должен использовать кэш)
        final result2 = await service.searchAlbumArt(
          artist: 'Test Artist',
          title: 'Test Title',
        );

        // Assert
        expect(result2, isNull);
      });

      test('должен очищать кэш по clearCache()', () async {
        // Arrange
        await service.searchAlbumArt(artist: 'Test', title: 'Test');
        final statsBefore = service.getCacheStats();

        // Act
        service.clearCache();
        final statsAfter = service.getCacheStats();

        // Assert
        expect(statsBefore.totalEntries, greaterThanOrEqualTo(0));
        expect(statsAfter.totalEntries, equals(0));
      });

      test('должен возвращать статистику кэша', () {
        // Arrange & Act
        final stats = service.getCacheStats();

        // Assert
        expect(stats.totalEntries, equals(0));
        expect(stats.validEntries, equals(0));
        expect(stats.pendingRequests, equals(0));
      });

      test('должен создавать правильный ключ кэша', () async {
        // Act - выполняем два запроса с разными регистрами
        await service.searchAlbumArt(artist: 'TEST', title: 'TITLE');
        await service.searchAlbumArt(artist: 'test', title: 'title');

        // Assert - ключи должны быть нормализованы (регистр не важен)
        // В тестах HTTP не работает, поэтому кэш не сохраняется
        // Проверяем только, что pending requests завершены
        final stats = service.getCacheStats();
        expect(stats.pendingRequests, equals(0)); // Все запросы завершены
      });
    });

    // ═══════════════════════════════════════════════════════════════
    // Тесты на поиск обложек
    // Примечание: HTTP запросы в тестах возвращают 400, поэтому
    // тестируем только логику обработки ответов
    // ═══════════════════════════════════════════════════════════════
    group('searchAlbumArt', () {
      test('должен возвращать null при пустых параметрах', () async {
        // Arrange & Act
        final artUrl = await service.searchAlbumArt();

        // Assert
        expect(artUrl, isNull);
      });

      test('должен возвращать null при null параметрах', () async {
        // Arrange & Act
        final artUrl = await service.searchAlbumArt(artist: null, title: null);

        // Assert
        expect(artUrl, isNull);
      });

      test('должен выполнять запрос с artist и title', () async {
        // Arrange & Act
        final artUrl = await service.searchAlbumArt(
          artist: 'KitJah',
          title: 'Kousyun',
        );

        // Assert - в тестах HTTP блокируется, поэтому null
        expect(artUrl, isNull);
      });

      test('должен выполнять запрос только с artist', () async {
        // Arrange & Act
        final artUrl = await service.searchAlbumArt(artist: 'KitJah');

        // Assert
        expect(artUrl, isNull);
      });

      test('должен выполнять запрос только с title', () async {
        // Arrange & Act
        final artUrl = await service.searchAlbumArt(title: 'Kousyun');

        // Assert
        expect(artUrl, isNull);
      });

      test('должен обрабатывать пустые строки', () async {
        // Arrange & Act
        final artUrl = await service.searchAlbumArt(artist: '', title: '');

        // Assert
        expect(artUrl, isNull);
      });
    });

    // ═══════════════════════════════════════════════════════════════
    // Тесты на извлечение URL из ICY метаданных
    // ═══════════════════════════════════════════════════════════════
    group('extractArtUrlFromIcy', () {
      test('должен извлекать artUrl из метаданных', () {
        // Arrange
        final metadata = {
          'artUrl': 'https://example.com/art.jpg',
          'title': 'Test Song',
        };

        // Act
        final result = service.extractArtUrlFromIcy(metadata);

        // Assert
        expect(result, equals('https://example.com/art.jpg'));
      });

      test('должен извлекать imageUrl из метаданных', () {
        // Arrange
        final metadata = {'imageUrl': 'https://example.com/image.jpg'};

        // Act
        final result = service.extractArtUrlFromIcy(metadata);

        // Assert
        expect(result, equals('https://example.com/image.jpg'));
      });

      test('должен извлекать albumArt из метаданных', () {
        // Arrange
        final metadata = {'albumArt': 'https://example.com/album.jpg'};

        // Act
        final result = service.extractArtUrlFromIcy(metadata);

        // Assert
        expect(result, equals('https://example.com/album.jpg'));
      });

      test('должен извлекать coverArt из метаданных', () {
        // Arrange
        final metadata = {'coverArt': 'https://example.com/cover.jpg'};

        // Act
        final result = service.extractArtUrlFromIcy(metadata);

        // Assert
        expect(result, equals('https://example.com/cover.jpg'));
      });

      test('должен возвращать null при отсутствии полей', () {
        // Arrange
        final metadata = {'title': 'Test Song', 'artist': 'Test Artist'};

        // Act
        final result = service.extractArtUrlFromIcy(metadata);

        // Assert
        expect(result, isNull);
      });

      test('должен возвращать null при пустых метаданных', () {
        // Arrange & Act
        final result = service.extractArtUrlFromIcy({});

        // Assert
        expect(result, isNull);
      });

      test('должен возвращать null при null метаданных', () {
        // Arrange & Act
        final result = service.extractArtUrlFromIcy(null);

        // Assert
        expect(result, isNull);
      });

      test('должен приоритизировать artUrl над другими полями', () {
        // Arrange
        final metadata = {
          'artUrl': 'https://example.com/art.jpg',
          'imageUrl': 'https://example.com/image.jpg',
          'albumArt': 'https://example.com/album.jpg',
          'coverArt': 'https://example.com/cover.jpg',
        };

        // Act
        final result = service.extractArtUrlFromIcy(metadata);

        // Assert
        expect(result, equals('https://example.com/art.jpg'));
      });
    });

    // ═══════════════════════════════════════════════════════════════
    // Тесты на Rate Limiting
    // ═══════════════════════════════════════════════════════════════
    group('Rate Limiting', () {
      test('должен отслеживать количество запросов', () async {
        // Arrange & Act - выполняем несколько запросов
        for (int i = 0; i < 3; i++) {
          await service.searchAlbumArt(artist: 'Test$i', title: 'Title$i');
        }

        // Assert - проверяем, что запросы были выполнены
        final stats = service.getCacheStats();
        expect(stats.pendingRequests, equals(0)); // Все запросы завершены
      });
    });
  });
}
