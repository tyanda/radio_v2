# Flutter Superpowers Guide

> Адаптированная версия [obra/superpowers](https://github.com/obra/superpowers) для Flutter-разработки

## 📖 Оглавление

1. [Быстрый старт](#быстрый-старт)
2. [Настройка Cursor](#настройка-cursor)
3. [Навыки](#навыки)
4. [Процесс разработки](#процесс-разработки)
5. [Интеграция с CI/CD](#интеграция-с-cicd)

---

## Быстрый старт

### 1. Установка навыков

Скопируйте папку `skills/` в ваш проект:

```bash
# Навыки уже в проекте в папке skills/
# Для использования в Cursor скопируйте:
cp -r skills/ ~/.cursor/skills/
```

### 2. Настройка правил

Правила уже настроены в `.cursor/rules/`:

- `main.mdc` — общая конфигурация
- `flutter-dev-rules.mdc` — правила разработки
- `test-rules.mdc` — правила тестирования
- `i18n-rules.mdc` — правила локализации
- `firebase-rules.mdc` — правила Firebase

### 3. Проверка работы

Откройте любой `.dart` файл и начните писать код. Cursor автоматически применит правила.

---

## Настройка Cursor

### Для нового проекта

1. **Создайте директорию правил:**
   ```bash
   mkdir -p .cursor/rules
   ```

2. **Скопируйте правила из этого проекта:**
   ```bash
   cp /path/to/radio_v4/.cursor/rules/*.mdc .cursor/rules/
   ```

3. **Скопируйте навыки:**
   ```bash
   cp -r /path/to/radio_v4/skills ~/.cursor/skills/
   ```

### Активация навыков в сессии

В начале сессии напишите:

```
/using-flutter-superpowers
```

Или активируйте конкретный навык:

```
/test-driven-development
/firebase-testing
/arb-workflow
```

---

## Навыки

### Core (Базовые)

| Навык | Файл | Описание |
|-------|------|----------|
| **TDD** | `skills/core/test-driven-development.md` | RED-GREEN-REFACTOR цикл |
| **Debugging** | `skills/core/systematic-debugging.md` | 4-фазный поиск багов |
| **Verification** | `skills/core/verification-before-completion.md` | Проверка перед коммитом |

### Flutter

| Навык | Файл | Описание |
|-------|------|----------|
| **Widget Testing** | `skills/flutter/widget-testing.md` | Тестирование виджетов |
| **Riverpod** | `skills/flutter/riverpod-providers.md` | Создание providers |
| **Feature-First** | `skills/flutter/feature-first-structure.md` | Архитектура по фичам |

### Firebase

| Навык | Файл | Описание |
|-------|------|----------|
| **Realtime Database** | `skills/firebase/realtime-database.md` | Работа с Firebase DB |
| **Security Rules** | `skills/firebase/security-rules.md` | Правила безопасности |
| **Testing** | `skills/firebase/firebase-testing.md` | Тесты с эмулятором |

### i18n

| Навык | Файл | Описание |
|-------|------|----------|
| **ARB Workflow** | `skills/i18n/arb-workflow.md` | Добавление строк через ARB |
| **Translation Review** | `skills/i18n/translation-review.md` | Проверка переводов |

---

## Процесс разработки

### 1. Начало задачи

```bash
# Создайте ветку
git checkout -b feature/new-feature

# Или для хотфикса
git checkout -b fix/bug-fix
```

### 2. TDD Цикл

#### Шаг 1: RED — Напиши тест

```dart
// test/unit/features/radio/radio_provider_test.dart
test('должен_загружать_станции_при_инициализации', () async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  
  final state = container.read(radioProvider);
  expect(state.isLoading, isTrue);
});
```

```bash
flutter test test/unit/features/radio/radio_provider_test.dart
# Тест падает (красный) ✅
```

#### Шаг 2: GREEN — Реализуй код

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

#### Шаг 3: REFACTOR — Улучши код

```bash
# Запусти анализ
flutter analyze

# Отформатируй
dart format lib/features/radio/
```

### 3. Проверка перед коммитом

```bash
# 1. Все тесты
flutter test

# 2. Анализ
flutter analyze

# 3. Форматирование
dart format --set-exit-if-changed lib/ test/

# 4. Генерация
flutter gen-l10n

# 5. Посмотри изменения
git diff HEAD
```

### 4. Коммит

```bash
git add .
git commit -m "feat(radio): добавить загрузку станций

- Создан RadioRepository для работы с Firebase
- Добавлен RadioProvider для состояния
- Написаны unit-тесты"
```

### 5. Code Review

Перед созданием PR:

- [ ] Все тесты проходят
- [ ] `flutter analyze` без ошибок
- [ ] Код отформатирован
- [ ] Локализация добавлена (RU/EN)
- [ ] Правила Firebase проверены

---

## Интеграция с CI/CD

### GitHub Actions

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Generate l10n
        run: flutter gen-l10n
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Run analyzer
        run: flutter analyze
      
      - name: Check formatting
        run: dart format --set-exit-if-changed lib/ test/
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage/lcov.info
```

### Firebase Deploy

```yaml
# .github/workflows/deploy.yml
name: Deploy to Firebase

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: subosito/flutter-action@v2
      
      - name: Build web
        run: flutter build web --release
      
      - name: Deploy to Firebase
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          channelId: live
          projectId: your-project-id
```

---

## Утилиты

### Скрипты

```bash
# Проверка локализации
./scripts/check-l10n.sh

# Поиск хардкод строк
./scripts/find-hardcoded-strings.sh

# Pre-commit проверка
./scripts/pre-commit-check.sh
```

### Полезные команды

```bash
# Запуск с логированием
flutter run --verbose

# Профилирование
flutter pub global activate devtools
flutter pub global run devtools

# Очистка
flutter clean
flutter pub get

# Пересборка
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Ресурсы

- [Оригинал Superpowers](https://github.com/obra/superpowers)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter i18n](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)

---

## Поддержка

Если возникли вопросы:

1. Проверьте документацию в `skills/README.md`
2. Посмотрите примеры в `test/`
3. Обратитесь к оригинальным навыкам superpowers
