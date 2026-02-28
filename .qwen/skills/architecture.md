# 🏗️ Architecture Skill

**Навык проверки соответствия чистой архитектуре**

---

## 🎯 Назначение

Этот навык обеспечивает соблюдение принципов Clean Architecture в Flutter проекте.

---

## 📐 Слои архитектуры

```
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │   Widgets   │  │   Screens   │  │  Providers  │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
└─────────────────────────────────────────────────────────┘
                          ↓ depends on
┌─────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │  Entities   │  │  Use Cases  │  │ Repositories│     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
└─────────────────────────────────────────────────────────┘
                          ↓ depends on
┌─────────────────────────────────────────────────────────┐
│                      DATA LAYER                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │   Models    │  │  Services   │  │  Data Sources│    │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
└─────────────────────────────────────────────────────────┘
```

---

## ✅ Чеклист архитектуры

```markdown
## Architecture Checklist

### Presentation Layer
- [ ] Виджеты не зависят от Data слоя
- [ ] Providers в core/providers.dart
- [ ] Нет прямой зависимости на сервисы
- [ ] UI логика в StateNotifier/Notifier

### Domain Layer
- [ ] Entities чистые (без зависимостей)
- [ ] Use Cases инкапсулируют бизнес логику
- [ ] Repository interfaces в domain

### Data Layer
- [ ] Models реализуют Entities
- [ ] Services инкапсулируют внешние API
- [ ] Data Sources абстрагированы

### Dependencies
- [ ] Presentation → Domain
- [ ] Domain → Domain (нет зависимостей на другие слои)
- [ ] Data → Domain
- [ ] Нет циклических зависимостей
```

---

## 🚀 Использование

```
/arch-check <файл или папка>

Примеры:
/arch-check lib/features/radio
/arch-check весь проект
```

---

## 📋 Структура проекта

```
lib/
├── main.dart
├── firebase_options.dart
│
├── core/                      # Общие компоненты
│   ├── design/                # Дизайн система
│   │   ├── design.dart
│   │   ├── design_tokens.dart
│   │   ├── spacing.dart
│   │   ├── effects.dart
│   │   └── typography.dart
│   │
│   ├── providers.dart         # Riverpod providers
│   │
│   ├── config.dart            # Конфигурация
│   │
│   └── utils/                 # Утилиты
│       ├── logger.dart
│       └── snackbar_helper.dart
│
├── features/                  # Фичи
│   ├── radio/                 # Радио фича
│   │   ├── presentation/      # UI слой
│   │   │   ├── widgets/
│   │   │   │   ├── radio_view.dart
│   │   │   │   ├── mini_player.dart
│   │   │   │   └── radio_cards_view.dart
│   │   │   └── providers/
│   │   │       └── player_provider.dart
│   │   │
│   │   ├── domain/            # Бизнес логика
│   │   │   ├── entities/
│   │   │   │   └── station.dart
│   │   │   └── repositories/
│   │   │       └── radio_repository.dart
│   │   │
│   │   └── data/              # Data слой
│   │       ├── models/
│   │       │   └── station_model.dart
│   │       ├── services/
│   │       │   └── audio_service.dart
│   │       └── datasources/
│   │           └── radio_datasource.dart
│   │
│   ├── weather/               # Погода фича
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   │
│   └── horoscope/             # Гороскоп фича
│       ├── presentation/
│       ├── domain/
│       └── data/
│
└── widgets/                   # Переиспользуемые виджеты
    ├── splash_screen.dart
    ├── shimmer_widget.dart
    ├── equalizer_animation.dart
    └── scroll_scale_card.dart
```

---

## 🔧 Проверка архитектуры

### Автоматические проверки

```dart
// test/architecture/architecture_test.dart

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Architecture Tests', () {
    test('Widgets не должны импортировать Data слой', () {
      // Проверить что виджеты не импортируют
      // lib/features/*/data/**
    });

    test('Domain слой не должен импортировать Flutter', () {
      // Проверить что domain не импортирует
      // package:flutter/material.dart
    });

    test('Providers должны быть в core/providers.dart', () {
      // Проверить что все providers экспортируются
      // из core/providers.dart
    });
  });
}
```

---

## 🎓 Best Practices

### ✅ DO

```dart
// Presentation зависит от Domain
import '../../domain/entities/station.dart';

class PlayerNotifier extends StateNotifier<PlayerState> {
  final RadioRepository repository; // ← Interface из domain
  
  PlayerNotifier(this.repository);
}

// Data реализует Domain
class RadioRepositoryImpl implements RadioRepository {
  @override
  Future<Station> getStation() async {
    // Реализация
  }
}
```

### ❌ DON'T

```dart
// Presentation НЕ должна зависеть от Data
import '../../data/models/station_model.dart'; // ❌

// Domain НЕ должна зависеть от Flutter
import 'package:flutter/material.dart'; // ❌

// Виджеты НЕ должны создавать сервисы напрямую
class MyWidget extends StatelessWidget {
  final service = AudioService(); // ❌ Используйте providers!
}
```

---

## 📚 Ресурсы

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Riverpod Best Practices](https://riverpod.dev/)
