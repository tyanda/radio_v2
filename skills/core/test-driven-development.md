# Test-Driven Development для Flutter

## Цель

Писать тесты **до** реализации кода, следуя циклу RED-GREEN-REFACTOR.

## Процесс

### 1. RED — Напиши падающий тест

```dart
// test/unit/providers/radio_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakha_live/features/radio/providers/radio_provider.dart';

void main() {
  group('RadioProvider', () {
    test('должен загружать список станций', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      
      final radioState = container.read(radioProvider);
      
      expect(radioState.isLoading, isTrue);
      expect(radioState.stations, isEmpty);
    });
  });
}
```

**Критерии:**
- [ ] Тест назван по паттерну `должен_делать_что_то`
- [ ] Тест падает (красный)
- [ ] Тест изолирован (не зависит от других тестов)

### 2. GREEN — Реализуй минимум кода

```dart
// lib/features/radio/providers/radio_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RadioState {
  final bool isLoading;
  final List<RadioStation> stations;
  
  RadioState({this.isLoading = false, this.stations = const []});
}

final radioProvider = StateNotifierProvider<RadioNotifier, RadioState>((ref) {
  return RadioNotifier();
});

class RadioNotifier extends StateNotifier<RadioState> {
  RadioNotifier() : super(RadioState(isLoading: true)) {
    _loadStations();
  }
  
  Future<void> _loadStations() async {
    // TODO: реализовать загрузку
    state = RadioState(isLoading: false, stations: []);
  }
}
```

**Критерии:**
- [ ] Тест проходит (зелёный)
- [ ] Код минимален
- [ ] Нет лишней логики

### 3. REFACTOR — Улучши код

```dart
// Добавь обработку ошибок, кэширование, логирование
```

**Критерии:**
- [ ] Тест всё ещё проходит
- [ ] Код стал чище
- [ ] Нет дублирования

## Команды

```bash
# Запустить все тесты
flutter test

# Запустить конкретный тест
flutter test test/unit/providers/radio_provider_test.dart

# Запустить с покрытием
flutter test --coverage

# Проверить покрытие
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Правила

1. **Никакого кода без теста** — сначала RED
2. **Один тест — одна ответственность** — не тестируй всё в одном тесте
3. **Называй по-русски** — `должен_загружать_станции()`
4. **Используй ProviderContainer** — для тестирования Riverpod
5. **addTearDown** — освобождай ресурсы после теста

## Анти-паттерны

❌ **Плохо:**
```dart
test('test1', () { ... });  // Непонятное название
test('загрузка и отображение и обновление', () { ... });  // Слишком много
```

✅ **Хорошо:**
```dart
test('должен_загружать_список_станций', () { ... });
test('должен_показывать_ошибку_при_отсутствии_сети', () { ... });
```

## Интеграция с CI

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter test --coverage
```
