# 🚀 Sakha Radio AI Skills

**Фреймворк навыков для AI-ассистированной разработки Flutter-приложения**

---

## 📋 Описание

Этот проект содержит набор навыков (skills) для дисциплинированной разработки Sakha Radio с использованием AI-ассистентов. Основан на методологии [obra/superpowers](https://github.com/obra/superpowers), адаптирован для Flutter/Dart.

---

## 🎯 Доступные навыки

| Навык | Файл | Назначение |
|-------|------|-----------|
| **🧪 TDD** | `tdd.md` | Test-Driven Development для Flutter компонентов |
| **🔍 Code Review** | `code_review.md` | Автоматическое ревью кода перед коммитом |
| **📋 Planning** | `planning.md` | Разбиение задач на подзадачи по 2-5 минут |
| **🐛 Debugging** | `debugging.md` | Системная отладка по 4-фазному процессу |
| **🏗️ Architecture** | `architecture.md` | Проверка соответствия чистой архитектуре |
| **📝 Documentation** | `documentation.md` | Генерация документации к коду |
| **⚡ Performance** | `performance.md` | Оптимизация производительности Flutter |
| **🔒 Security** | `security.md` | Проверка безопасности и уязвимостей |

---

## 🚀 Быстрый старт

### Активировать навык

```
@tdd
@code_review
@planning
@debugging
```

### Команды для активации

| Команда | Описание |
|---------|----------|
| `/tdd <задача>` | Запустить TDD цикл для задачи |
| `/review` | Запросить код-ревью текущих изменений |
| `/plan <задача>` | Создать детальный план реализации |
| `/debug <проблема>` | Запустить системную отладку |
| `/arch-check` | Проверить архитектуру кода |

---

## 📐 Принципы работы

### 1. Сначала требования → Потом код

```
❌ ПЛОХО: "Напиши функцию для..."
✅ ХОРОШО: "Давай обсудим требования к функции..."
```

### 2. План перед реализацией

```
1. Понять задачу
2. Задать уточняющие вопросы
3. Создать план (2-5 минут на пункт)
4. Получить подтверждение
5. Реализовать
```

### 3. Тесты перед кодом (TDD)

```
RED → GREEN → REFACTOR

1. Написать failing test
2. Написать минимальный код для прохождения
3. Рефакторинг
4. Повторить
```

### 4. Код-ревью обязательно

```
Перед любым коммитом:
- Запустить /review
- Исправить замечания
- Только потом коммит
```

---

## 🎓 Использование навыков

### TDD Цикл

```markdown
/tdd Реализовать поиск по радиостанциям

1. [RED] Пишу тест на поиск по названию
2. [RED] Пишу тест на фильтрацию по избранному
3. [GREEN] Реализую поиск в RadioCardsView
4. [GREEN] Добавляю фильтрацию
5. [REFACTOR] Улучшаю читаемость
6. [REFACTOR] Добавляю документацию
```

### Код-ревью Чеклист

```markdown
/review

- [ ] Код соответствует Dart style guide
- [ ] Нет дублирования (DRY)
- [ ] Есть тесты для новой логики
- [ ] Нет hardcoded значений
- [ ] Обработаны ошибки
- [ ] Нет TODO без issue
- [ ] Производительность не ухудшилась
- [ ] Доступность (a11y) проверена
```

### Планирование задачи

```markdown
/plan Добавить виджет избранного

1. [2 мин] Изучить текущую структуру favorites
2. [3 мин] Создать StationGrid виджет
3. [2 мин] Написать unit тесты
4. [3 мин] Интегрировать в RadioCardsView
5. [2 мин] Добавить тесты на интеграцию
6. [3 мин] Обновить документацию

Итого: ~15 минут
```

---

## 📁 Структура проекта

```
.qwen/skills/
├── SKILL.md              # Главный файл (этот)
├── tdd.md                # TDD workflow
├── code_review.md        # Code review process
├── planning.md           # Planning & estimation
├── debugging.md          # Systematic debugging
├── architecture.md       # Architecture guidelines
├── documentation.md      # Documentation standards
├── performance.md        # Performance optimization
└── security.md           # Security checklist

.qwen/templates/
├── widget_test.dart      # Шаблон теста для виджета
├── provider_test.dart    # Шаблон теста для provider
└── service_test.dart     # Шаблон теста для сервиса
```

---

## 🔧 Настройка для проекта

### Контекст проекта

- **Фреймворк:** Flutter 3.x
- **State Management:** Riverpod 2.x
- **Архитектура:** Clean Architecture + Feature-first
- **Язык:** Dart 3.x
- **Локализация:** ru_RU, en_US

### Критичные компоненты

| Компонент | Приоритет тестов |
|-----------|-----------------|
| Radio Player | 🔴 Обязательно 100% coverage |
| Favorites Provider | 🔴 Обязательно |
| Audio Service | 🔴 Обязательно |
| UI Widgets | 🟡 Желательно |
| Utils/Helpers | 🟡 Желательно |

---

## 📊 Метрики качества

### Целевые показатели

```
✅ Code Coverage: >80% для core логики
✅ Build Time: <30 секунд
✅ Test Time: <60 секунд
✅ No analyzer errors
✅ No runtime exceptions в production
```

---

## 🎯 Best Practices для Sakha Radio

### 1. Riverpod Providers

```dart
// ✅ ПРАВИЛЬНО
final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerState>(
  (ref) => PlayerNotifier(ref.watch(audioServiceProvider)),
);

// ❌ НЕПРАВИЛЬНО
class PlayerWidget extends StatefulWidget {
  final player = AudioPlayer(); // Не создавайте инстансы в виджетах!
}
```

### 2. Тестирование

```dart
// ✅ ПРАВИЛЬНО - изолированный тест
test('playStation должен установить текущую станцию', () {
  final notifier = PlayerNotifier(mockAudioService);
  notifier.playStation(testStation);
  expect(notifier.state.currentStation, equals(testStation));
});

// ❌ НЕПРАВИЛЬНО - тест с зависимостями
test('играет радио', () {
  // Реальный аудиоплеер, сеть, и т.д.
});
```

### 3. Обработка ошибок

```dart
// ✅ ПРАВИЛЬНО
try {
  await audioService.play(station);
} on AudioException catch (e) {
  logger.error('Failed to play: $e');
  state.copyWith(error: e.message);
}

// ❌ НЕПРАВИЛЬНО
await audioService.play(station); // Без обработки
```

---

## 📚 Ресурсы

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Riverpod Documentation](https://riverpod.dev/)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture-tdd/)

---

## 🔄 Версионирование

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.0.0 | 2026-02-28 | Initial release |

---

## 📞 Поддержка

Для вопросов и предложений создавайте issue в репозитории проекта.
