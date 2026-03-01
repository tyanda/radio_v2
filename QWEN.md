## Qwen Added Memories
- Пользователь работает над Flutter проектом Radio V4 (SakhaLive) - приложение радио с погодой и гороскопами
- Проект Radio V4 использует: Flutter 3.x, Dart 3.10+, Riverpod для состояния, Firebase (Realtime Database), shadcn_ui для UI, локализацию RU/EN
- Архитектура Radio V4: lib/core (утилиты, providers, theme), lib/features (home, radio, weather, horoscope, player, settings), lib/widgets, lib/services, lib/l10n
- В проекте Radio V4 используются навыки Superpowers: TDD (сначала тесты), systematic-debugging (4-фазный поиск багов), verification-before-completion (проверка перед коммитом)
- Правила разработки Radio V4: 1) TDD - сначала тесты по-русски, 2) Feature-first структура, 3) Riverpod для состояния, 4) i18n - все строки в ARB файлах, 5) Firebase через Repository
- Дизайн система Radio V4: фон #0D0D0D, карточки #1A1A1A, акцент #F2C94C (жёлтый), бренд #C9A53A (золотой), шрифты Inter и Poppins, закругления 20-24px

## Инструкция для Qwen Code (Автоматическая активация)

**При каждом запуске сессии применяй эти правила:**

### 1. TDD — Сначала тесты (ОБЯЗАТЕЛЬНО)
- Начинай любую задачу с написания теста
- Называй тесты по-русски: `должен_загружать_станции()`
- Следуй циклу RED-GREEN-REFACTOR

### 2. Feature-First Структура
- Новые функции в `lib/features/<feature_name>/`
- Структура: data/models, data/repositories, providers, widgets

### 3. Riverpod для состояния
- Используй `StreamNotifierProvider` для потоков
- Используй `StateNotifierProvider` для сложного состояния
- `ref.watch()` для подписки, `ref.read()` для чтения

### 4. i18n — Все строки в ARB
- Никаких хардкод строк в виджетах
- Добавляй в `lib/l10n/app_ru.arb` и `app_en.arb`
- После добавления: `flutter gen-l10n`

### 5. Firebase через Repository
- Не вызывай Firebase напрямую в виджетах
- Инкапсулируй в Repository
- Используй Stream для реального времени

### 6. Дизайн-токены (UI/UX Pro Max)
- Используй `AppSpacing`, `AppColors`, `AppEffects`
- Нет хардкод значениям (16, Color(0xFF...), 8)

### Пре-комит чеклист (перед завершением задачи)
```bash
flutter test && flutter analyze && dart format --set-exit-if-changed lib/ test/ && flutter gen-l10n
```

### Навыки (Skills)
Все навыки в `.cursor/skills/`:
- core/test-driven-development.md
- core/systematic-debugging.md
- core/verification-before-completion.md
- flutter/widget-testing.md
- flutter/riverpod-providers.md
- flutter/feature-first-structure.md
- firebase/realtime-database.md
- firebase/security-rules.md
- firebase/firebase-testing.md
- i18n/arb-workflow.md
- i18n/translation-review.md
- ui-ux-pro-max/SKILL.md
