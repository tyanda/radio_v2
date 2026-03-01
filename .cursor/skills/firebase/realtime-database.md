# Firebase Realtime Database

## Работа с Firebase Realtime Database

### Настройка

```dart
// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

### Repository Pattern

```dart
// lib/features/radio/data/repositories/radio_repository.dart
import 'package:firebase_database/firebase_database.dart';

class RadioRepository {
  final DatabaseReference _ref;
  
  RadioRepository({FirebaseDatabase? database})
      : _ref = (database ?? FirebaseDatabase.instance).ref();
  
  // Получить данные один раз
  Future<List<RadioStation>> getStations() async {
    final snapshot = await _ref.child('stations').get();
    if (!snapshot.exists) return [];
    
    return snapshot.children.map((child) {
      return RadioStation.fromJson(
        Map<String, dynamic>.from(child.value as Map),
      );
    }).toList();
  }
  
  // Слушать изменения в реальном времени
  Stream<List<RadioStation>> watchStations() {
    return _ref.child('stations').onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists) return [];
      
      return snapshot.children.map((child) {
        return RadioStation.fromJson(
          Map<String, dynamic>.from(child.value as Map),
        );
      }).toList();
    });
  }
  
  // Добавить данные
  Future<void> addStation(RadioStation station) async {
    await _ref.child('stations').child(station.id).set(station.toJson());
  }
  
  // Обновить данные
  Future<void> updateStation(String id, Map<String, dynamic> data) async {
    await _ref.child('stations').child(id).update(data);
  }
  
  // Удалить данные
  Future<void> deleteStation(String id) async {
    await _ref.child('stations').child(id).remove();
  }
}
```

### Использование с Riverpod

```dart
// lib/features/radio/providers/radio_provider.dart
final radioRepositoryProvider = Provider<RadioRepository>((ref) {
  return RadioRepository();
});

final radioProvider = StreamNotifierProvider<RadioNotifier, RadioState>((ref) {
  return RadioNotifier(ref.read(radioRepositoryProvider));
});

class RadioNotifier extends StreamNotifier<RadioState> {
  final RadioRepository repository;
  
  RadioNotifier(this.repository);
  
  @override
  Stream<RadioState> build() {
    return repository.watchStations().map((stations) {
      return RadioState(stations: stations);
    });
  }
}
```

### Обработка ошибок

```dart
try {
  final stations = await repository.getStations();
  state = RadioState(stations: stations);
} on FirebaseException catch (e) {
  debugPrint('Firebase ошибка: ${e.code} - ${e.message}');
  state = RadioState(error: 'Ошибка подключения к серверу');
} catch (e, st) {
  debugPrint('Неизвестная ошибка: $e\n$st');
  state = RadioState(error: 'Произошла неизвестная ошибка');
}
```

### Query

```dart
// Получить первые 10 станций
final snapshot = await _ref
    .child('stations')
    .orderByChild('name')
    .limitToFirst(10)
    .get();

// Фильтрация
final snapshot = await _ref
    .child('stations')
    .orderByChild('active')
    .equalTo(true)
    .get();
```
