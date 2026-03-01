# Test-Driven Development (TDD)

## Цикл RED-GREEN-REFACTOR

### Шаг 1: RED — Напиши падающий тест

```dart
// test/unit/features/radio/radio_provider_test.dart
test('должен_загружать_станции_при_инициализации', () async {
  // Arrange
  final container = ProviderContainer();
  addTearDown(container.dispose);

  // Act
  final state = container.read(radioProvider);

  // Assert
  expect(state.isLoading, isTrue);
});
```

```bash
flutter test test/unit/features/radio/radio_provider_test.dart
# Тест падает (красный) ✅
```

### Шаг 2: GREEN — Реализуй код

```dart
// lib/features/radio/providers/radio_provider.dart
final radioProvider = StreamNotifierProvider<RadioNotifier, RadioState>((ref) {
  return RadioNotifier()..loadStations();
});
```

```bash
flutter test test/unit/features/radio/radio_provider_test.dart
# Тест проходит (зелёный) ✅
```

### Шаг 3: REFACTOR — Улучши код

```bash
# Запусти анализ
flutter analyze

# Отформатируй
dart format lib/features/radio/ test/unit/features/radio/
```

## Правила

1. **Названия тестов по-русски**: `должен_делать_что_то()`
2. **Arrange-Act-Assert**: Структура каждого теста
3. **Изоляция**: Каждый тест независим
4. **Dispose**: Освобождай ресурсы (`addTearDown`)
