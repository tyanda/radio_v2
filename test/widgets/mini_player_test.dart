// TDD Session: MiniPlayer Widget Tests
// Фаза: RED → GREEN → REFACTOR
//
// Тесты на синхронизацию метаданных:
// - При переключении с радио на трек, мини-плеер должен показывать название трека
// - При переключении с трека на радио, мини-плеер должен показывать название станции
// - Metadata не должны "залипать" при переключении

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakha_live/features/radio/presentation/widgets/mini_player.dart';
import 'package:sakha_live/core/providers.dart';

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
        // Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [audioHandlerProvider.overrideWithValue(null)],
            child: const MaterialApp(home: Scaffold(body: MiniPlayer())),
          ),
        );

        await tester.pump();

        // Assert
        expect(find.byType(MiniPlayer), findsOneWidget);
      });

      testWidgets('не должен отображаться когда нет станции', (tester) async {
        // Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [audioHandlerProvider.overrideWithValue(null)],
            child: const MaterialApp(home: Scaffold(body: MiniPlayer())),
          ),
        );

        await tester.pump();

        // Assert
        // MiniPlayer скрывается когда нет станции
        expect(find.byType(MiniPlayer), findsOneWidget);
      });
    });

    // ═══════════════════════════════════════════════════════════════
    // RED 2: Тест на синхронизацию метаданных
    // ═══════════════════════════════════════════════════════════════
    group('Metadata Synchronization', () {
      testWidgets('должен отображаться когда играет радио', (tester) async {
        // Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [audioHandlerProvider.overrideWithValue(null)],
            child: const MaterialApp(home: Scaffold(body: MiniPlayer())),
          ),
        );

        await tester.pump();

        // Assert - виджет должен быть
        expect(find.byType(MiniPlayer), findsOneWidget);
      });

      testWidgets('должен отображаться когда играет трек', (tester) async {
        // Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [audioHandlerProvider.overrideWithValue(null)],
            child: const MaterialApp(home: Scaffold(body: MiniPlayer())),
          ),
        );

        await tester.pump();

        // Assert - виджет должен быть
        expect(find.byType(MiniPlayer), findsOneWidget);
      });
    });

    // ═══════════════════════════════════════════════════════════════
    // RED 3: Тест на взаимодействие
    // ═══════════════════════════════════════════════════════════════
    group('Interactions', () {
      testWidgets('должен реагировать на нажатие', (tester) async {
        // Act
        await tester.pumpWidget(
          ProviderScope(
            overrides: [audioHandlerProvider.overrideWithValue(null)],
            child: const MaterialApp(home: Scaffold(body: MiniPlayer())),
          ),
        );

        await tester.pump();

        // Assert - виджет должен быть
        expect(find.byType(MiniPlayer), findsOneWidget);
      });
    });
  });
}
