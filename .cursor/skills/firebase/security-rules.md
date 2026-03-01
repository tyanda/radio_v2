# Firebase Security Rules

## Правила безопасности Firebase

### Базовые правила

```json
{
  "rules": {
    "stations": {
      ".read": true,
      ".write": "auth != null"
    },
    "settings": {
      ".read": "auth != null",
      ".write": "auth != null && auth.uid === 'admin_uid'"
    }
  }
}
```

### Валидация данных

```json
{
  "rules": {
    "stations": {
      "$stationId": {
        ".read": true,
        ".write": "auth != null",
        ".validate": "
          newData.hasChildren(['id', 'name', 'streamUrl']) &&
          newData.child('id').isString() &&
          newData.child('name').isString() &&
          newData.child('name').val().length > 0 &&
          newData.child('streamUrl').isString() &&
          newData.child('streamUrl').val().matches(/^https?:\\/\\/.*/)
        "
      }
    }
  }
}
```

### Правила для пользователей

```json
{
  "rules": {
    "users": {
      "$userId": {
        ".read": "$userId === auth.uid",
        ".write": "$userId === auth.uid",
        ".validate": "
          newData.hasChildren(['email', 'favorites']) &&
          newData.child('email').isString()
        "
      }
    },
    "favorites": {
      "$userId": {
        ".read": "$userId === auth.uid",
        ".write": "$userId === auth.uid"
      }
    }
  }
}
```

### Rate Limiting

```json
{
  "rules": {
    "stations": {
      ".read": true,
      ".write": "auth != null",
      ".indexOn": ["name", "active"]
    },
    "requests": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid",
        ".validate": "
          !data.exists() || 
          (now - data.child('lastRequest').val() > 60000)
        "
      }
    }
  }
}
```

### Проверка перед деплоем

```bash
# Проверка синтаксиса
firebase deploy --only database:dry-run

# Запуск тестов правил
firebase emulators:exec --only database "npm test"
```

### Тестирование правил

```dart
import 'package:firebase_database/firebase_database.dart';

void main() {
  setUpAll(() async {
    await Firebase.initializeApp();
    
    // Подключение к эмулятору
    FirebaseDatabase.instance.setSettings(
      Settings(host: 'localhost:9000', sslEnabled: false),
    );
  });
  
  test('должен_разрешать_чтение_станций', () async {
    final snapshot = await FirebaseDatabase.instance
        .ref('stations')
        .get();
    
    expect(snapshot.exists, isTrue);
  });
  
  test('должен_запрещать_запись_без_авторизации', () async {
    expect(
      () => FirebaseDatabase.instance
          .ref('stations')
          .child('test')
          .set({'name': 'Test'}),
      throwsA(isA<FirebaseException>()),
    );
  });
}
```

## Лучшие практики

1. **Минимальные привилегии** — Давай только необходимые права
2. **Валидация на сервере** — Не доверяй клиенту
3. **Индексы** — Добавляй `.indexOn` для query
4. **Тестирование** — Проверяй правила с эмулятором
