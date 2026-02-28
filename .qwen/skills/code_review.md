# 🔍 Code Review Skill

**Навык автоматического код-ревью для Flutter компонентов**

---

## 🎯 Назначение

Этот навык обеспечивает систематическое ревью кода перед каждым коммитом. AI проверяет код по чеклисту и даёт конкретные рекомендации.

---

## 🚀 Использование

### Активация

```
/review [файл или описание]

Примеры:
/review lib/features/radio/presentation/widgets/mini_player.dart
/review последние изменения
/review весь PR
```

---

## 📋 Чеклист код-ревью

### 1. Стиль кода (Dart Style Guide)

```markdown
## Стиль кода

- [ ] Отступы 2 пробела
- [ ] Строки < 80 символов (максимум 120)
- [ ] Имена классов PascalCase
- [ ] Имена функций/переменных camelCase
- [ ] Константы UPPER_SNAKE_CASE
- [ ] Файлы lowercase_with_underscores.dart
- [ ] Нет trailing whitespace
- [ ] Есть newline в конце файла
```

### 2. Архитектура

```markdown
## Архитектура

- [ ] Соблюдена Clean Architecture
- [ ] Нет зависимостей UI → Data
- [ ] Providers в core/providers.dart
- [ ] Виджеты в features/<feature>/presentation/widgets/
- [ ] Логика в features/<feature>/domain/
- [ ] Data в features/<feature>/data/
```

### 3. Тестирование

```markdown
## Тестирование

- [ ] Есть тесты для новой логики
- [ ] Тесты покрывают edge cases
- [ ] Используются моки для зависимостей
- [ ] Имена тестов описательные
- [ ] Тесты изолированные
```

### 4. Производительность

```markdown
## Производительность

- [ ] Нет лишних rebuild (используется const)
- [ ] Controller dispose в dispose()
- [ ] Нет утечек памяти (StreamSubscription)
- [ ] Избегать setState в циклах
- [ ] Использовать RepaintBoundary для сложных виджетов
```

### 5. Обработка ошибок

```markdown
## Обработка ошибок

- [ ] try-catch для async операций
- [ ] Логирование ошибок (Logger)
- [ ] Пользовательские сообщения об ошибках
- [ ] Нет пустых catch блоков
- [ ] Обработаны null значения
```

### 6. Доступность (a11y)

```markdown
## Доступность

- [ ] Semantics для кастомных виджетов
- [ ] labels для иконок
- [ ] Контрастность цветов
- [ ] Поддержка screen readers
- [ ] Фокус клавиатуры работает
```

### 7. Безопасность

```markdown
## Безопасность

- [ ] Нет hardcoded API ключей
- [ ] Нет sensitive данных в логах
- [ ] URL валидируются
- [ ] Нет eval / exec
- [ ] Зависимости обновлены
```

### 8. Документация

```markdown
## Документация

- [ ] Dartdoc для public API
- [ ] Комментарии для сложной логики
- [ ] README обновлён (если нужно)
- [ ] Примеры использования (если нужно)
```

---

## 🔧 Процесс ревью

### Шаг 1: Запрос ревью

```markdown
/review

Файлы:
- lib/features/radio/presentation/widgets/mini_player.dart
- test/widgets/mini_player_test.dart

Описание: Добавил жесты для управления громкостью
```

### Шаг 2: Автоматическая проверка

AI запускает проверки по чеклисту и возвращает:

```markdown
## Code Review Report

### ✅ Passed (8/12)
- Стиль кода
- Архитектура
- Документация
- ...

### ⚠️ Warnings (3/12)
- Обработка ошибок: Нет try-catch для async
- Производительность: Отсутствует const constructor
- Тестирование: Нет тестов для edge case

### ❌ Issues (1/12)
- Безопасность: Hardcoded URL в коде
```

### Шаг 3: Исправление замечаний

```dart
// ❌ БЫЛО
final url = 'http://api.example.com/key123';

// ✅ СТАЛО
final url = AppConfig.apiUrl;
```

### Шаг 4: Повторная проверка

```
/review --repeat
```

---

## 📊 Система оценки

### Уровни критичности

| Уровень | Значок | Описание | Действие |
|---------|--------|----------|----------|
| **Critical** | ❌ | Блокирует мердж | Исправить обязательно |
| **Warning** | ⚠️ | Желательно исправить | Исправить если возможно |
| **Suggestion** | 💡 | Рекомендация | На усмотрение разработчика |
| **Passed** | ✅ | Всё хорошо | Нет действий |

### Пример отчёта

```markdown
## Code Review: MiniPlayer

### ❌ Critical Issues

1. **Безопасность**: Hardcoded API ключ
   - Файл: lib/services/radio_service.dart:15
   - Решение: Переместить в .env

2. **Обработка ошибок**: Нет try-catch
   - Файл: lib/features/radio/player.dart:42
   - Решение: Обработать AudioException

### ⚠️ Warnings

1. **Производительность**: Отсутствует const constructor
   - Файл: lib/widgets/station_card.dart:10
   - Решение: Добавить const

2. **Тестирование**: Нет тестов для null case
   - Файл: test/player_test.dart
   - Решение: Добавить тест с null station

### 💡 Suggestions

1. **Стиль**: Можно использовать spread operator
   - Файл: lib/features/home/home_screen.dart:25
   - Решение: Заменить [a, b, c] на [...list]

### ✅ Passed

- Dart style guide соблюдён
- Архитектура корректная
- Документация полная
- Доступность проверена
```

---

## 🎯 Специфичные проверки для Flutter

### Widget Checks

```markdown
## Widget Specific

- [ ] Используется const где возможно
- [ ] Key для виджетов в списках
- [ ] Правильное использование StatefulWidget vs StatelessWidget
- [ ] AnimationController dispose
- [ ] MediaQuery/Theme.of в build, не в init
```

### Riverpod Checks

```markdown
## Riverpod Specific

- [ ] Providers объявлены в core/providers.dart
- [ ] Используется ref.watch для зависимостей
- [ ] ref.listen для side effects
- [ ] StateNotifier для сложного состояния
- [ ] AsyncNotifier для async операций
```

### Audio/Streaming Checks

```markdown
## Audio/Streaming Specific

- [ ] AudioService инициализирован правильно
- [ ] StreamSubscription.cancelled в dispose
- [ ] Обработаны состояния буферизации
- [ ] Уведомления для background playback
- [ ] Сессионная логика (audio_session)
```

---

## 🔧 Автоматические исправления

### AI может предложить авто-фикс

```markdown
## Auto-Fix Available

**Issue**: Missing const constructor

**Current code:**
```dart
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});
}
```

**Proposed fix:**
```dart
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key}); // ✅ Already const
  
  @override
  Widget build(BuildContext context) {
    return const Placeholder(); // ✅ Add const
  }
}
```

Apply fix? [y/n]
```

---

## 📋 Шаблоны отчётов

### Краткий отчёт

```markdown
## Quick Review

✅ Style: Pass
✅ Architecture: Pass
⚠️ Tests: 2 warnings
❌ Security: 1 critical

Ready to merge after fixing critical issues.
```

### Подробный отчёт

```markdown
## Detailed Review

### Summary
- Files changed: 3
- Lines added: 145
- Lines removed: 32
- Issues found: 7 (1❌, 3⚠️, 3💡)

### Detailed Findings

#### ❌ Critical (1)
1. [Security] Hardcoded API key in radio_service.dart

#### ⚠️ Warnings (3)
1. [Performance] Missing const constructor
2. [Tests] No edge case coverage
3. [Docs] Missing dartdoc for public API

#### 💡 Suggestions (3)
1. [Style] Use spread operator
2. [Refactor] Extract method
3. [Optimization] Cache computed value

### Recommendations
1. Fix critical security issue immediately
2. Address warnings before merge
3. Consider suggestions for future PR

### Approval Status
⏳ Pending fixes
```

---

## 🎓 Best Practices

### ✅ DO

```dart
// Всегда обрабатывайте ошибки
try {
  await audioService.play(station);
} on AudioException catch (e) {
  logger.error('Play failed: $e');
  state.copyWith(error: e.message);
}

// Используйте const
static const radius = 8.0;
const SizedBox(height: 16);

// Dispose контроллеров
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

### ❌ DON'T

```dart
// Никогда не игнорируйте ошибки
await audioService.play(station); // ❌

// Не создавайте объекты в build
@override
Widget build(BuildContext context) {
  final paint = Paint(); // ❌ Создавайте вне build
  return Container();
}

// Не забывайте dispose
@override
void dispose() {
  // _controller.dispose(); забыли! ❌
  super.dispose();
}
```

---

## 📞 Интеграция с CI/CD

### GitHub Actions

```yaml
name: Code Review
on: [pull_request]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Flutter Analyze
        run: flutter analyze
      
      - name: Flutter Test
        run: flutter test
      
      - name: Coverage
        run: |
          flutter test --coverage
          genhtml coverage/lcov.info -o coverage/html
```

---

## 📚 Ресурсы

- [Dart Style Guide](https://dart.dev/guides/language/effective-dart)
- [Flutter Best Practices](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo)
- [Riverpod Best Practices](https://riverpod.dev/docs/introduction/getting_started)
- [Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)
