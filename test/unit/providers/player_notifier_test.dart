// TDD Session: PlayerNotifier тесты
// Фаза: RED → GREEN → REFACTOR

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radio_v2/features/radio/domain/station.dart';
import 'package:radio_v2/features/radio/presentation/providers/player_provider.dart';

void main() {
  group('PlayerNotifier TDD Tests', () {
    setUpAll(() {
      // Инициализируем binding для тестов
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    // ═══════════════════════════════════════════════════════════════
    // RED 1: Тест на инициализацию
    // ═══════════════════════════════════════════════════════════════
    group('Initialization', () {
      testWidgets('должен инициализироваться с корректным состоянием по умолчанию', (tester) async {
        // Arrange & Act
        late PlayerState? capturedState;
        
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Consumer(
                  builder: (context, ref, child) {
                    final stateAsync = ref.watch(playerProvider);
                    capturedState = stateAsync.value;
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        );
        
        await tester.pumpAndSettle();

        // Assert
        expect(capturedState?.isPlaying, isFalse);
        expect(capturedState?.currentStation, isNull);
        expect(capturedState?.volume, equals(0.65));
        expect(capturedState?.showVolumeSlider, isFalse);
      });
    });

    // ═══════════════════════════════════════════════════════════════
    // RED 2: Тест на playStation
    // ═══════════════════════════════════════════════════════════════
    group('playStation', () {
      testWidgets('должен устанавливать текущую станцию', (tester) async {
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

        late PlayerState? capturedState;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Consumer(
                  builder: (context, ref, child) {
                    ref.read(playerProvider.notifier).playStation(testStation);
                    final stateAsync = ref.watch(playerProvider);
                    capturedState = stateAsync.value;
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        );
        
        await tester.pumpAndSettle();

        // Assert
        expect(capturedState?.currentStation, equals(testStation));
        expect(capturedState?.currentStation?.name, equals('Test Radio'));
      });
    });

    // ═══════════════════════════════════════════════════════════════
    // RED 3: Тест на setVolume
    // ═══════════════════════════════════════════════════════════════
    group('setVolume', () {
      testWidgets('должен устанавливать громкость', (tester) async {
        // Arrange
        const testVolume = 0.75;

        late PlayerState? capturedState;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Consumer(
                  builder: (context, ref, child) {
                    ref.read(playerProvider.notifier).setVolume(testVolume);
                    final stateAsync = ref.watch(playerProvider);
                    capturedState = stateAsync.value;
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        );
        
        await tester.pumpAndSettle();

        // Assert
        expect(capturedState?.volume, equals(testVolume));
      });
    });

    // ═══════════════════════════════════════════════════════════════
    // RED 4: Тест на toggleVolumeSlider
    // ═══════════════════════════════════════════════════════════════
    group('toggleVolumeSlider', () {
      testWidgets('должен переключать showVolumeSlider', (tester) async {
        // Arrange & Act
        late PlayerState? capturedState;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Consumer(
                  builder: (context, ref, child) {
                    ref.read(playerProvider.notifier).toggleVolumeSlider();
                    final stateAsync = ref.watch(playerProvider);
                    capturedState = stateAsync.value;
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        );
        
        await tester.pumpAndSettle();

        // Assert
        expect(capturedState?.showVolumeSlider, isTrue);
      });
    });
  });
}
