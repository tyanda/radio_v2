# Translation Review

## Проверка переводов

### Чеклист ревью

1. **Полнота** — Все строки переведены на RU и EN
2. **Консистентность** — Термины используются одинаково
3. **Грамматика** — Нет ошибок в тексте
4. **Контекст** — Перевод соответствует UI элементу
5. **Плюрализация** — Правильные формы для множественного числа

### Автоматическая проверка

```bash
# Скрипт проверки полноты
#!/usr/bin/env python3
import json

def check_l10n_completeness():
    with open('lib/l10n/app_ru.arb', 'r', encoding='utf-8') as f:
        ru = json.load(f)
    with open('lib/l10n/app_en.arb', 'r', encoding='utf-8') as f:
        en = json.load(f)
    
    ru_keys = {k for k in ru.keys() if not k.startswith('@')}
    en_keys = {k for k in en.keys() if not k.startswith('@')}
    
    missing_in_en = ru_keys - en_keys
    missing_in_ru = en_keys - ru_keys
    
    if missing_in_en:
        print(f"❌ Отсутствует в EN: {missing_in_en}")
    if missing_in_ru:
        print(f"❌ Отсутствует в RU: {missing_in_ru}")
    
    if not missing_in_en and not missing_in_ru:
        print("✅ Все переводы на месте")

if __name__ == '__main__':
    check_l10n_completeness()
```

### Ручная проверка

```dart
// Прогон через все локали
testWidgets('проверка_переводов', (tester) async {
  final locales = AppLocalizations.supportedLocales;
  
  for (final locale in locales) {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MyWidget(),
      ),
    );
    
    // Проверить что нет пустых строк
    expect(find.text(''), findsNothing);
    
    // Проверить что нет ключей вместо значений
    expect(find.textContaining('_'), findsNothing);
  }
});
```

### Поиск проблем

```bash
# Найти строки с ключами вместо значений
grep -rn "@[a-z]" lib/ --include="*.dart" | grep "Text"

# Найти пустые строки
grep -rn 'Text("")' lib/ --include="*.dart"
grep -rn "Text('')" lib/ --include="*.dart"

# Найти строки без локализации
grep -rn "Text('.*')" lib/ --include="*.dart" | grep -v "AppLocalizations" | grep -v "debugPrint"
```

### Консистентность терминов

Создай глоссарий терминов:

```markdown
# Глоссарий

| English | Русский |
|---------|---------|
| Station | Станция |
| Play | Воспроизвести |
| Pause | Пауза |
| Loading | Загрузка |
| Error | Ошибка |
| Settings | Настройки |
```

Проверь что термины используются одинаково:

```bash
# Проверить использование термина
grep -rn "Станция" lib/ --include="*.dart"
grep -rn "Station" lib/ --include="*.dart"
```

## Процесс ревью

1. Запусти автоматическую проверку
2. Проверь новые строки вручную
3. Сверь с глоссарием
4. Проверь в контексте UI
5. Обнови глоссарий при необходимости
