# Firebase Testing

## Цель

Тестировать интеграцию с Firebase надёжно и быстро.

## Уровни тестирования

### 1. Unit-тесты с моками

```dart
// test/unit/repositories/radio_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:radio_v2/features/radio/data/repositories/radio_repository.dart';
import 'package:radio_v2/features/radio/data/models/radio_station.dart';

@GenerateMocks([DatabaseReference, DataSnapshot, FirebaseDatabase])
import 'radio_repository_test.mocks.dart';

void main() {
  group('RadioRepository', () {
    late MockDatabaseReference mockRef;
    late MockDataSnapshot mockSnapshot;
    late RadioRepository repository;
    
    setUp(() {
      mockRef = MockDatabaseReference();
      mockSnapshot = MockDataSnapshot();
      
      final mockDatabase = MockFirebaseDatabase();
      when(mockDatabase.ref()).thenReturn(mockRef);
      
      repository = RadioRepository(database: mockDatabase);
    });
    
    group('getStations', () {
      test('должен_возвращать_пустой_список_если_данных_нет', () async {
        // Arrange
        when(mockRef.child('stations')).thenReturn(mockRef);
        when(mockSnapshot.exists).thenReturn(false);
        when(mockRef.get()).thenAnswer((_) async => mockSnapshot);
        
        // Act
        final result = await repository.getStations();
        
        // Assert
        expect(result, isEmpty);
        verify(mockRef.child('stations')).called(1);
      });
      
      test('должен_возвращать_список_станций', () async {
        // Arrange
        final stationsData = {
          'station1': {'name': 'Europa Plus', 'streamUrl': 'http://...'},
          'station2': {'name': 'Radio 1', 'streamUrl': 'http://...'},
        };
        
        when(mockRef.child('stations')).thenReturn(mockRef);
        when(mockSnapshot.exists).thenReturn(true);
        when(mockSnapshot.value).thenReturn(stationsData);
        when(mockRef.get()).thenAnswer((_) async => mockSnapshot);
        
        // Act
        final result = await repository.getStations();
        
        // Assert
        expect(result.length, 2);
        expect(result.first.name, 'Europa Plus');
      });
      
      test('должен_выбрасывать_ошибку_при_сбое', () async {
        // Arrange
        when(mockRef.child('stations')).thenReturn(mockRef);
        when(mockRef.get()).thenThrow(Exception('Network error'));
        
        // Act & Assert
        expect(
          () => repository.getStations(),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
```

### 2. Integration-тесты с Emulator

```dart
// test/integration/firebase_radio_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:radio_v2/firebase_options.dart';
import 'package:radio_v2/features/radio/data/repositories/radio_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  late FirebaseDatabase database;
  late RadioRepository repository;
  
  setUpAll(() async {
    // Инициализация Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Подключение к эмулятору
    database = FirebaseDatabase.instance;
    database.setSettings(
      Settings(
        host: 'localhost:9000',
        sslEnabled: false,
      ),
    );
    
    repository = RadioRepository(database: database);
    
    // Очистка перед тестами
    await database.ref().remove();
  });
  
  tearDown(() async {
    // Очистка после каждого теста
    await database.ref().remove();
  });
  
  group('Firebase Radio Integration', () {
    testWidgets('должен_сохранять_и_читать_станции', (tester) async {
      // Arrange
      final testStation = {
        'name': 'Test Radio',
        'streamUrl': 'http://test.com/stream',
        'description': 'Test Description',
      };
      
      // Act - Сохранение
      await database.ref('stations/station1').set(testStation);
      
      // Act - Чтение
      final stations = await repository.getStations();
      
      // Assert
      expect(stations.length, 1);
      expect(stations.first.name, 'Test Radio');
      expect(stations.first.streamUrl, 'http://test.com/stream');
    });
    
    testWidgets('должен_получать_обновления_в_реальном_времени', (tester) async {
      // Arrange
      final completer = Completer<List<RadioStation>>();
      late StreamSubscription subscription;
      
      subscription = repository.watchStations().listen((stations) {
        if (stations.isNotEmpty) {
          completer.complete(stations);
        }
      });
      
      // Act - Добавление станции
      await database.ref('stations/station1').set({
        'name': 'Live Radio',
        'streamUrl': 'http://live.com/stream',
      });
      
      // Assert
      final stations = await completer.future;
      expect(stations.first.name, 'Live Radio');
      
      await subscription.cancel();
    });
    
    testWidgets('должен_удалять_станции', (tester) async {
      // Arrange
      await database.ref('stations/station1').set({
        'name': 'To Delete',
        'streamUrl': 'http://delete.com/stream',
      });
      
      // Act - Удаление
      await database.ref('stations/station1').remove();
      
      // Assert
      final stations = await repository.getStations();
      expect(stations, isEmpty);
    });
  });
}
```

### 3. Rules Unit Testing (TypeScript)

```typescript
// functions/tests/database-rules.test.ts
import {
  createApplication,
  assertSucceeds,
  assertFails,
} from '@firebase/rules-unit-testing';
import { getDatabase, ref, set, get } from 'firebase/database';

describe('Database Security Rules', () => {
  it('должен_разрешать_чтение_stations_всем', async () => {
    const app = await createApplication({});
    const db = getDatabase(app);
    
    // Сначала добавим данные
    await set(ref(db, 'stations/station1'), {
      name: 'Test Station',
      streamUrl: 'http://test.com',
    });
    
    // Проверяем чтение
    await assertSucceeds(get(ref(db, 'stations')));
  });
  
  it('должен_запрещать_запись_stations_без_авторизации', async () => {
    const app = await createApplication({});
    const db = getDatabase(app);
    
    await assertFails(set(ref(db, 'stations/new_station'), {
      name: 'Hacked',
      streamUrl: 'http://evil.com',
    }));
  });
  
  it('должен_разрешать_запись_stations_с_авторизацией', async () => {
    const app = await createApplication({
      auth: { uid: 'admin123' },
    });
    const db = getDatabase(app);
    
    await assertSucceeds(set(ref(db, 'stations/station1'), {
      name: 'Legit Station',
      streamUrl: 'http://legit.com/stream',
    }));
  });
  
  it('должен_требовать_name_и_streamUrl', async () => {
    const app = await createApplication({
      auth: { uid: 'admin123' },
    });
    const db = getDatabase(app);
    
    // Без name
    await assertFails(set(ref(db, 'stations/station1'), {
      streamUrl: 'http://test.com',
    }));
    
    // Без streamUrl
    await assertFails(set(ref(db, 'stations/station1'), {
      name: 'Test',
    }));
    
    // С обоими полями
    await assertSucceeds(set(ref(db, 'stations/station1'), {
      name: 'Test',
      streamUrl: 'http://test.com',
    }));
  });
});
```

## Запуск тестов

### Локально с эмулятором

```bash
# 1. Запустить Firebase Emulator
firebase emulators:start --only database &

# 2. Подождать запуска эмулятора
sleep 5

# 3. Запустить Dart/Flutter тесты
flutter test test/integration/

# 4. Запустить TypeScript тесты правил
npm run test

# 5. Остановить эмулятор
firebase emulators:export ./emulator-data
pkill -f "firebase emulators"
```

### CI/CD (GitHub Actions)

```yaml
# .github/workflows/firebase-test.yml
name: Firebase Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      firebase-emulator:
        image: google/cloud-sdk:latest
        ports:
          - 9000:9000
        options: >-
          --name firebase-emulator
          -d
          firebase emulators:start --only database --host 0.0.0.0
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: subosito/flutter-action@v2
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Wait for emulator
        run: sleep 10
      
      - name: Run integration tests
        run: |
          export FIREBASE_DATABASE_EMULATOR_HOST=localhost:9000
          flutter test test/integration/
```

## Mock-утилиты

### Test Helpers

```dart
// test/helpers/firebase_test_helpers.dart
import 'package:firebase_database/firebase_database.dart';

class FirebaseTestHelpers {
  // Очистить базу данных
  static Future<void> clearDatabase(FirebaseDatabase database) async {
    await database.ref().remove();
  }
  
  // Создать тестовую станцию
  static Map<String, dynamic> createTestStation({
    String name = 'Test Station',
    String url = 'http://test.com/stream',
  }) {
    return {
      'name': name,
      'streamUrl': url,
      'description': 'Test station for testing',
    };
  }
  
  // Заполнить тестовыми данными
  static Future<void> seedDatabase(
    FirebaseDatabase database,
    List<Map<String, dynamic>> stations,
  ) async {
    for (var i = 0; i < stations.length; i++) {
      await database.ref('stations/station$i').set(stations[i]);
    }
  }
}
```

## Отладка

### Включить логирование

```dart
// main_test.dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // Включить подробное логирование Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Для отладки эмулятора
  FirebaseDatabase.instance.setLoggingEnabled(true);
  
  runApp(TestApp());
}
```

### Просмотр логов эмулятора

```bash
# Логи эмулятора в реальном времени
tail -f ~/.cache/firebase/emulators/firebase-debug.log

# Логи правил безопасности
tail -f ~/.cache/firebase/emulators/firestore-debug.log
```

## Чеклист

- [ ] Unit-тесты с моками покрывают repository
- [ ] Integration-тесты с эмулятором работают
- [ ] Правила безопасности протестированы
- [ ] Тесты изолированы (очистка после каждого)
- [ ] Тесты быстрые (<10 секунд каждый)
- [ ] CI запускает тесты автоматически
