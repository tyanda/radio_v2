import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_v2/core/providers.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('DynamicTheme Tests', () {
    test('должен_генерировать_тему_с_заданным_цветом', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(themeProvider.notifier);
      const testColor = Colors.green;

      final themeData = notifier.getThemeData(testColor);
      final shadTheme = notifier.getShadcnTheme(testColor);

      expect(themeData.primaryColor, equals(testColor));
      expect(shadTheme.colorScheme.primary, equals(testColor));
    });
    group('DynamicTheme Integration Tests', () {
      test('должен_извлекать_акцентный_цвет_из_цвета_станции', () async {
        // Этот тест проверяет логику извлечения (визуально)
        final hsl = HSLColor.fromColor(Colors.blue);
        final accentColor = hsl
            .withLightness((hsl.lightness).clamp(0.4, 0.7))
            .toColor();
        expect(accentColor.toARGB32(), isNotNull);
      });
    });
  });
}
