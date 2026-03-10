# Verification Before Completion

## Цель

Никогда не завершать задачу без доказательства, что она работает.

## Процесс проверки

### 1. Запусти тесты

```bash
# Все тесты
flutter test

# С покрытием
flutter test --coverage

# Проверь, что покрытие не упало
# (используй lcov или coverage)
```

**Чеклист:**
- [ ] Все тесты проходят
- [ ] Покрытие не упало критически
- [ ] Нет предупреждений в выводе

### 2. Проверь вручную (если нужно)

```bash
# Запусти приложение
flutter run

# Для веба
flutter run -d chrome

# Для iOS
flutter run -d ios

# Для Android
flutter run -d android
```

**Чеклист:**
- [ ] Приложение запускается без ошибок
- [ ] Новая функция работает
- [ ] Старые функции не сломались

### 3. Статический анализ

```bash
# Анализ кода
flutter analyze

# Форматирование
dart format --set-exit-if-changed lib/ test/

# Проверка pubspec
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**Чеклист:**
- [ ] `flutter analyze` без ошибок
- [ ] Код отформатирован
- [ ] Генерация кода работает

### 4. Проверь дифф

```bash
# Посмотри изменения
git diff HEAD

# Убедись, что нет лишнего
git status
```

**Чеклист:**
- [ ] Изменения только там, где планировал
- [ ] Нет отладочного кода (`print()`, `debugger()`)
- [ ] Нет закомментированного кода
- [ ] `.env` и секреты не попали в коммит

## Шаблон pre-commit проверки

```bash
#!/bin/bash
# scripts/pre-commit-check.sh

set -e

echo "🔍 Запуск тестов..."
flutter test

echo "🔍 Статический анализ..."
flutter analyze

echo "🔍 Форматирование..."
dart format --set-exit-if-changed lib/ test/

echo "🔍 Проверка сборки..."
flutter build web --dry-run

echo "✅ Все проверки пройдены!"
```

## Автоматизация через Git Hooks

```bash
# .git/hooks/pre-commit
#!/bin/bash
set -e

# Запусти проверки
flutter test
flutter analyze

# Если что-то упало — коммит отменён
```

## Критерии готовности (DoD)

Задача считается **готовой**, только если:

- [ ] Код написан
- [ ] Тесты написаны и проходят
- [ ] `flutter analyze` без ошибок
- [ ] Ручная проверка (если применимо)
- [ ] Документация обновлена
- [ ] Code review пройдено

## Анти-паттерны

❌ **Плохо:**
```
"Код работает, я проверил локально"
"Тесты потом напишу"
"Это маленькое изменение, не нужно тестировать"
```

✅ **Хорошо:**
```
"Тесты проходят: 42/42"
"flutter analyze: 0 issues"
"Добавил интеграционный тест на новый функционал"
```

## Интеграция с CI/CD

```yaml
# .github/workflows/verify.yml
name: Verification

on: [pull_request]

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test
      
      - name: Run analyzer
        run: flutter analyze
      
      - name: Check formatting
        run: dart format --set-exit-if-changed lib/ test/
      
      - name: Build (verify compilation)
        run: flutter build web --release
```
