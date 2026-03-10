# Настройка Qwen Code для Radio V4

## ✅ Настройка завершена

Все файлы конфигурации созданы и готовы к работе.

---

## 📁 Структура файлов

```
radio_v4/
├── .cursorrules                    # ⭐ Главный файл - активирует правила автоматически
├── .cursor/
│   ├── ACTIVATE_SKILLS.md          # Инструкция по активации навыков
│   ├── rules/                      # Правила Cursor (.mdc файлы)
│   │   ├── main.mdc
│   │   ├── flutter-dev-rules.mdc
│   │   ├── test-rules.mdc
│   │   ├── i18n-rules.mdc
│   │   ├── firebase-rules.mdc
│   │   └── ui-ux-rules.mdc
│   └── skills/                     # Навыки Superpowers
│       ├── core/
│       │   ├── test-driven-development.md
│       │   ├── systematic-debugging.md
│       │   └── verification-before-completion.md
│       ├── flutter/
│       │   ├── widget-testing.md
│       │   ├── riverpod-providers.md
│       │   └── feature-first-structure.md
│       ├── firebase/
│       │   ├── realtime-database.md
│       │   ├── security-rules.md
│       │   └── firebase-testing.md
│       ├── i18n/
│       │   ├── arb-workflow.md
│       │   └── translation-review.md
│       └── ui-ux-pro-max/
│           └── SKILL.md
└── QWEN.md                         # Обновлённая память проекта
```

---

## 🚀 Как использовать

### Автоматическая активация (рекомендуется)

Файл **`.cursorrules`** автоматически активирует все правила при каждой сессии.

**Вам не нужно ничего делать** — просто начните работать, и я буду следовать правилам.

### Ручная активация (опционально)

В начале сессии напишите:

```
/using-flutter-superpowers
```

Или активируйте конкретный навык:

```
/test-driven-development
```

---

## 📋 Правила работы

### 1. TDD — Сначала тесты

```dart
// 1. RED - Пишу падающий тест
test('должен_загружать_станции', () async { ... });

// 2. GREEN - Реализую код
// 3. REFACTOR - Улучшаю
```

### 2. Feature-First

```
features/radio/
├── data/models/
├── data/repositories/
├── providers/
└── widgets/
```

### 3. Riverpod

```dart
final provider = StreamNotifierProvider<Notifier, State>((ref) {
  return Notifier();
});
```

### 4. i18n

```dart
// ❌ Text("Привет")
// ✅ Text(AppLocalizations.of(context)!.welcome)
```

### 5. Firebase через Repository

```dart
// ❌ FirebaseDatabase.instance.ref()
// ✅ repository.getStations()
```

### 6. Дизайн-токены

```dart
// ❌ EdgeInsets.all(16)
// ✅ EdgeInsets.all(AppSpacing.lg)
```

---

## ✅ Пре-коммит чеклист

Перед завершением задачи я автоматически проверю:

```bash
flutter test                                    # Все тесты проходят
flutter analyze                                 # Нет ошибок анализа
dart format --set-exit-if-changed lib/ test/    # Код отформатирован
flutter gen-l10n                                # Генерация работает
```

---

## 🎯 Примеры использования

### Новая функция

1. Опиши задачу: "Добавь кнопку паузы в радио плеер"
2. Я напишу тест сначала
3. Реализую код
4. Запущу проверку

### Исправление бага

1. Опиши проблему: "Радио не воспроизводится после паузы"
2. Я найду баг (4-фазный debugging)
3. Напишу тест на баг
4. Исправлю код

### Новая строка локализации

1. Скажи: "Добавь строку 'Загрузка...'"
2. Я добавлю в ARB файлы (RU/EN)
3. Запущу `flutter gen-l10n`
4. Использую в коде

---

## 📚 Документы

- **QWEN.md** — Память проекта (обновлено)
- **.cursorrules** — Автоматическая активация правил
- **.cursor/ACTIVATE_SKILLS.md** — Список навыков
- **FLUTTER_SUPERPOWERS_GUIDE.md** — Полная документация Superpowers

---

## 🔧 Команды разработки

```bash
# Запуск
flutter run

# Тесты
flutter test
flutter test --coverage

# Анализ
flutter analyze

# Форматирование
dart format lib/ test/

# Генерация
flutter gen-l10n
flutter pub run build_runner build --delete-conflicting-outputs

# Сборка
flutter build web
flutter build apk
flutter build ios
```

---

## 💡 Советы

1. **Всегда описывай задачу подробно** — Я напишу тесты и код точно по требованиям
2. **Проверяй результат** — Я запущу тесты перед завершением
3. **Используй навыки** — `/test-driven-development` для сложных задач

---

**Готово!** Теперь при каждом запуске я буду автоматически следовать этим правилам.
