// Тесты для PlayerState
// Проверяют базовую функциональность состояния плеера

import 'package:flutter_test/flutter_test.dart';
import 'package:radio_v2/features/radio/domain/station.dart';
import 'package:radio_v2/features/radio/presentation/providers/player_provider.dart';

void main() {
  group('PlayerState Tests', () {
    // ═══════════════════════════════════════════════════════════════
    // Тесты на создание состояния
    // ═══════════════════════════════════════════════════════════════
    group('Construction', () {
      test('должен создавать начальное состояние с правильными значениями', () {
        // Arrange & Act
        final state = const PlayerState();

        // Assert
        expect(state.isPlaying, isFalse);
        expect(state.currentStation, isNull);
        expect(state.volume, equals(0.65));
        expect(state.showVolumeSlider, isFalse);
        expect(state.isBuffering, isFalse);
      });

      test('должен создавать состояние с параметрами', () {
        // Arrange
        final testStation = Station(
          id: 'test-1',
          name: 'Test Radio',
          art: 'assets/images/test.png',
          desc: 'Test Description',
          icon: 'icon',
          url: 'https://test.com/stream',
          frequency: '100.0',
        );

        // Act
        final state = PlayerState(
          isPlaying: true,
          currentStation: testStation,
          volume: 0.8,
          showVolumeSlider: true,
          isBuffering: false,
        );

        // Assert
        expect(state.isPlaying, isTrue);
        expect(state.currentStation, equals(testStation));
        expect(state.volume, equals(0.8));
        expect(state.showVolumeSlider, isTrue);
        expect(state.isBuffering, isFalse);
      });
    });

    // ═══════════════════════════════════════════════════════════════
    // Тесты на copyWith
    // ═══════════════════════════════════════════════════════════════
    group('copyWith', () {
      test('должен создавать копию с измененными параметрами', () {
        // Arrange
        final initialState = const PlayerState();

        // Act
        final newState = initialState.copyWith(isPlaying: true, volume: 0.9);

        // Assert
        expect(newState.isPlaying, isTrue);
        expect(newState.volume, equals(0.9));
        // Оригинальное состояние не изменилось
        expect(initialState.isPlaying, isFalse);
        expect(initialState.volume, equals(0.65));
      });

      test('должен создавать копию с текущей станцией', () {
        // Arrange
        final testStation = Station(
          id: 'test-1',
          name: 'Test Radio',
          art: 'assets/images/test.png',
          desc: 'Test Description',
          icon: 'icon',
          url: 'https://test.com/stream',
          frequency: '100.0',
        );

        final initialState = const PlayerState();

        // Act
        final newState = initialState.copyWith(
          currentStation: testStation,
          isPlaying: true,
        );

        // Assert
        expect(newState.currentStation, equals(testStation));
        expect(newState.currentStation?.name, equals('Test Radio'));
        expect(newState.isPlaying, isTrue);
      });

      test('должен создавать копию с метаданными трека', () {
        // Arrange
        final initialState = const PlayerState();

        // Act
        final newState = initialState.copyWith(
          trackTitle: 'Test Song',
          trackArtist: 'Test Artist',
          albumArt: 'https://example.com/art.jpg',
        );

        // Assert
        expect(newState.trackTitle, equals('Test Song'));
        expect(newState.trackArtist, equals('Test Artist'));
        expect(newState.albumArt, equals('https://example.com/art.jpg'));
      });

      test('должен создавать копию с ошибкой', () {
        // Arrange
        final initialState = const PlayerState();

        // Act
        final newState = initialState.copyWith(isBuffering: true);

        // Assert
        expect(newState.isBuffering, isTrue);
      });
    });

    // ═══════════════════════════════════════════════════════════════
    // Тесты на равенство
    // ═══════════════════════════════════════════════════════════════
    group('Equality', () {
      test('должен сравнивать одинаковые состояния', () {
        // Arrange
        final state1 = const PlayerState();
        final state2 = const PlayerState();

        // Assert
        expect(state1, equals(state2));
      });

      test('не должен сравнивать разные состояния', () {
        // Arrange
        final state1 = const PlayerState();
        final state2 = state1.copyWith(isPlaying: true);

        // Assert
        expect(state1, isNot(equals(state2)));
      });
    });
  });
}
