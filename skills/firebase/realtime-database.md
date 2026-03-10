# Firebase Realtime Database для Flutter

## Цель

Правильно работать с Firebase Realtime Database во Flutter-приложении.

## Архитектура проекта

```
lib/
├── features/
│   └── radio/
│       ├── data/
│       │   ├── repositories/
│       │   │   └── radio_repository.dart  # Firebase-вызовы
│       │   └── models/
│       │       └── radio_station.dart
│       └── providers/
│           └── radio_provider.dart  # Riverpod + Firebase
```

## Паттерны

### 1. Repository Pattern

```dart
// lib/features/radio/data/repositories/radio_repository.dart
import 'package:firebase_database/firebase_database.dart';
import '../models/radio_station.dart';

class RadioRepository {
  final DatabaseReference _ref;
  
  RadioRepository({FirebaseDatabase? database})
      : _ref = (database ?? FirebaseDatabase.instance).ref();
  
  // Получить все станции
  Future<List<RadioStation>> getStations() async {
    final snapshot = await _ref.child('stations').get();
    
    if (!snapshot.exists) return [];
    
    final data = snapshot.value as Map;
    return data.entries
        .map((e) => RadioStation.fromJson({
              'id': e.key,
              ...e.value as Map,
            }))
        .toList();
  }
  
  // Подписка на изменения (Stream)
  Stream<List<RadioStation>> watchStations() {
    return _ref.child('stations').onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists) return [];
      
      final data = snapshot.value as Map;
      return data.entries
          .map((e) => RadioStation.fromJson({
                'id': e.key,
                ...e.value as Map,
              }))
          .toList();
    });
  }
  
  // Обновить данные
  Future<void> updateStation(String id, Map<String, dynamic> data) {
    return _ref.child('stations/$id').update(data);
  }
}
```

### 2. Riverpod + Firebase Stream

```dart
// lib/features/radio/providers/radio_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/radio_repository.dart';
import '../data/models/radio_station.dart';

class RadioState {
  final bool isLoading;
  final List<RadioStation> stations;
  final String? error;
  
  RadioState({
    this.isLoading = false,
    this.stations = const [],
    this.error,
  });
}

final radioRepositoryProvider = Provider<RadioRepository>((ref) {
  return RadioRepository();
});

final radioProvider = StreamNotifierProvider<RadioNotifier, RadioState>(() {
  return RadioNotifier();
});

class RadioNotifier extends StreamNotifier<RadioState> {
  @override
  Stream<RadioState> build() {
    final repository = ref.read(radioRepositoryProvider);
    
    return repository.watchStations().map(
      (stations) => RadioState(stations: stations),
    ).handleError(
      (error) => RadioState(error: error.toString()),
    );
  }
}
```

### 3. Модель с fromJson/toJson

```dart
// lib/features/radio/data/models/radio_station.dart
class RadioStation {
  final String id;
  final String name;
  final String streamUrl;
  final String? description;
  final String? logoUrl;
  
  RadioStation({
    required this.id,
    required this.name,
    required this.streamUrl,
    this.description,
    this.logoUrl,
  });
  
  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      id: json['id'] as String,
      name: json['name'] as String,
      streamUrl: json['streamUrl'] as String,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'streamUrl': streamUrl,
      'description': description,
      'logoUrl': logoUrl,
    };
  }
}
```

## Безопасность

### Правила Firebase (firestore.rules / database.rules.json)

```json
{
  "rules": {
    "stations": {
      // Чтение: все могут читать
      ".read": true,
      
      // Запись: только авторизованные
      ".write": "auth != null",
      
      "$stationId": {
        // Валидация данных
        ".validate": "
          newData.hasChildren(['name', 'streamUrl']) &&
          newData.child('name').isString() &&
          newData.child('streamUrl').isString()
        "
      }
    }
  }
}
```

### Деплой правил

```bash
# Проверка правил
firebase deploy --only database:dry-run

# Деплой
firebase deploy --only database
```

## Тестирование

### Mock Firebase

```dart
// test/unit/repositories/radio_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sakha_live/features/radio/data/repositories/radio_repository.dart';

class MockDatabaseReference extends Mock implements DatabaseReference {}
class MockDataSnapshot extends Mock implements DataSnapshot {}

void main() {
  group('RadioRepository', () {
    late MockDatabaseReference mockRef;
    late RadioRepository repository;
    
    setUp(() {
      mockRef = MockDatabaseReference();
      repository = RadioRepository(database: MockFirebaseDatabase(ref: mockRef));
    });
    
    test('должен_возвращать_пустой_список_если_нет_данных', () async {
      when(mockRef.child('stations').get())
          .thenAnswer((_) async => MockDataSnapshot(exists: false));
      
      final stations = await repository.getStations();
      
      expect(stations, isEmpty);
    });
  });
}
```

### Integration Test с Emulator

```bash
# Запустить Firebase Emulator
firebase emulators:start

# Запустить интеграционные тесты
flutter test integration_test/firebase_test.dart
```

## Производительность

### 1. KeepAlive для часто используемых данных

```dart
final radioProvider = StreamNotifierProvider<RadioNotifier, RadioState>(() {
  return RadioNotifier();
}, keepAlive: true);
```

### 2. Кэширование

```dart
class RadioRepository {
  List<RadioStation>? _cachedStations;
  DateTime? _cacheTime;
  
  Future<List<RadioStation>> getStations() async {
    // Вернуть кэш если моложе 5 минут
    if (_cachedStations != null &&
        DateTime.now().difference(_cacheTime!) < Duration(minutes: 5)) {
      return _cachedStations!;
    }
    
    final stations = await _fetchFromFirebase();
    _cachedStations = stations;
    _cacheTime = DateTime.now();
    return stations;
  }
}
```

### 3. Пагинация для больших данных

```dart
Future<List<RadioStation>> getStationsPage({
  String? startAt,
  int limit = 20,
}) async {
  Query query = _ref.child('stations').limitToFirst(limit);
  if (startAt != null) {
    query = query.startAt(startAt);
  }
  
  final snapshot = await query.get();
  // ...
}
```

## Чеклист перед коммитом

- [ ] Repository инкапсулирует Firebase-вызовы
- [ ] Модель имеет fromJson/toJson
- [ ] Stream используется для реального времени
- [ ] Обработаны ошибки (handleError)
- [ ] Правила безопасности настроены
- [ ] Тесты написаны

## Частые ошибки

❌ **Вызов Firebase напрямую в виджете:**
```dart
// ПЛОХО
final snapshot = await FirebaseDatabase.instance.ref().child('stations').get();
```

✅ **Через Repository + Provider:**
```dart
// ХОРОШО
final stations = ref.watch(radioProvider).stations;
```

❌ **Нет обработки ошибок:**
```dart
// ПЛОХО
final data = await ref.child('data').get();
```

✅ **С обработкой:**
```dart
// ХОРОШО
try {
  final data = await ref.child('data').get();
} catch (e) {
  // Обработать ошибку
}
```
