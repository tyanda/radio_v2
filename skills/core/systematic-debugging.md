# Systematic Debugging для Flutter

## Цель

Находить и исправлять баги систематически, а не методом тыка.

## 4-фазный процесс

### Фаза 1: Воспроизведение

**Задача:** Точно определить, когда происходит баг.

```dart
// test/integration/radio_playback_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('воспроизведение радио при переключении станции', (tester) async {
    // TODO: воспроизвести баг шаг за шагом
  });
}
```

**Чеклист:**
- [ ] Описаны шаги для воспроизведения
- [ ] Известен ожидаемый результат
- [ ] Известен фактический результат
- [ ] Баг воспроизводится стабильно

### Фаза 2: Локализация

**Задача:** Найти точное место в коде.

**Методы:**

1. **Бинарный поиск** — комментируй половину кода
2. **Логирование** — добавь `print()` или `debugPrint()`
3. **Breakpoints** — используй отладчик

```dart
// Добавь логирование
void _loadStations() async {
  debugPrint('[_loadStations] Начало загрузки');
  try {
    final response = await _api.getStations();
    debugPrint('[_loadStations] Получено ${response.length} станций');
  } catch (e, st) {
    debugPrint('[_loadStations] Ошибка: $e\n$st');
    rethrow;
  }
}
```

**Чеклист:**
- [ ] Найден файл с багом
- [ ] Найдена функция с багом
- [ ] Найдена строка с багом

### Фаза 3: Анализ причины

**Задача:** Понять **почему** баг происходит.

**5 Почему:**
```
Почему радио не играет? → Потому что станция не загрузилась
Почему станция не загрузилась? → Потому что API вернул ошибку
Почему API вернул ошибку? → Потому что токен истёк
Почему токен истёк? → Потому что нет refresh-логики
Почему нет refresh-логики? → Потому что не реализовано ← КОРЕНЬ
```

**Чеклист:**
- [ ] Найдена корневая причина (root cause)
- [ ] Понятно, почему код ведёт себя так
- [ ] Понятно, как должно работать

### Фаза 4: Исправление

**Задача:** Исправить баг и предотвратить повторение.

```dart
// 1. Исправь баг
Future<void> _loadStations() async {
  state = RadioState(isLoading: true);
  try {
    final stations = await _repository.getStations();
    state = RadioState(stations: stations);
  } catch (e) {
    state = RadioState(error: e.toString());
  }
}

// 2. Добавь тест на этот баг
test('должен_показывать_ошибку_при_сбое_api', () async {
  when(mockRepository.getStations()).thenThrow(Exception('Network'));
  
  final notifier = RadioNotifier(mockRepository);
  
  expect(notifier.state.error, isNotNull);
});
```

**Чеклист:**
- [ ] Баг исправлен
- [ ] Тест проходит
- [ ] Добавлен тест на регрессию
- [ ] Проверены похожие места в коде

## Инструменты

### Flutter DevTools

```bash
# Запустить DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

**Что смотреть:**
- **Performance** — дфризы, медленные фреймы
- **Memory** — утечки памяти
- **Network** — медленные запросы
- **Provider** — состояние Riverpod

### Логирование

```dart
// Включи подробное логирование
flutter run --verbose

// Логи Flutter
adb logcat | grep flutter

// Логи iOS
tail -f /tmp/flutter_tools.*.log
```

## Частые баги во Flutter

### 1. setState во время build

❌ **Плохо:**
```dart
@override
Widget build(BuildContext context) {
  setState(() { ... });  // Ошибка!
  return Container();
}
```

✅ **Хорошо:**
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    setState(() { ... });
  });
}
```

### 2. Утечка StreamSubscription

❌ **Плохо:**
```dart
void initState() {
  stream.listen((data) { ... });  // Нет отписки
}
```

✅ **Хорошо:**
```dart
StreamSubscription? _subscription;

void initState() {
  _subscription = stream.listen((data) { ... });
}

@override
void dispose() {
  _subscription?.cancel();
  super.dispose();
}
```

### 3. Неправильное использование Provider

❌ **Плохо:**
```dart
Widget build(BuildContext context) {
  final state = ref.read(myProvider);  // Пересоздаёт
  return Text(state.toString());
}
```

✅ **Хорошо:**
```dart
Widget build(BuildContext context) {
  final state = ref.watch(myProvider);  // Подписывается
  return Text(state.toString());
}
```

## Шаблон отчёта о баге

```markdown
## Описание
[Что происходит]

## Шаги воспроизведения
1. [Первый шаг]
2. [Второй шаг]
3. [Ожидаемый результат]
4. [Фактический результат]

## Окружение
- Flutter: [версия]
- Устройство: [эмулятор/физическое]
- OS: [Android/iOS/Web]

## Логи
```
[Вставь логи сюда]
```

## Скриншоты/Видео
[Прикрепи если применимо]
```
