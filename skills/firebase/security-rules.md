# Firebase Security Rules Review

## Цель

Проверять и поддерживать правила безопасности Firebase в актуальном состоянии.

## Структура правил

### Realtime Database (database.rules.json)

```json
{
  "rules": {
    ".read": false,
    ".write": false,
    
    "stations": {
      ".read": true,
      ".write": "auth != null",
      "$stationId": {
        ".validate": "
          newData.hasChildren(['name', 'streamUrl']) &&
          newData.child('name').isString() &&
          newData.child('streamUrl').isString()
        "
      }
    },
    
    "users": {
      "$userId": {
        // Пользователь может читать/писать только свои данные
        ".read": "$userId === auth.uid",
        ".write": "$userId === auth.uid",
        ".validate": "
          newData.hasChildren(['favorites']) &&
          newData.child('favorites').isBoolean()
        "
      }
    },
    
    "analytics": {
      // Только на запись, никто не читает
      ".read": false,
      ".write": "auth != null"
    }
  }
}
```

## Чеклист ревью правил

### 1. Принцип минимальных привилегий

- [ ] Чтение запрещено по умолчанию (`.read: false`)
- [ ] Запись запрещена по умолчанию (`.write: false`)
- [ ] Доступ открыт только к необходимым путям
- [ ] Нет правил вида `".read": true` для чувствительных данных

### 2. Валидация данных

- [ ] Все поля имеют `.validate`
- [ ] Типы данных проверены (`isString()`, `isNumber()`, `isBoolean()`)
- [ ] Обязательные поля проверены через `hasChildren()`
- [ ] Форматы проверены (email, URL через `matches()`)

### 3. Аутентификация

- [ ] Запись требует авторизации (`auth != null`)
- [ ] Пользователи изолированы (`$userId === auth.uid`)
- [ ] Нет записи без авторизации

### 4. Структура путей

- [ ] Пути иерархичны и логичны
- [ ] Wildcard переменные названы понятно (`$userId`, не `$x`)
- [ ] Нет глубокой вложенности (>5 уровней)

## Паттерны безопасности

### 1. Временные метки

```json
"created_at": {
  ".validate": "
    newData.isNumber() &&
    // Только при создании
    (!data.exists() || newData.val() === data.val()) &&
    // Не в будущем
    newData.val() <= now &&
    // Не слишком в прошлом
    newData.val() > (now - 31536000000)
  "
}
```

### 2. Ссылки на другие узлы

```json
"user_id": {
  ".validate": "
    newData.isString() &&
    root.child('users').child(newData.val()).exists()
  "
}
```

### 3. Списки с лимитом

```json
"favorites": {
  ".validate": "newData.isNumber()",
  ".indexOn": ["station_id"],
  "$favoriteId": {
    ".validate": "
      newData.hasChildren(['station_id']) &&
      // Максимум 50 избранного
      data.parent().childrenCount() < 50
    "
  }
}
```

### 4. Санитизация строк

```json
"name": {
  ".validate": "
    newData.isString() &&
    newData.val().length > 0 &&
    newData.val().length <= 100 &&
    // Только буквы, цифры, пробелы
    newData.val().matches('^[a-zA-Zа-яА-ЯёЁ0-9 \\\\-\']+$')
  "
}
```

## Тестирование правил

### Firebase Emulator + Tests

```typescript
// functions/tests/database-rules.test.ts
import { createApplication } from '@firebase/rules-unit-testing';

describe('Database Rules', () => {
  it('должен разрешать чтение stations всем', async () => {
    const app = await createApplication({});
    const db = getDatabase(app);
    
    await assertSucceeds(ref(db, 'stations').get());
  });
  
  it('должен запрещать запись stations без авторизации', async () => {
    const app = await createApplication({});
    const db = getDatabase(app);
    
    await assertFails(ref(db, 'stations/station1').set({ name: 'Test' }));
  });
  
  it('должен разрешать запись stations с авторизацией', async () => {
    const app = await createApplication({
      auth: { uid: 'user123' }
    });
    const db = getDatabase(app);
    
    await assertSucceeds(ref(db, 'stations/station1').set({
      name: 'Test',
      streamUrl: 'http://example.com/stream'
    }));
  });
});
```

### Локальное тестирование

```bash
# Запустить эмулятор
firebase emulators:start --only database

# Запустить тесты
npm run test

# Проверить правила в UI
# Открой http://localhost:4000/database
```

## Деплой

### 1. Проверка перед деплоем

```bash
# Синтаксическая проверка
firebase deploy --only database:dry-run

# Запустить тесты правил
firebase emulators:exec --only database "npm test"
```

### 2. Деплой

```bash
# Деплой только правил
firebase deploy --only database

# Деплой всего проекта
firebase deploy
```

### 3. Rollback (если нужно)

```bash
# Откатить последнюю версию
firebase database:rules:cancel
```

## Мониторинг

### Логи Firebase

```bash
# Просмотр логов в реальном времени
firebase database:log
```

### Firebase Console

1. Открой [Firebase Console](https://console.firebase.google.com/)
2. Выбери проект
3. Realtime Database → Usage
4. Смотри аномалии в чтении/записи

## Частые уязвимости

### ❌ ПЛОХО: Публичная запись

```json
{
  "rules": {
    "stations": {
      ".read": true,
      ".write": true  // ОПАСНО! Любой может писать
    }
  }
}
```

### ❌ ПЛОХО: Нет валидации

```json
{
  "rules": {
    "stations": {
      "$id": {
        ".read": true,
        ".write": "auth != null"
        // Нет .validate - можно писать что угодно
      }
    }
  }
}
```

### ❌ ПЛОХО: Чтение всех пользователей

```json
{
  "rules": {
    "users": {
      ".read": true  // ОПАСНО! Все видят всех пользователей
    }
  }
}
```

### ✅ ХОРОШО: Изоляция пользователей

```json
{
  "rules": {
    "users": {
      "$userId": {
        ".read": "$userId === auth.uid",
        ".write": "$userId === auth.uid",
        ".validate": "newData.hasChildren(['email'])"
      }
    }
  }
}
```

## Шаблон для нового проекта

```json
{
  "rules": {
    ".read": false,
    ".write": false,
    
    "public": {
      ".read": true,
      ".write": false
    },
    
    "users": {
      "$userId": {
        ".read": "$userId === auth.uid",
        ".write": "$userId === auth.uid"
      }
    },
    
    "admin": {
      ".read": "root.child('admin').child(auth.uid).val() === true",
      ".write": "root.child('admin').child(auth.uid).val() === true"
    }
  }
}
```
