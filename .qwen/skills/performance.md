# ⚡ Performance Skill

**Навык оптимизации производительности Flutter**

---

## 🎯 Назначение

Этот навык помогает находить и устранять проблемы производительности во Flutter приложении.

---

## 🚀 Использование

```
/perf-check <что проверить>

Примеры:
/perf-check lib/features/radio/presentation/widgets/mini_player.dart
/perf-check весь экран
/perf-check анимации
```

---

## 📋 Чеклист производительности

### 1. Widget Rebuilds

```markdown
## Widget Rebuilds

- [ ] Используется const constructor где возможно
- [ ] RepaintBoundary для сложных виджетов
- [ ] ValueListenableBuilder вместо setState
- [ ] Selector для Riverpod (избегать лишних rebuild)
- [ ] Key для виджетов в списках
```

### 2. Изображения

```markdown
## Изображения

- [ ] Используется cached_network_image
- [ ] Правильные размеры изображений
- [ ] Compress изображений
- [ ] FadeInImage для плавной загрузки
- [ ] Предзагрузка критичных изображений
```

### 3. Анимации

```markdown
## Анимации

- [ ] AnimationController dispose
- [ ] TickerProviderStateMixin используется
- [ ] vsync: this для контроллеров
- [ ] Избегать анимаций в build
- [ ] Использовать AnimatedBuilder
```

### 4. Списки

```markdown
## Списки

- [ ] ListView.builder для длинных списков
- [ ] itemExtent указан
- [ ] addAutomaticKeepAlives: false если не нужно
- [ ] addRepaintBoundaries: false если не нужно
- [ ] CacheExtent для предзагрузки
```

### 5. Async операции

```markdown
## Async операции

- [ ] FutureBuilder используется
- [ ] Изоляция для тяжёлых вычислений (compute)
- [ ] Кэширование результатов
- [ ] Отмена подписок в dispose
- [ ] Debounce для частых операций
```

---

## 🔧 Инструменты

### Flutter DevTools

```markdown
## DevTools

### Performance Tab
- FPS метрика
- Build time
- Raster time
- GPU time

### Memory Tab
- Heap snapshot
- Allocation profile
- Memory leaks

### Widget Inspector
- Build frequency
- Layout bounds
- Repaint rainbow
```

### Performance Overlay

```dart
// Включить оверлей
MaterialApp(
  showPerformanceOverlay: true,
  ...
)
```

### Repaint Rainbow

```dart
// Включить в Debug меню
Debug → Repaint Rainbow
```

---

## 🎯 Оптимизации для Sakha Radio

### MiniPlayer

```dart
// ✅ ПРАВИЛЬНО - const constructor
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key}); // ← const
  
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

// ✅ ПРАВИЛЬНО - Selector для избежания rebuild
Consumer(
  builder: (context, ref, _) {
    final volume = ref.watch(playerProvider.select((s) => s.volume));
    return Text('$volume');
  },
)

// ❌ НЕПРАВИЛЬНО - лишний rebuild
Consumer(
  builder: (context, ref, _) {
    final state = ref.watch(playerProvider); // ← Перестраивается при любом изменении
    return Text('${state.volume}');
  },
)
```

### RadioCardsView

```dart
// ✅ ПРАВИЛЬНО - ListView.builder
ListView.builder(
  itemCount: stations.length,
  itemBuilder: (context, index) => StationCard(stations[index]),
)

// ❌ НЕПРАВИЛЬНО - создание всех виджетов сразу
ListView(
  children: stations.map((s) => StationCard(s)).toList(), // ← Создаёт все сразу!
)

// ✅ ПРАВИЛЬНО - RepaintBoundary для сложных виджетов
RepaintBoundary(
  child: StationCard(station),
)
```

### Анимации

```dart
// ✅ ПРАВИЛЬНО - dispose контроллера
class _MyWidget extends State<MyWidget> with TickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: ...);
  }
  
  @override
  void dispose() {
    _controller.dispose(); // ← Освободить ресурсы
    super.dispose();
  }
}

// ❌ НЕПРАВИЛЬНО - утечка памяти
@override
void dispose() {
  // _controller.dispose(); забыли!
  super.dispose();
}
```

---

## 📊 Метрики производительности

### Целевые показатели

```
✅ FPS: 60 (или 120 для ProMotion)
✅ Build time: <16ms (60 FPS)
✅ Raster time: <8ms
✅ Memory: <100MB в простое
✅ Start time: <2 секунд
```

### Измерение

```bash
# Замерить время запуска
flutter run --profile

# Замерить память
flutter run --profile --trace-startup

# Замерить FPS
flutter run --profile --enable-impeller
```

---

## 🔧 Профилирование

### 1. Найти медленные виджеты

```dart
// Включить debug print
WidgetsBinding.instance.addPostFrameCallback((_) {
  print('Build time: ${stopwatch.elapsedMilliseconds}ms');
});
```

### 2. Найти утечки памяти

```bash
# Сделать heap snapshot
flutter pub global activate devtools
flutter pub global run devtools

# Открыть DevTools → Memory → Heap Snapshot
```

### 3. Найти лишние rebuild

```dart
// Добавить print в build
@override
Widget build(BuildContext context) {
  print('Building ${widget.runtimeType}');
  return Container();
}
```

---

## 🎓 Best Practices

### ✅ DO

```dart
// Использовать const
const SizedBox(height: 16);
const Icon(Icons.play);

// Кэшировать вычисления
final cachedValue = computeExpensiveValue();

// Использовать RepaintBoundary
RepaintBoundary(
  child: ComplexAnimation(),
)

// Selector для Riverpod
final name = ref.watch(provider.select((s) => s.name));
```

### ❌ DON'T

```dart
// Создавать объекты в build
@override
Widget build(BuildContext context) {
  final list = []; // ← Создаётся каждый build!
  final paint = Paint(); // ← Создаётся каждый build!
  return Container();
}

// Лишние rebuild
Consumer(
  builder: (context, ref, _) {
    final state = ref.watch(provider); // ← Полный watch
    return Text(state.name); // ← Используется только name
  },
)

// Забывать dispose
@override
void dispose() {
  // controller.dispose(); забыли!
  super.dispose();
}
```

---

## 📚 Ресурсы

- [Flutter Performance](https://docs.flutter.dev/perf/rendering-performance)
- [DevTools](https://docs.flutter.dev/development/tools/devtools/overview)
- [Performance Best Practices](https://docs.flutter.dev/perf/ui-performance)
