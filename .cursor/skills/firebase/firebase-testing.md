# Firebase Testing

## Тестирование с Firebase Emulator

### Настройка эмулятора

```dart
// test/firebase_test_setup.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

Future<void> setupFirebaseEmulator() async {
  await Firebase.initializeApp();
  
  // Подключение к эмулятору
  FirebaseDatabase.instance.setSettings(
    Settings(
      host: 'localhost:9000',
      sslEnabled: false,
      persistenceEnabled: false,
    ),
  );
}

Future<void> clearDatabase() async {
  await FirebaseDatabase.instance.ref().remove();
}
```

### Integration Test

```dart
// test/integration/radio_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  setUpAll(() async {
    await setupFirebaseEmulator();
  });
  
  setUp(() async {
    await clearDatabase();
    
    // Добавить тестовые данные
    await FirebaseDatabase.instance.ref('stations').set({
      'station1': {'id': '1', 'name': 'Europa Plus', 'streamUrl': 'https://...'},
      'station2': {'id': '2', 'name': 'Record', 'streamUrl': 'https://...'},
    });
  });
  
  group('RadioRepository', () {
    test('должен_загружать_станции', () async {
      final repository = RadioRepository();
      final stations = await repository.getStations();
      
      expect(stations, hasLength(2));
      expect(stations.first.name, 'Europa Plus');
    });
    
    test('должен_добавлять_станцию', () async {
      final repository = RadioRepository();
      final station = RadioStation(
        id: '3',
        name: 'Test Radio',
        streamUrl: 'https://test.com/stream',
      );
      
      await repository.addStation(station);
      final stations = await repository.getStations();
      
      expect(stations, hasLength(3));
      expect(stations.any((s) => s.name == 'Test Radio'), isTrue);
    });
    
    test('должен_удалять_станцию', () async {
      final repository = RadioRepository();
      await repository.deleteStation('station1');
      final stations = await repository.getStations();
      
      expect(stations, hasLength(1));
    });
  });
}
```

### Stream Test

```dart
test('должен_слушать_изменения', () async {
  final repository = RadioRepository();
  final stationsStream = repository.watchStations();
  
  final completer = Completer<List<RadioStation>>();
  stationsStream.listen((stations) {
    if (!completer.isCompleted) {
      completer.complete(stations);
    }
  });
  
  // Изменить данные
  await FirebaseDatabase.instance.ref('stations/station3').set({
    'id': '3',
    'name': 'New Station',
    'streamUrl': 'https://new.com/stream',
  });
  
  final stations = await completer.future;
  expect(stations.any((s) => s.name == 'New Station'), isTrue);
});
```

### Запуск тестов с эмулятором

```bash
# Запустить эмулятор
firebase emulators:start --only database &

# Запустить тесты
flutter test test/integration/

# Остановить эмулятор
pkill -f "firebase emulators"
```

### Автоматический запуск

```bash
# Один командой
firebase emulators:exec --only database "flutter test test/integration/"
```

## Mock для Unit Tests

```dart
@GenerateMocks([DatabaseReference, DataSnapshot, FirebaseDatabase])
import 'radio_repository_test.mocks.dart';

void main() {
  test('должен_возвращать_пустой_список', () async {
    final mockRef = MockDatabaseReference();
    final mockSnapshot = MockDataSnapshot();
    final mockDatabase = MockFirebaseDatabase();
    
    when(mockSnapshot.exists).thenReturn(false);
    when(mockRef.get()).thenAnswer((_) async => mockSnapshot);
    when(mockDatabase.ref()).thenReturn(mockRef);
    
    final repository = RadioRepository(database: mockDatabase);
    final stations = await repository.getStations();
    
    expect(stations, isEmpty);
  });
}
```

## Чеклист

- [ ] Эмулятор запущен на порту 9000
- [ ] Данные очищаются перед каждым тестом
- [ ] Тесты изолированы
- [ ] Stream тесты используют Completer
- [ ] Mock объекты для unit тестов
