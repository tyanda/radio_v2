# Feature-First Structure

## Архитектура по фичам

### Структура проекта

```
lib/
├── core/                    # Общие компоненты
│   ├── design/              # Дизайн-токены, тема
│   ├── providers/           # Глобальные providers
│   ├── utils/               # Утилиты
│   └── constants/           # Константы
│
├── features/                # Фичи
│   ├── home/                # Главная страница
│   │   ├── widgets/
│   │   └── providers/
│   │
│   ├── radio/               # Радио
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── providers/
│   │   └── widgets/
│   │
│   ├── weather/             # Погода
│   │   ├── data/
│   │   ├── providers/
│   │   └── widgets/
│   │
│   └── horoscope/           # Гороскоп
│       ├── data/
│       ├── providers/
│       └── widgets/
│
├── widgets/                 # Переиспользуемые виджеты
├── services/                # Сервисы (audio, location)
└── l10n/                    # Локализация
```

### Структура фичи

```
features/radio/
├── data/
│   ├── models/
│   │   └── radio_station.dart       # Модель данных
│   └── repositories/
│       └── radio_repository.dart    # Доступ к данным
│
├── providers/
│   └── radio_provider.dart          # State management
│
└── widgets/
    ├── radio_player.dart            # Основной виджет
    ├── station_list.dart            # Список станций
    └── station_tile.dart            # Элемент станции
```

### Модель данных

```dart
// lib/features/radio/data/models/radio_station.dart
class RadioStation {
  final String id;
  final String name;
  final String streamUrl;
  final String? logoUrl;
  final String? description;
  
  RadioStation({
    required this.id,
    required this.name,
    required this.streamUrl,
    this.logoUrl,
    this.description,
  });
  
  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      id: json['id'] as String,
      name: json['name'] as String,
      streamUrl: json['streamUrl'] as String,
      logoUrl: json['logoUrl'] as String?,
      description: json['description'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'streamUrl': streamUrl,
      'logoUrl': logoUrl,
      'description': description,
    };
  }
}
```

### Repository

```dart
// lib/features/radio/data/repositories/radio_repository.dart
class RadioRepository {
  final DatabaseReference _ref;
  
  RadioRepository({FirebaseDatabase? database})
      : _ref = (database ?? FirebaseDatabase.instance).ref();
  
  Future<List<RadioStation>> getStations() async {
    final snapshot = await _ref.child('stations').get();
    if (!snapshot.exists) return [];
    
    return (snapshot.children.map((child) {
      return RadioStation.fromJson(
        Map<String, dynamic>.from(child.value as Map),
      );
    }).toList());
  }
  
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
}
```

### Provider

```dart
// lib/features/radio/providers/radio_provider.dart
final radioRepositoryProvider = Provider<RadioRepository>((ref) {
  return RadioRepository();
});

final radioProvider = StreamNotifierProvider<RadioNotifier, RadioState>((ref) {
  return RadioNotifier(ref.read(radioRepositoryProvider));
});
```

### Widget

```dart
// lib/features/radio/widgets/radio_player.dart
class RadioPlayer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(radioProvider);
    
    return Column(
      children: [
        for (final station in state.stations)
          StationTile(station: station),
      ],
    );
  }
}
```

## Преимущества

1. **Изоляция** — Каждая фича независима
2. **Масштабируемость** — Легко добавлять новые фичи
3. **Тестируемость** — Тесты рядом с кодом
4. **Понятность** — Ясная структура
