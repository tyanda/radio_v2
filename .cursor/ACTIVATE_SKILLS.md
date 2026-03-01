# Активация навыков Radio V4

## Для начала сессии

Напиши в начале сессии:

```
/using-flutter-superpowers
```

Или используй один из конкретных навыков:

### Core навыки
- `/test-driven-development` — TDD цикл
- `/systematic-debugging` — Поиск багов
- `/verification-before-completion` — Проверка перед завершением

### Flutter навыки
- `/widget-testing` — Тесты виджетов
- `/riverpod-providers` — Создание providers
- `/feature-first-structure` — Архитектура

### Firebase навыки
- `/realtime-database` — Работа с Firebase
- `/security-rules` — Правила безопасности
- `/firebase-testing` — Тесты с эмулятором

### i18n навыки
- `/arb-workflow` — Добавление строк
- `/translation-review` — Проверка переводов

### UI/UX
- `/ui-ux-pro-max` — Дизайн-токены

---

## Автоматическая активация

Файл `.cursorrules` в корне проекта **автоматически активирует все правила** при каждой сессии.

Вам не нужно вручную активировать навыки — они применяются автоматически.

---

## Быстрый старт

1. **Начни задачу** — Опиши что нужно сделать
2. **TDD** — Я напишу тест сначала
3. **Реализация** — Затем код
4. **Проверка** — Запущу тесты и анализ

---

## Команды для проверки

```bash
# Запустить все тесты
flutter test

# Анализ кода
flutter analyze

# Форматирование
dart format lib/ test/

# Генерация локализации
flutter gen-l10n

# Пре-коммит проверка
flutter test && flutter analyze && dart format --set-exit-if-changed lib/ test/ && flutter gen-l10n
```
