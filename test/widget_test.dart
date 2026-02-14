// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_v2/features/radio/presentation/providers/radio_providers.dart';
import 'package:radio_v2/main.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Mock providers with external dependencies to ensure test is hermetic.
          newsProvider.overrideWith((ref) => Future.value([])),
          tickerProvider.overrideWith((ref) => Stream.value("")),
        ],
        child: const MyApp(),
      ),
    );

    // The app has infinite animations (BlinkingDot, Marquee) and periodic timers,
    // so pumpAndSettle will always time out. We can safely ignore this timeout
    // as it still allows the initial frame and async setup to complete.
    try {
      await tester.pumpAndSettle();
    } on FlutterError catch (e) {
      if (!e.message.contains('pumpAndSettle timed out')) {
        rethrow;
      }
    }

    // At this point, the UI should have processed the initial async calls.
    expect(find.text('SakhaLive'), findsOneWidget);

    // Verify that the first radio station is displayed.
    expect(find.text('Виктория'), findsOneWidget);
  });
}
