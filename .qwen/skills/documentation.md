# 📝 Documentation Skill

**Навык генерации и поддержки документации**

---

## 🎯 Назначение

Этот навык обеспечивает качественную документацию кода: dartdoc комментарии, README, changelog.

---

## 🚀 Использование

```
/docs <что задокументировать>

Примеры:
/docs lib/features/radio/presentation/widgets/mini_player.dart
/docs добавить README для новой фичи
/docs обновить CHANGELOG
```

---

## 📋 Типы документации

### 1. Dartdoc (для кода)

```dart
/// Краткое описание класса.
///
/// Подробное описание с примерами использования.
///
/// ## Пример
/// ```dart
/// final player = PlayerNotifier(audioService);
/// player.playStation(station);
/// ```
///
/// ## См. также
/// - [AudioService] для низкоуровневого аудио API
/// - [PlayerState] для состояния плеера
class PlayerNotifier extends StateNotifier<PlayerState> {
  /// Краткое описание конструктора.
  ///
  /// [audioService] - сервис для воспроизведения аудио.
  /// Throws [AudioException] если сервис не инициализирован.
  PlayerNotifier(this.audioService);

  /// Краткое описание метода.
  ///
  /// [station] - радиостанция для воспроизведения.
  ///
  /// Возвращает [Future], который завершается когда
  /// воспроизведение началось.
  ///
  /// Throws:
  /// - [AudioException] если ошибка воспроизведения
  /// - [NetworkException] если нет сети
  Future<void> playStation(Station station) async {
    // Реализация
  }
}
```

### 2. README (для модулей)

```markdown
# Radio Feature

Модуль воспроизведения радио.

## Компоненты

- `RadioView` - главный экран радио
- `MiniPlayer` - мини-плеер
- `PlayerProvider` - управление состоянием

## Использование

```dart
import 'package:radio_v2/features/radio/radio.dart';

// Отобразить экран
RadioView();

// Использовать плеер
ref.read(playerProvider.notifier).playStation(station);
```

## Тесты

```bash
flutter test test/features/radio/
```
```

### 3. CHANGELOG (для версий)

```markdown
# Changelog

## [1.0.1] - 2026-02-28

### Added
- Улучшенный SplashScreen с анимациями
- Жесты для MiniPlayer (свайпы)
- Поиск и фильтры для RadioCardsView

### Changed
- Улучшена дизайн-система (AppEffects)
- Обновлены анимации переходов

### Fixed
- Исправлена утечка памяти в PlayerNotifier

## [1.0.0] - 2026-01-01

### Added
- Initial release
```

---

## 📐 Стандарты документирования

### Классы

```dart
/// <Краткое описание>
///
/// <Подробное описание с примерами>
///
/// ## Пример использования
/// ```dart
/// <пример кода>
/// ```
///
/// ## См. также
/// - [RelatedClass1]
/// - [RelatedClass2]
class MyClass {}
```

### Методы

```dart
/// <Краткое описание>
///
/// <Подробное описание>
///
/// [param1] - описание параметра
/// [param2] - описание параметра
///
/// Возвращает <что возвращает>.
///
/// Throws:
/// - [ExceptionType1] если <условие>
/// - [ExceptionType2] если <условие>
void myMethod(String param1, int param2) {}
```

### Переменные

```dart
/// Описание переменной.
///
/// По умолчанию: `default_value`
final String myVariable = 'value';
```

---

## ✅ Чеклист документации

```markdown
## Documentation Checklist

### Code Documentation
- [ ] Все public классы задокументированы
- [ ] Все public методы задокументированы
- [ ] Параметры описаны
- [ ] Возвращаемые значения описаны
- [ ] Исключения описаны
- [ ] Примеры использования есть

### Project Documentation
- [ ] README.md актуален
- [ ] CHANGELOG.md ведётся
- [ ] API документация сгенерирована
- [ ] Примеры кода работают

### Quality
- [ ] Нет опечаток
- [ ] Примеры актуальны
- [ ] Ссылки работают
- [ ] Форматирование корректное
```

---

## 🔧 Генерация документации

### Dartdoc

```bash
# Сгенерировать документацию
dart doc

# Открыть в браузере
open doc/api/index.html
```

### Проверка

```bash
# Проверить dartdoc
dart doc --dry-run
```

---

## 📋 Шаблоны

### README для фичи

```markdown
# <Feature Name>

<Краткое описание фичи>

## Структура

```
<feature>/
├── presentation/    # UI компоненты
├── domain/          # Бизнес логика
└── data/            # Data слой
```

## Компоненты

### Presentation

- `<Widget1>` - описание
- `<Widget2>` - описание

### Domain

- `<Entity1>` - описание
- `<UseCase1>` - описание

### Data

- `<Model1>` - описание
- `<Service1>` - описание

## Использование

```dart
<пример кода>
```

## Тесты

```bash
flutter test test/features/<feature>/
```

## Зависимости

- `<package1>` - для чего используется
- `<package2>` - для чего используется
```

### CHANGELOG entry

```markdown
## [<version>] - <date>

### Added
- <что добавлено>

### Changed
- <что изменено>

### Deprecated
- <что устарело>

### Removed
- <что удалено>

### Fixed
- <что исправлено>

### Security
- <исправления безопасности>
```

---

## 🎓 Best Practices

### ✅ DO

```dart
/// Воспроизводит радиостанцию.
///
/// Начинает воспроизведение указанной радиостанции
/// и обновляет состояние плеера.
///
/// ## Пример
/// ```dart
/// final notifier = PlayerNotifier(service);
/// await notifier.playStation(station);
/// ```
///
/// [station] - радиостанция для воспроизведения.
///
/// Throws [AudioException] если воспроизведение невозможно.
Future<void> playStation(Station station) async {}
```

### ❌ DON'T

```dart
/// Play station.
///
/// Plays the station.
///
/// [station] station.
/// Throws exception if error.
Future<void> playStation(Station station) async {} // ❌ Слишком кратко!
```

---

## 📚 Ресурсы

- [Dart Documentation Guide](https://dart.dev/guides/language/effective-dart/documentation)
- [Dartdoc Package](https://pub.dev/packages/dartdoc)
- [Keep a Changelog](https://keepachangelog.com/)
