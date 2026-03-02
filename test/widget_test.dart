import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakha_live/core/providers/radio_providers.dart';
import 'package:sakha_live/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App starts and shows the main screen', (
    WidgetTester tester,
  ) async {
    // Mock the essential providers that are async or have external dependencies
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          newsProvider.overrideWith((ref) => Future.value([])),
          tickerProvider.overrideWith((ref) => Stream.value("")),
          greetingProvider.overrideWith((ref) => Stream.value("ДОБРОЕ УТРО")),
        ],
        child: const MyApp(),
      ),
    );

    // Wait for splash screen to complete and navigation to happen
    await tester.pump(const Duration(seconds: 2));

    // Allow animations to settle (ignore timeout from infinite animations)
    try {
      await tester.pumpAndSettle();
    } on FlutterError catch (e) {
      if (!e.message.contains('pumpAndSettle timed out')) {
        rethrow;
      }
    }

    // Verify we're on the home screen by checking for "SakhaLive" text
    // The text is split into "Sakha" and "Live" in RichText
    expect(find.textContaining('Sakha', findRichText: true), findsOneWidget);

    // Verify the Scaffold is present (main screen structure)
    expect(find.byType(Scaffold), findsOneWidget);

    // Verify the bottom navigation bar container is present
    expect(find.byType(Stack), findsWidgets);
  });
}
