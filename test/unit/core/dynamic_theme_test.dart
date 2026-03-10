import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakha_live/core/providers.dart';
import 'package:sakha_live/core/design/design_tokens.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('ThemeProvider Tests - Фиксированные брендовые цвета', () {
    test(
      'должен_использовать_фиксированный_брендовый_цвет_SakhaLive',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(themeProvider.notifier);

        final themeData = notifier.getThemeData();
        final shadTheme = notifier.getShadcnTheme();

        // Проверяем, что используется фиксированный брендовый цвет
        expect(themeData.darkTheme.primaryColor, equals(AppColors.primary));
        expect(themeData.lightTheme.primaryColor, equals(AppColors.primary));
        expect(shadTheme.colorScheme.primary, equals(AppColors.primary));
      },
    );

    test('должен_сохранять_тёмную_тему_по_умолчанию', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = await container.read(themeProvider.future);
      expect(state.isDarkTheme, isTrue);
    });

    test('должен_переключать_тему_между_светлой_и_тёмной', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(themeProvider.notifier);

      // Изначально тёмная
      var state = await container.read(themeProvider.future);
      expect(state.isDarkTheme, isTrue);

      // Переключаем на светлую
      await notifier.toggleTheme();
      state = await container.read(themeProvider.future);
      expect(state.isDarkTheme, isFalse);

      // Переключаем обратно на тёмную
      await notifier.toggleTheme();
      state = await container.read(themeProvider.future);
      expect(state.isDarkTheme, isTrue);
    });

    test('должен_использовать_фиксированные_цвета_в_тёмной_теме', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(themeProvider.notifier);
      final themeData = notifier.getThemeData();

      // Проверяем цвета тёмной темы
      expect(
        themeData.darkTheme.scaffoldBackgroundColor,
        equals(AppColors.background),
      );
      expect(themeData.darkTheme.cardColor, equals(AppColors.cardBackground));
      expect(themeData.darkTheme.primaryColor, equals(AppColors.primary));
    });

    test('должен_использовать_фиксированные_цвета_в_светлой_теме', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(themeProvider.notifier);
      final themeData = notifier.getThemeData();

      // Проверяем цвета светлой темы
      expect(
        themeData.lightTheme.scaffoldBackgroundColor,
        equals(AppColors.backgroundLight),
      );
      expect(themeData.lightTheme.cardColor, equals(Colors.white));
      expect(themeData.lightTheme.primaryColor, equals(AppColors.primary));
    });
  });
}
