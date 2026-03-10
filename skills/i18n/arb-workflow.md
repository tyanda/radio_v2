# ARB Workflow для Flutter

## Цель

Добавлять локализованные строки через `.arb` файлы правильно и последовательно.

## Структура

```
lib/
└── l10n/
    ├── app_ru.arb      # Русский (основной)
    └── app_en.arb      # Английский
```

## Процесс добавления новой строки

### Шаг 1: Добавить в template (app_ru.arb)

```json
{
  "radioStationTitle": "Радио Станция",
  "playButtonLabel": "Воспроизвести",
  "pauseButtonLabel": "Пауза",
  
  "@radioStationTitle": {
    "description": "Заголовок радио станции на главном экране"
  },
  "@playButtonLabel": {
    "description": "Текст на кнопке воспроизведения"
  },
  "@pauseButtonLabel": {
    "description": "Текст на кнопке паузы"
  }
}
```

**Важно:**
- [ ] Ключ в camelCase
- [ ] Описание в `@key`
- [ ] Нет хардкод значений в коде

### Шаг 2: Добавить переводы в другие языки

```json
// app_en.arb
{
  "radioStationTitle": "Radio Station",
  "playButtonLabel": "Play",
  "pauseButtonLabel": "Pause",
  
  "@radioStationTitle": {
    "description": "Radio station title on main screen"
  },
  "@playButtonLabel": {
    "description": "Play button text"
  },
  "@pauseButtonLabel": {
    "description": "Pause button text"
  }
}
```

### Шаг 3: Сгенерировать код

```bash
# Сгенерировать локализацию
flutter gen-l10n

# Или через flutter pub get (автоматически)
flutter pub get
```

### Шаг 4: Использовать в коде

```dart
// lib/features/radio/widgets/radio_player.dart
import 'package:flutter/material.dart';
import 'package:sakha_live/l10n/app_localizations.dart';

class RadioPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        Text(l10n.radioStationTitle),
        ElevatedButton(
          onPressed: () { ... },
          child: Text(l10n.playButtonLabel),
        ),
      ],
    );
  }
}
```

## Параметризация строк

### ARB с параметрами

```json
{
  "stationCount": "{count, plural, =0{Нет станций} one{{count} станция} few{{count} станции} many{{count} станций} other{{count} станций}}",
  "welcomeUser": "Привет, {name}!",
  "temperature": "{temperature}°C",
  
  "@stationCount": {
    "description": "Количество радио станций",
    "parameters": ["count"]
  },
  "@welcomeUser": {
    "description": "Приветствие пользователя",
    "parameters": ["name"]
  },
  "@temperature": {
    "description": "Температура",
    "parameters": ["temperature"]
  }
}
```

### Использование с параметрами

```dart
// Количество станций
Text(l10n.stationCount(5));  // "5 станций"

// Приветствие
Text(l10n.welcomeUser('Анна'));  // "Привет, Анна!"

// Температура
Text(l10n.temperature(25));  // "25°C"
```

## Множественное число (Plurals)

### Русские правила

```json
{
  "hour": "{count, plural, =0{часов} one{{count} час} few{{count} часа} many{{count} часов} other{{count} часов}}",
  "minute": "{count, plural, =0{минут} one{{count} минута} few{{count} минуты} many{{count} минут} other{{count} минут}}",
  "second": "{count, plural, =0{секунд} one{{count} секунда} few{{count} секунды} many{{count} секунд} other{{count} секунд}}"
}
```

### Английские правила

```json
{
  "hour": "{count, plural, =0{hours} one{# hour} other{# hours}}",
  "minute": "{count, plural, =0{minutes} one{# minute} other{# minutes}}",
  "second": "{count, plural, =0{seconds} one{# second} other{# seconds}}"
}
```

## Выбранные значения (Select)

```json
{
  "greeting": "{gender, select, male{Добрый день, господин!} female{Добрый день, госпожа!} other{Добрый день!}}",
  
  "@greeting": {
    "description": "Приветствие по полу",
    "parameters": ["gender"]
  }
}
```

```dart
Text(l10n.greeting('male'));  // "Добрый день, господин!"
```

## Чеклист перед коммитом

- [ ] Строка добавлена в `app_ru.arb`
- [ ] Добавлено описание `@key`
- [ ] Перевод добавлен в `app_en.arb`
- [ ] Сгенерирован код (`flutter gen-l10n`)
- [ ] Нет предупреждений при генерации
- [ ] Используется `AppLocalizations` в коде
- [ ] Нет хардкод строк в виджетах

## Скрипт проверки

```bash
#!/bin/bash
# scripts/check-l10n.sh

echo "🔍 Проверка локализации..."

# Проверить, что все ключи есть в обоих файлах
ru_keys=$(grep -v '^@' lib/l10n/app_ru.arb | grep -o '"[^"]*":' | sort)
en_keys=$(grep -v '^@' lib/l10n/app_en.arb | grep -o '"[^"]*":' | sort)

missing_in_en=$(comm -23 <(echo "$ru_keys") <(echo "$en_keys"))

if [ -n "$missing_in_en" ]; then
  echo "❌ Ключи отсутствуют в app_en.arb:"
  echo "$missing_in_en"
  exit 1
fi

echo "✅ Все ключи локализованы"
```

## Поиск хардкод строк

```bash
# Найти строки в коде (возможные нарушения)
grep -rn "Text('.*')" lib/ --include="*.dart" | \
  grep -v "AppLocalizations" | \
  grep -v "l10n/"

# Исключения: иконки, технические строки
grep -rn "Text(\".*\")" lib/ --include="*.dart" | \
  grep -v "AppLocalizations"
```

## Генерация переводов через AI

```bash
#!/bin/bash
# scripts/generate-translations.sh

# Экспорт ключей из RU
jq -r 'to_entries | map(select(.key | startswith("@") | not)) | .[] | "\(.key): \(.value)"' lib/l10n/app_ru.arb > /tmp/ru_keys.txt

# Сгенерировать перевод через AI (пример)
# (используй ваш предпочтительный AI CLI)
ai-translate --from ru --to en /tmp/ru_keys.txt > /tmp/en_keys.txt

# Импортировать в app_en.arb
# (нужен скрипт для слияния)
```

## Пример полного ARB

```json
{
  "@@locale": "ru",
  
  "appName": "Радио Приложение",
  "@appName": {
    "description": "Название приложения"
  },
  
  "homeTab": "Главная",
  "@homeTab": {
    "description": "Вкладка главная"
  },
  
  "weatherTab": "Погода",
  "@weatherTab": {
    "description": "Вкладка погода"
  },
  
  "horoscopeTab": "Гороскоп",
  "@horoscopeTab": {
    "description": "Вкладка гороскоп"
  },
  
  "loading": "Загрузка...",
  "@loading": {
    "description": "Текст при загрузке"
  },
  
  "error": "Произошла ошибка: {error}",
  "@error": {
    "description": "Сообщение об ошибке",
    "parameters": ["error"]
  },
  
  "retry": "Повторить",
  "@retry": {
    "description": "Кнопка повторить"
  },
  
  "songsCount": "{count, plural, =0{Нет песен} one{{count} песня} few{{count} песни} many{{count} песен} other{{count} песен}}",
  "@songsCount": {
    "description": "Количество песен",
    "parameters": ["count"]
  }
}
```

## Настройка l10n.yaml

```yaml
# l10n.yaml (уже есть в проекте)
arb-dir: lib/l10n
template-arb-file: app_ru.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
preferred-supported-locales:
  - ru
  - en
nullable-getter: false  # AppLocalizations не nullable
```

## Отладка

### Проверка сгенерированного файла

```dart
// .dart_tool/flutter_gen/gen_l10n/app_localizations.dart
// Проверить, что все методы сгенерированы правильно
```

### MissingTranslationError

Если видишь ошибку:
```
A missing translation was detected...
```

1. Проверь, что ключ есть во всех `.arb` файлах
2. Запусти `flutter gen-l10n` заново
3. Перезапусти приложение
