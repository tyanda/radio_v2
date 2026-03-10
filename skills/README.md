# Superpowers Skills для Flutter-проекта

Адаптированная версия [obra/superpowers](https://github.com/obra/superpowers) для Flutter-разработки с Firebase.

## 📚 Структура

```
skills/
├── core/                    # Базовые навыки
│   ├── test-driven-development/
│   ├── systematic-debugging/
│   └── verification-before-completion/
├── flutter/                 # Flutter-специфичные навыки
│   ├── widget-testing/
│   ├── riverpod-providers/
│   ├── feature-first-structure/
│   └── golden-tests/
├── firebase/                # Firebase навыки
│   ├── realtime-database/
│   ├── security-rules/
│   └── firebase-testing/
├── i18n/                    # Интернационализация
│   ├── arb-workflow/
│   └── translation-review/
└── meta/                    # Мета-навыки
    ├── writing-skills/
    └── using-flutter-superpowers/
```

## 🚀 Быстрый старт

### Для Cursor

1. Добавьте в `.cursor/rules/dev-rules.mdc`:
```md
---
description: Основные правила разработки Flutter
globs: **/*.dart
---

## При изменении кода всегда следуй этим правилам:

1. **TDD**: Сначала пиши тесты, потом реализацию
2. **Feature-first**: Новые функции создавай в lib/features/<feature_name>/
3. **Riverpod**: Используй providers для состояния
4. **i18n**: Все строки локализуй через AppLocalizations
5. **Тесты**: Unit-тесты в test/unit/, widget-тесты в test/widget/
```

2. Скопируй навыки из `skills/` в `~/.cursor/skills/`

### Для Claude Code

```bash
# Установи плагин superpowers
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace

# Скопируй кастомные навыки
cp -r skills/* ~/.config/claude-code/skills/
```

## 📖 Навыки

### Core (обязательные)

| Навык | Описание |
|-------|----------|
| `test-driven-development` | RED-GREEN-REFACTOR цикл |
| `systematic-debugging` | 4-фазный поиск причин багов |
| `verification-before-completion` | Проверка перед завершением |

### Flutter

| Навык | Описание |
|-------|----------|
| `widget-testing` | Тестирование виджетов с flutter_test |
| `riverpod-providers` | Создание providers по best practices |
| `feature-first-structure` | Организация кода по features |

### Firebase

| Навык | Описание |
|-------|----------|
| `realtime-database` | Работа с Firebase Realtime Database |
| `security-rules` | Проверка правил безопасности Firebase |
| `firebase-testing` | Integration тесты с Firebase Emulator |

### i18n

| Навык | Описание |
|-------|----------|
| `arb-workflow` | Добавление строк через .arb файлы |
| `translation-review` | Проверка полноты локализации |

## 🎯 Использование

Начни сессии с команды:
```
/using-flutter-superpowers
```

Или активируй конкретный навык:
```
/widget-testing
/firebase-testing
```

## 📝 Философия

1. **Тесты первыми** — никогда не пиши код без теста
2. **Feature-first** — каждый feature изолирован
3. **Riverpod** — единый источник истины
4. **i18n всегда** — все строки локализуемы
5. **Доказательства** — `flutter test` перед коммитом
