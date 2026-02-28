# 🐛 Debugging Skill — Системная отладка

**Навык отладки по 4-фазному процессу**

---

## 🎯 Назначение

Этот навык обеспечивает систематический подход к поиску и исправлению багов, используя 4-фазный процесс: Reproduce → Isolate → Fix → Verify.

---

## 🚀 Использование

### Активация

```
/debug <описание проблемы>

Примеры:
/debug Плеер зависает при переключении
/debug Не работает поиск по станциям
/debug Ошибка при запуске на Android
```

---

## 📐 4-фазный процесс отладки

```
┌─────────────────────────────────────────────────────────┐
│              DEBUGGING PROCESS                          │
│                                                         │
│  PHASE 1: REPRODUCE  →  Воспроизвести баг              │
│       ↓                                                   │
│  PHASE 2: ISOLATE    →  Найти корневую причину         │
│       ↓                                                   │
│  PHASE 3: FIX        →  Исправить                      │
│       ↓                                                   │
│  PHASE 4: VERIFY     →  Проверить и предотвратить      │
│       ↓                                                   │
│  DONE              →  Задокументировать                │
└─────────────────────────────────────────────────────────┘
```

---

## 🔍 Фаза 1: REPRODUCE (Воспроизведение)

### Цель

Чётко определить условия воспроизведения бага.

### Чеклист

```markdown
## Phase 1: Reproduce

- [ ] Описать симптомы
- [ ] Определить шаги воспроизведения
- [ ] Выяснить частоту (всегда/иногда/редко)
- [ ] Определить окружение (OS, версия, устройство)
- [ ] Скриншоты/видео/логи
```

### Шаблон отчёта

```markdown
## Bug Report: <Название>

### Симптомы
<Что происходит неправильно>

### Шаги воспроизведения
1. Открыть приложение
2. Нажать на кнопку X
3. Наблюдать ошибку Y

### Ожидаемое поведение
<Что должно происходить>

### Фактическое поведение
<Что происходит на самом деле>

### Частота
- [ ] Всегда (100%)
- [ ] Часто (>50%)
- [ ] Иногда (<50%)
- [ ] Редко (<10%)

### Окружение
- OS: Android 14 / iOS 17 / Web
- Устройство: Pixel 8 / iPhone 15 / Chrome
- Версия приложения: 1.0.1
```

### Команды для сбора информации

```bash
# Логи Flutter
flutter logs

# Логи Android
adb logcat | grep -i "radio"

# Логи iOS
idevicesyslog | grep -i "radio"

# Debug режим
flutter run --verbose
```

---

## 🔬 Фаза 2: ISOLATE (Изоляция)

### Цель

Найти корневую причину (root cause).

### Методы изоляции

#### 1. Divide and Conquer

```markdown
## Isolation: Divide and Conquer

1. Разделить код на части
2. Проверить каждую часть
3. Найти где проблема

Пример:
- [ ] UI виджет отображает данные? ✅
- [ ] Provider передаёт данные? ✅
- [ ] Service получает данные? ❌ ← Проблема здесь!
```

#### 2. Binary Search (для регрессий)

```markdown
## Isolation: Binary Search

1. Найти последний рабочий коммит
2. Найти первый сломанный коммит
3. Найти коммит с багом

git bisect start
git bisect bad HEAD
git bisect good <рабочий коммит>
```

#### 3. Debugging Tools

```markdown
## Isolation: Tools

### Flutter DevTools
- Widget Inspector
- Performance overlay
- Memory profiler
- Network tab

### Print Debugging
Logger.log('State: ${state}');

### Breakpoints
- Точка останова в IDE
- debugger(); в коде

### Assertions
assert(state != null, 'State must not be null');
```

### Шаблон отчёта

```markdown
## Root Cause Analysis

### Гипотезы
1. [ ] Проблема в UI (виджет не rebuild)
2. [ ] Проблема в Provider (state не обновляется)
3. [ ] Проблема в Service (данные не приходят)
4. [x] Проблема в Audio (плеер не инициализирован)

### Проверка гипотез

**Гипотеза 1: UI**
- Проверил: Widget rebuilds ✅
- Вывод: Не проблема

**Гипотеза 2: Provider**
- Проверил: State обновляется ✅
- Вывод: Не проблема

**Гипотеза 3: Service**
- Проверил: Данные приходят ✅
- Вывод: Не проблема

**Гипотеза 4: Audio**
- Проверил: AudioPlayer не инициализирован ❌
- Вывод: ПРОБЛЕМА ЗДЕСЬ!

### Корневая причина
AudioPlayer.init() не вызывается при переключении станции.

### Доказательства
- Лог: "Player not initialized"
- Код: init() только в main()
- Тест: Провал на переключении
```

---

## 🔧 Фаза 3: FIX (Исправление)

### Цель

Исправить корневую причину, а не симптомы.

### Чеклист

```markdown
## Phase 3: Fix

- [ ] Исправление адресует корневую причину
- [ ] Нет side effects
- [ ] Код соответствует стилю проекта
- [ ] Написан тест на баг
- [ ] Тест проходит с исправлением
```

### Шаблон исправления

```markdown
## Fix Plan

### Корневая причина
AudioPlayer.init() не вызывается при переключении станции.

### Решение
Вызвать init() в playStation() перед воспроизведением.

### Изменения
```dart
// БЫЛО
Future<void> playStation(Station station) async {
  _currentStation = station;
  await _player.play();
}

// СТАЛО
Future<void> playStation(Station station) async {
  _currentStation = station;
  await _player.setUrl(station.url); // ← Инициализация
  await _player.play();
}
```

### Тест на баг
```dart
test('должен инициализировать плеер при переключении', () async {
  await notifier.playStation(station1);
  await notifier.playStation(station2);
  expect(notifier.state.isPlaying, isTrue);
});
```
```

---

## ✅ Фаза 4: VERIFY (Проверка)

### Цель

Убедиться что баг исправлен и не вернётся.

### Чеклист

```markdown
## Phase 4: Verify

- [ ] Баг не воспроизводится с исправлением
- [ ] Все тесты проходят
- [ ] Нет регрессий
- [ ] Производительность не ухудшилась
- [ ] Добавлен тест на баг (prevent regression)
- [ ] Задокументировано в CHANGELOG
```

### Шаблон проверки

```markdown
## Verification Report

### Тесты
```
✅ Unit tests: 45 passed
✅ Widget tests: 23 passed
✅ Integration tests: 8 passed
```

### Ручная проверка
- [ ] Воспроизвести шаги бага → Ошибка не появляется ✅
- [ ] Проверить смежный функционал → Всё работает ✅
- [ ] Проверить производительность → Без изменений ✅

### Regression Prevention
- [x] Добавлен тест: test/player_switch_test.dart
- [x] Добавлен комментарий в код
- [ ] Обновлена документация (не требуется)

### Статус
✅ BUG FIXED AND VERIFIED
```

---

## 🎯 Специфичные баги Flutter

### 1. State Management баги

```markdown
## Common: State не обновляется

### Симптомы
- UI не реагирует на изменения
- setState не работает

### Диагностика
1. Проверить что setState вызывается
2. Проверить что виджет не disposed
3. Проверить зависимости в build

### Решение
// ❌ НЕПРАВИЛЬНО
void update() {
  someVariable = value;
  // setState забыли!
}

// ✅ ПРАВИЛЬНО
void update() {
  setState(() {
    someVariable = value;
  });
}
```

### 2. Async/Await баги

```markdown
## Common: Future не завершается

### Симптомы
- Loading бесконечно
- Данные не приходят

### Диагностика
1. Проверить что await используется
2. Проверить что нет deadlock
3. Проверить error handling

### Решение
// ❌ НЕПРАВИЛЬНО
void loadData() {
  fetchData(); // Забыли await!
  setState(() => loaded = true);
}

// ✅ ПРАВИЛЬНО
Future<void> loadData() async {
  await fetchData();
  setState(() => loaded = true);
}
```

### 3. Memory Leak баги

```markdown
## Common: Утечка памяти

### Симптомы
- Приложение замедляется со временем
- Потребление памяти растёт

### Диагностика
1. Проверить StreamSubscription
2. Проверить AnimationController
3. Проверить Timer

### Решение
// ❌ НЕПРАВИЛЬНО
class _MyWidget extends State<MyWidget> {
  StreamSubscription? _subscription;
  
  @override
  void initState() {
    _subscription = stream.listen(...);
  }
  // dispose забыли!
}

// ✅ ПРАВИЛЬНО
class _MyWidget extends State<MyWidget> {
  StreamSubscription? _subscription;
  
  @override
  void initState() {
    _subscription = stream.listen(...);
  }
  
  @override
  void dispose() {
    _subscription?.cancel(); // ← Освободить ресурсы
    super.dispose();
  }
}
```

---

## 🔧 Debugging Tools

### Flutter DevTools

```markdown
## DevTools

### Widget Inspector
- Проверить дерево виджетов
- Найти лишние rebuild
- Проверить keys

### Performance
- FPS метрика
- Build time
- Raster time

### Memory
- Heap snapshot
- Allocation profile
- Memory leaks

### Network
- HTTP запросы
- Response time
- Payload size
```

### Logger

```dart
// Использование Logger в проекте
Logger.log('Информация');
Logger.warning('Предупреждение');
Logger.error('Ошибка');

// С тегами
Logger.log('Сообщение', tag: 'Player');
```

### Print vs Logger

```dart
// ❌ НЕПРАВИЛЬНО
print('Debug: $value');

// ✅ ПРАВИЛЬНО
Logger.log('Value: $value', tag: 'MyWidget');
```

---

## 📋 Шаблоны

### Bug Report Template

```markdown
## Bug Report

### Название
<Краткое описание>

### Критичность
- [ ] Critical (блокирует работу)
- [ ] High (серьёзная проблема)
- [ ] Medium (неудобство)
- [ ] Low (косметика)

### Описание
<Подробное описание>

### Шаги воспроизведения
1. ...
2. ...
3. ...

### Ожидаемый результат
<Что должно быть>

### Фактический результат
<Что есть>

### Логи
```
<Вставить логи>
```

### Скриншоты
<Прикрепить>

### Окружение
- OS: ...
- Устройство: ...
- Версия: ...
```

### Fix Report Template

```markdown
## Fix Report

### Bug
<Ссылка на bug report>

### Root Cause
<Корневая причина>

### Solution
<Описание решения>

### Changes
- Файл 1: описание изменений
- Файл 2: описание изменений

### Tests
- [x] Добавлен тест на баг
- [x] Все тесты проходят
- [x] Ручная проверка пройдена

### Verification
- [x] Баг не воспроизводится
- [x] Нет регрессий
- [x] Производительность в норме

### Status
✅ FIXED
```

---

## 🎓 Best Practices

### ✅ DO

```dart
// Логировать важные события
Logger.log('Playing station: ${station.name}', tag: 'Player');

// Обрабатывать ошибки
try {
  await player.play();
} on AudioException catch (e) {
  Logger.error('Play failed: $e');
  state.copyWith(error: e.message);
}

// Освобождать ресурсы
@override
void dispose() {
  _controller.dispose();
  _subscription?.cancel();
  super.dispose();
}
```

### ❌ DON'T

```dart
// Не игнорировать ошибки
try {
  await something();
} catch (_) {} // ❌ Пустой catch!

// Не логировать чувствительные данные
Logger.log('Password: $password'); // ❌

// Не забывать dispose
@override
void dispose() {
  // _controller.dispose(); забыли! ❌
  super.dispose();
}
```

---

## 📚 Ресурсы

- [Flutter Debugging](https://docs.flutter.dev/testing/debugging)
- [Dart DevTools](https://docs.flutter.dev/development/tools/devtools/overview)
- [Flutter Performance](https://docs.flutter.dev/perf/rendering-performance)
