# ARB Workflow

## Добавление строк локализации через ARB файлы

### Шаг 1: Добавь строку в ARB файлы

```json
// lib/l10n/app_ru.arb
{
  "newFeatureTitle": "Новая функция",
  "@newFeatureTitle": {
    "description": "Заголовок новой функции на главном экране",
    "type": "text"
  },
  
  "welcomeUser": "Привет, {name}!",
  "@welcomeUser": {
    "description": "Приветствие пользователя",
    "type": "text",
    "parameters": ["name"]
  },
  
  "songsCount": "{count, plural, =0{Нет песен} one{{count} песня} few{{count} песни} many{{count} песен} other{{count} песен}}",
  "@songsCount": {
    "description": "Количество песен",
    "type": "text",
    "parameters": ["count"]
  }
}

// lib/l10n/app_en.arb
{
  "newFeatureTitle": "New Feature",
  "@newFeatureTitle": {
    "description": "New feature title on main screen",
    "type": "text"
  },
  
  "welcomeUser": "Hello, {name}!",
  "@welcomeUser": {
    "description": "User greeting",
    "type": "text",
    "parameters": ["name"]
  },
  
  "songsCount": "{count, plural, =0{No songs} one{{count} song} other{{count} songs}}",
  "@songsCount": {
    "description": "Number of songs",
    "type": "text",
    "parameters": ["count"]
  }
}
```

### Шаг 2: Сгенерируй код

```bash
flutter gen-l10n
```

Проверь что файлы сгенерированы:
- `.dart_tool/flutter_gen/gen_l10n/app_localizations.dart`
- `.dart_tool/flutter_gen/gen_l10n/app_localizations_ru.dart`
- `.dart_tool/flutter_gen/gen_l10n/app_localizations_en.dart`

### Шаг 3: Используй в коде

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// В виджете
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        Text(l10n.newFeatureTitle),
        Text(l10n.welcomeUser(userName)),
        Text(l10n.songsCount(songs.length)),
      ],
    );
  }
}
```

### Шаг 4: В тесте

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

testWidgets('должен_показывать_заголовок', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ru'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MyWidget(),
    ),
  );
  
  expect(find.text('Новая функция'), findsOneWidget);
});
```

## Формат ARB

### Простая строка

```json
{
  "key": "Значение",
  "@key": {
    "description": "Описание",
    "type": "text"
  }
}
```

### С параметром

```json
{
  "greeting": "Привет, {name}!",
  "@greeting": {
    "description": "Приветствие",
    "type": "text",
    "parameters": ["name"]
  }
}
```

### Плюрализация

```json
{
  "itemsCount": "{count, plural, =0{Нет элементов} one{{count} элемент} few{{count} элемента} many{{count} элементов} other{{count} элементов}}",
  "@itemsCount": {
    "description": "Количество элементов",
    "type": "text",
    "parameters": ["count"]
  }
}
```

### Выбор (select)

```json
{
  "status": "{status, select, active{Активен} inactive{Неактивен} other{Неизвестно}}",
  "@status": {
    "description": "Статус",
    "type": "text",
    "parameters": ["status"]
  }
}
```

## Проверка

### Найти хардкод строки

```bash
# Найти строки в Text виджетах
grep -rn "Text('.*')" lib/ --include="*.dart" | grep -v "AppLocalizations"
grep -rn 'Text(".*")' lib/ --include="*.dart" | grep -v "AppLocalizations"
```

### Проверить полноту переводов

```bash
# Скрипт проверки
python3 scripts/check_l10n_completeness.py
```

## Исключения

Допускаются хардкод строки для:
- Иконок (`IconData`)
- Ключей (`Key`, `ValueKey`)
- Semantics labels
- Отладочных сообщений (`debugPrint`)

```dart
// ✅ Допустимо
Icon(Icons.home, semanticLabel: 'Home')
ListView(key: ValueKey('station_list'))
debugPrint('Загрузка: $data')
```
