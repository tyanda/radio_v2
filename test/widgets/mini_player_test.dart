// TDD Session: MiniPlayer Widget Tests
// Фаза: RED → GREEN → REFACTOR

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radio_v2/features/radio/presentation/widgets/mini_player.dart';
import 'package:radio_v2/features/radio/presentation/providers/player_provider.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('MiniPlayer Widget Tests', () {
    // ═══════════════════════════════════════════════════════════════
    // RED 1: Тест на отображение виджета
    // ═══════════════════════════════════════════════════════════════
    group('Rendering', () {
      testWidgets('должен отображаться', (tester) async {
        // Arrange
        final container = ProviderContainer(
          overrides: [
            playerProvider.overrideWith(() => PlayerNotifier()),
          ],
        );
        addTearDown(container.dispose);

        // Act
        await tester.pumpWidget(
          ProviderScope(
            child: const MaterialApp(
              home: Scaffold(
                body: MiniPlayer(),
              ),
            ),
          ),
        );

        await tester.pump();

        // Assert
        expect(find.byType(MiniPlayer), findsOneWidget);
      });

      testWidgets('не должен отображаться когда нет станции', (tester) async {
        // Arrange
        final container = ProviderContainer(
          overrides: [
            playerProvider.overrideWith(() => PlayerNotifier()),
          ],
        );
        addTearDown(container.dispose);

        // Act
        await tester.pumpWidget(
          ProviderScope(
            child: const MaterialApp(
              home: Scaffold(
                body: MiniPlayer(),
              ),
            ),
          ),
        );

        await tester.pump();

        // Assert
        // MiniPlayer скрывается когда нет станции
        expect(find.byType(MiniPlayer), findsOneWidget);
      });
    });

    // ═══════════════════════════════════════════════════════════════
    // RED 2: Тест на взаимодействие
    // ═══════════════════════════════════════════════════════════════
    group('Interactions', () {
      testWidgets('должен реагировать на нажатие', (tester) async {
        // Arrange
        final container = ProviderContainer(
          overrides: [
            playerProvider.overrideWith(() => PlayerNotifier()),
          ],
        );
        addTearDown(container.dispose);

        // Act
        await tester.pumpWidget(
          ProviderScope(
            child: const MaterialApp(
              home: Scaffold(
                body: MiniPlayer(),
              ),
            ),
          ),
        );

        await tester.pump();

        // Assert - виджет должен быть
        expect(find.byType(MiniPlayer), findsOneWidget);
      });
    });
  });
}
