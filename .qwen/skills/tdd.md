# 🧪 TDD Skill — Test-Driven Development

**Навык разработки через тестирование для Flutter компонентов**

---

## 🎯 Назначение

Этот навык заставляет AI писать тесты **ПЕРЕД** написанием кода, следуя циклу RED-GREEN-REFACTOR.

---

## 📐 Процесс TDD

### Цикл RED-GREEN-REFACTOR

```
┌─────────────────────────────────────────────────────────┐
│                    TDD CYCLE                            │
│                                                         │
│  1. RED      →  Написать failing test                   │
│       ↓                                                   │
│  2. GREEN    →  Написать код для прохождения теста      │
│       ↓                                                   │
│  3. REFACTOR →  Улучшить код, не ломая тесты           │
│       ↓                                                   │
│  4. REPEAT   →  Вернуться к шагу 1                      │
└─────────────────────────────────────────────────────────┘
```

---

## 🚀 Использование

### Активация

```
/tdd <описание задачи>

Пример:
/tdd Реализовать поиск по радиостанциям
```

### Обязательные шаги

```markdown
## TDD Session: <Название задачи>

### Шаг 1: RED
- [ ] Написать тест на новую функциональность
- [ ] Убедиться, что тест падает (RED)
- [ ] Закоммитить тест

### Шаг 2: GREEN
- [ ] Написать минимальный код для прохождения теста
- [ ] Запустить тесты — все зелёные
- [ ] Закоммитить реализацию

### Шаг 3: REFACTOR
- [ ] Улучшить читаемость кода
- [ ] Устранить дублирование
- [ ] Добавить документацию
- [ ] Запустить тесты — все зелёные
- [ ] Закоммитить рефакторинг

### Шаг 4: REPEAT
- [ ] Вернуться к шагу 1 для следующей функциональности
```

---

## 📋 Типы тестов для Flutter

### 1. Unit Tests (для логики)

**Файл:** `test/unit/<component>_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:radio_v2/<path_to_file>.dart';

void main() {
  group('<ComponentName> Tests', () {
    late <ComponentName> component;
    late MockDependency mockDependency;

    setUp(() {
      mockDependency = MockDependency();
      component = <ComponentName>(mockDependency);
    });

    test('должен делать что-то', () {
      // Arrange
      when(mockDependency.someMethod()).thenReturn('value');

      // Act
      final result = component.method();

      // Assert
      expect(result, equals('expected'));
    });
  });
}
```

### 2. Widget Tests (для UI)

**Файл:** `test/widgets/<widget_name>_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radio_v2/<path_to_widget>.dart';

void main() {
  group('<WidgetName> Tests', () {
    testWidgets('отображает корректные данные', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: <WidgetName>(),
          ),
        ),
      );

      // Act
      final textFinder = find.text('Expected Text');

      // Assert
      expect(textFinder, findsOneWidget);
    });

    testWidgets('реагирует на нажатия', (WidgetTester tester) async {
      // Arrange
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: <WidgetName>(
            onTap: () => tapped = true,
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(<WidgetName>));
      await tester.pump();

      // Assert
      expect(tapped, isTrue);
    });
  });
}
```

### 3. Integration Tests (для потоков)

**Файл:** `test/integration/<feature>_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:radio_v2/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integration Tests', () {
    testWidgets('пользователь может воспроизвести радио', (tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.pause), findsOneWidget);
    });
  });
}
```

---

## 🎯 TDD для конкретных компонентов

### Для Radio Player

```dart
// test/unit/player/player_notifier_test.dart

void main() {
  group('PlayerNotifier Tests', () {
    late PlayerNotifier notifier;
    late MockAudioService mockAudioService;

    setUp(() {
      mockAudioService = MockAudioService();
      notifier = PlayerNotifier(mockAudioService);
    });

    test('playStation должен установить текущую станцию', () {
      // Arrange
      final testStation = Station(
        id: '1',
        name: 'Test Radio',
        art: 'test.png',
        desc: 'Test',
        url: 'http://test.com',
      );

      // Act
      notifier.playStation(testStation);

      // Assert
      expect(notifier.state.currentStation, equals(testStation));
    });

    test('togglePlay должен переключать isPlaying', () {
      // Arrange
      notifier.playStation(testStation);

      // Act
      notifier.togglePlay();

      // Assert
      expect(notifier.state.isPlaying, isTrue);
    });

    test('setVolume должен устанавливать громкость', () {
      // Act
      notifier.setVolume(0.75);

      // Assert
      expect(notifier.state.volume, equals(0.75));
    });
  });
}
```

### Для Providers (Riverpod)

```dart
// test/providers/favorites_provider_test.dart

void main() {
  group('FavoritesProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('toggleFavorite должен добавлять избранное', () {
      // Arrange
      final provider = favoritesProvider.notifier;

      // Act
      container.read(provider).toggleFavorite('Station Name');

      // Assert
      final state = container.read(favoritesProvider);
      expect(state.favoriteStationName, equals('Station Name'));
    });
  });
}
```

---

## 📊 Покрытие тестами

### Обязательное покрытие

| Компонент | Мин. Coverage |
|-----------|--------------|
| Player Notifier | 90% |
| Audio Service | 90% |
| Providers | 80% |
| UI Widgets | 60% |
| Utils | 70% |

### Проверка покрытия

```bash
# Запустить тесты с покрытием
flutter test --coverage

# Посмотреть покрытие
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## ✅ Чеклист качества тестов

```markdown
## Quality Checklist

- [ ] Тесты изолированные (нет зависимостей между тестами)
- [ ] Используются моки для внешних зависимостей
- [ ] Имена тестов описательные (должен/ожидаем/результат)
- [ ] Arrange-Act-Assert паттерн соблюдён
- [ ] Нет hardcoded значений (используются константы)
- [ ] Тесты быстрые (<10 секунд на запуск)
- [ ] Тесты стабильные (нет flaky тестов)
- [ ] Покрытие соответствует требованиям
```

---

## 🔧 Полезные команды

```bash
# Запустить все тесты
flutter test

# Запустить конкретный тест
flutter test test/unit/player_test.dart

# Запустить с покрытием
flutter test --coverage

# Запустить в watch режиме
flutter test --watch

# Запустить с отладкой
flutter test --start-paused
```

---

## 📚 Примеры

### Пример полного TDD цикла

```markdown
## TDD Session: Добавить фильтрацию избранных

### Итерация 1: Фильтр по имени

#### RED
```dart
test('filterStations должен фильтровать по имени', () {
  final stations = [
    Station(name: 'Radio 1', ...),
    Station(name: 'Radio 2', ...),
  ];
  final filtered = filterStations(stations, 'Radio 1');
  expect(filtered.length, equals(1));
  expect(filtered.first.name, equals('Radio 1'));
});
```

#### GREEN
```dart
List<Station> filterStations(List<Station> stations, String query) {
  return stations.where((s) => s.name.contains(query)).toList();
}
```

#### REFACTOR
- Добавить документацию
- Добавить обработку null

### Итерация 2: Фильтр по избранному

#### RED
```dart
test('filterStations должен фильтровать избранные', () {
  final stations = [
    Station(name: 'Radio 1', ...),
    Station(name: 'Radio 2', ...),
  ];
  final filtered = filterStations(stations, null, favorites: {'Radio 2'});
  expect(filtered.length, equals(1));
  expect(filtered.first.name, equals('Radio 2'));
});
```

... и так далее
```

---

## 🎓 Best Practices

### ✅ DO

```dart
// Называйте тесты понятно
test('playStation должен установить currentStation и isPlaying в true', () {});

// Используйте setUp для общей логики
setUp(() {
  mock = MockService();
  notifier = Notifier(mock);
});

// Используйте tearDown для очистки
tearDown(() {
  mock.dispose();
});
```

### ❌ DON'T

```dart
// Не называйте тесты кратко
test('test 1', () {}); // ❌

// Не создавайте зависимости в тестах
test('test', () {
  final service = RealService(); // ❌ Используйте моки!
});

// Не тестируйте несколько вещей в одном тесте
test('test everything', () {
  // 50 строк кода... // ❌
});
```

---

## 📞 Troubleshooting

### Проблема: Тесты падают случайно

**Решение:** Убедитесь, что тесты изолированы
```dart
setUp(() { /* fresh state */ });
tearDown(() { /* cleanup */ });
```

### Проблема: Тесты медленные

**Решение:** Используйте моки вместо реальных сервисов
```dart
// Вместо RealAudioService() используйте MockAudioService()
```

### Проблема: Сложно тестировать UI

**Решение:** Вынесите логику в отдельные функции/providers
```dart
// Логика в notifier, UI только отображает
```
