# Translation Review

## Цель

Проверять полноту и качество локализации перед релизом.

## Чеклист ревью

### 1. Полнота переводов

```bash
# Проверить, что все ключи есть в обоих языках
python3 scripts/check_l10n_completeness.py
```

**Критерии:**
- [ ] Все ключи из `app_ru.arb` есть в `app_en.arb`
- [ ] Все `@key` описания присутствуют
- [ ] Нет пустых значений (`""`)

### 2. Консистентность терминологии

| Термин | RU | EN |
|--------|-----|-----|
| Радио станция | Радио | Radio |
| Воспроизведение | Воспроизведение | Playback |
| Избранное | Избранное | Favorites |
| Настройки | Настройки | Settings |

**Критерии:**
- [ ] Термины используются одинаково во всём приложении
- [ ] Нет смешения синонимов (Play/Воспроизведение/Старт)

### 3. Грамматика и стиль

**RU:**
- [ ] Нет опечаток
- [ ] Правильные падежи
- [ ] Правильное множественное число

**EN:**
- [ ] Нет опечаток
- [ ] Правильная грамматика
- [ ] Стиль соответствует UI (краткий)

### 4. Параметризация

```json
// ❌ ПЛОХО
"welcome": "Привет, Александр! Добро пожаловать!",

// ✅ ХОРОШО
"welcome": "Привет, {name}! Добро пожаловать!",
```

**Критерии:**
- [ ] Переменные в `{curly braces}`
- [ ] Параметры указаны в `@key.parameters`
- [ ] Порядок параметров не важен

### 5. Plurals (Множественное число)

```json
// ❌ ПЛОХО - только одна форма
"songs": "Песни",

// ✅ ХОРОШО - все формы
"songs": "{count, plural, =0{Нет песен} one{{count} песня} few{{count} песни} many{{count} песен} other{{count} песен}}",
```

**Критерии:**
- [ ] Все формы plural указаны
- [ ] RU: =0, one, few, many, other
- [ ] EN: =0, one, other

### 6. Длина строк для UI

**Проверка:**

```dart
// test/unit/l10n/ui_length_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Длина строк для UI', () {
    test('кнопки не длиннее 20 символов', () {
      // EN версии обычно длиннее
      expect(l10n.playButtonLabel.length, lessThanOrEqualTo(20));
      expect(l10n.pauseButtonLabel.length, lessThanOrEqualTo(20));
      expect(l10n.stopButtonLabel.length, lessThanOrEqualTo(20));
    });
    
    test('заголовки не длиннее 40 символов', () {
      expect(l10n.radioStationTitle.length, lessThanOrEqualTo(40));
      expect(l10n.weatherTitle.length, lessThanOrEqualTo(40));
    });
  });
}
```

**Критерии:**
- [ ] Кнопки: ≤20 символов
- [ ] Заголовки: ≤40 символов
- [ ] Подписи: ≤60 символов

### 7. Специальные символы

**Проверка:**
- [ ] Нет неэкранированных кавычек (`"` → `\"`)
- [ ] Нет неэкранированных обратных слешей
- [ ] Unicode символы корректны (°, ©, ®, ™)

```json
{
  "temperature": "{temperature}°C",
  "copyright": "© 2024 Радио Приложение",
  "registered": "Торговая марка®"
}
```

## Автоматические тесты

### Test: Completeness

```dart
// test/unit/l10n/completeness_test.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Полнота локализации', () {
    Map<String, dynamic> loadArb(String path) {
      final content = File(path).readAsStringSync();
      return json.decode(content) as Map<String, dynamic>;
    }
    
    Set<String> getKeys(Map<String, dynamic> arb) {
      return arb.keys
          .where((k) => !k.startsWith('@@'))
          .where((k) => !k.startsWith('@'))
          .toSet();
    }
    
    test('все ключи RU должны быть в EN', () {
      final ru = loadArb('lib/l10n/app_ru.arb');
      final en = loadArb('lib/l10n/app_en.arb');
      
      final ruKeys = getKeys(ru);
      final enKeys = getKeys(en);
      
      final missing = ruKeys.difference(enKeys);
      
      expect(missing, isEmpty,
          reason: 'Ключи отсутствуют в app_en.arb: $missing');
    });
    
    test('все ключи должны иметь описания', () {
      final ru = loadArb('lib/l10n/app_ru.arb');
      
      final keys = ru.keys
          .where((k) => !k.startsWith('@'))
          .where((k) => !k.startsWith('@@'));
      
      for (final key in keys) {
        expect(ru.containsKey('@$key'), isTrue,
            reason: 'Описание отсутствует для ключа: $key');
      }
    });
  });
}
```

### Test: No Hardcoded Strings

```dart
// test/unit/l10n/hardcoded_strings_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('нет хардкод строк в виджетах Text', () {
    final dartFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    
    final hardcodedStrings = <String>[];
    
    for (final file in dartFiles) {
      final content = file.readAsStringSync();
      final lines = content.split('\n');
      
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        // Ищем Text("...") или Text('...')
        if (line.contains(RegExp(r'Text\s*\(\s*["\'].*["\']\s*\)')) &&
            !line.contains('AppLocalizations') &&
            !line.contains('l10n') &&
            // Исключаем иконки и технические строки
            !line.contains('Icon') &&
            !line.contains('key:') &&
            !line.contains('semanticsLabel')) {
          hardcodedStrings.add('${file.path}:${i + 1}: $line');
        }
      }
    }
    
    expect(hardcodedStrings, isEmpty,
        reason: 'Найдены хардкод строки:\n${hardcodedStrings.join('\n')}');
  });
}
```

## Ручная проверка

### Скриншоты UI

1. Переключить язык на RU
2. Сделать скриншоты всех экранов
3. Переключить язык на EN
4. Сделать скриншоты всех экранов
5. Сравнить визуально

### Проверка в контексте

```dart
// Временно добавить индикатор языка
Text('${AppLocalizations.of(context)! playButtonLabel} [${LocaleSettings.currentLocale}]')
```

## Инструменты

### Script: Check L10n

```python
#!/usr/bin/env python3
# scripts/check_l10n_completeness.py

import json
import sys

def load_arb(path):
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)

def get_keys(arb):
    return {k for k in arb.keys() if not k.startswith('@')}

def main():
    ru = load_arb('lib/l10n/app_ru.arb')
    en = load_arb('lib/l10n/app_en.arb')
    
    ru_keys = get_keys(ru)
    en_keys = get_keys(en)
    
    missing_in_en = ru_keys - en_keys
    extra_in_en = en_keys - ru_keys
    
    if missing_in_en:
        print(f"❌ Ключи отсутствуют в app_en.arb:")
        for key in sorted(missing_in_en):
            print(f"  - {key}")
        sys.exit(1)
    
    if extra_in_en:
        print(f"⚠️ Лишние ключи в app_en.arb:")
        for key in sorted(extra_in_en):
            print(f"  - {key}")
    
    print(f"✅ Все {len(ru_keys)} ключей локализованы")

if __name__ == '__main__':
    main()
```

### Script: Find Hardcoded Strings

```bash
#!/bin/bash
# scripts/find_hardcoded_strings.sh

echo "🔍 Поиск хардкод строк..."

grep -rn "Text('.*')" lib/ \
  --include="*.dart" \
  --exclude-dir=l10n \
  | grep -v "AppLocalizations" \
  | grep -v "l10n" \
  | grep -v "key:" \
  | grep -v "semanticsLabel" \
  || echo "✅ Хардкод строки не найдены"
```

## Процесс ревью

### Перед каждым PR

1. Запустить `flutter gen-l10n`
2. Запустить тесты локализации
3. Проверить скриптом полноту
4. Ручная проверка в приложении

### Перед релизом

1. Freeze строк (никаких изменений за неделю)
2. Полная проверка носителем языка
3. Проверка всех экранов на обоих языках
4. Обновление скриншотов

## Шаблон отчёта

```markdown
## Локализация: Отчёт

### Статус
- ✅ RU: 100% (42/42 ключей)
- ✅ EN: 100% (42/42 ключей)

### Найденные проблемы
- [ ] 3 ключа без описаний
- [ ] 1 строка длиннее 40 символов
- [ ] 2 хардкод строки в виджетах

### Исправления
- [x] Добавлены описания
- [ ] Укорочены строки (требуется дизайнер)
- [x] Вынесены строки в ARB
```
