# Verification Before Completion

## Чеклист перед завершением задачи

### 1. Запусти все тесты

```bash
flutter test
```

✅ Все тесты проходят

### 2. Проверь анализ кода

```bash
flutter analyze
```

✅ Нет ошибок или предупреждений

### 3. Проверь форматирование

```bash
dart format --set-exit-if-changed lib/ test/
```

✅ Код отформатирован (exit code 0)

### 4. Проверь генерацию

```bash
flutter gen-l10n
flutter pub run build_runner build --delete-conflicting-outputs
```

✅ Генерация работает без ошибок

### 5. Проверь дифф

```bash
git diff HEAD
```

✅ Изменения соответствуют задаче

### 6. Проверь локализацию

```bash
# Найди хардкод строки
grep -rn "Text('.*')" lib/ --include="*.dart" | grep -v "AppLocalizations"
```

✅ Нет хардкод строк

### 7. Проверь дизайн-токены

```bash
# Найди хардкод цвета
grep -rn "Color(0x" lib/ --include="*.dart"
```

✅ Нет хардкод цветов/отступов

## Автоматическая проверка

```bash
# Скрипт пре-коммит проверки
./scripts/pre-commit-check.sh
```

## Если что-то не проходит

1. **Тесты не проходят** → Исправь код или тест
2. **Анализ ошибка** → Исправь предупреждения
3. **Форматирование** → `dart format lib/ test/`
4. **Генерация ошибка** → Проверь синтаксис ARB/кода
5. **Хардкод строки** → Перенеси в ARB файлы
