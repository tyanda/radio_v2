# 🔒 Security Skill

**Навык проверки безопасности**

---

## 🎯 Назначение

Этот навык обеспечивает проверку кода на уязвимости безопасности и соответствие best practices.

---

## 🚀 Использование

```
/security-check <файл или папка>

Примеры:
/security-check lib/services
/security-check весь проект
/security-check API ключи
```

---

## 📋 Чеклист безопасности

### 1. API Ключи и Секреты

```markdown
## API Keys & Secrets

- [ ] Нет hardcoded API ключей в коде
- [ ] Ключи в .env файле
- [ ] .env в .gitignore
- [ ] Используется flutter_dotenv
- [ ] Ключи не логируются
```

### 2. Сетевая безопасность

```markdown
## Network Security

- [ ] HTTPS для всех запросов
- [ ] Certificate pinning (если нужно)
- [ ] Валидация SSL сертификатов
- [ ] Нет HTTP запросов
- [ ] Timeout для запросов
```

### 3. Обработка данных

```markdown
## Data Handling

- [ ] Санитизация пользовательских данных
- [ ] Валидация входных данных
- [ ] Нет eval / exec
- [ ] SQL injection защита
- [ ] XSS защита (для web)
```

### 4. Хранение данных

```markdown
## Data Storage

- [ ] Чувствительные данные зашифрованы
- [ ] Используется flutter_secure_storage
- [ ] Нет паролей в SharedPreferences
- [ ] Кэш очищается при выходе
- [ ] Биометрия для критичных данных
```

### 5. Логирование

```markdown
## Logging

- [ ] Нет sensitive данных в логах
- [ ] Логи отключены в production
- [ ] Нет паролей/токенов в логах
- [ ] Используется Logger с уровнями
- [ ] Логи не пишутся в файл без шифрования
```

---

## 🔧 Проверки

### 1. Поиск hardcoded ключей

```bash
# Поиск потенциальных ключей
grep -r "api_key" lib/
grep -r "API_KEY" lib/
grep -r "secret" lib/
grep -r "password" lib/
grep -r "token" lib/
```

### 2. Проверка зависимостей

```bash
# Проверить на уязвимости
flutter pub outdated
dart pub audit
```

### 3. Анализ кода

```bash
# Статический анализ
flutter analyze

# Проверить security
dart pub global activate security
security check
```

---

## 🎯 Security для Sakha Radio

### .env конфигурация

```bash
# .env (добавить в .gitignore!)
API_URL=https://api.sakhalive.ru
API_KEY=your_secret_key_here
FIREBASE_API_KEY=your_firebase_key
```

```dart
// lib/core/config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiUrl => dotenv.env['API_URL'] ?? '';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
  
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
  }
}
```

### Безопасное логирование

```dart
// ✅ ПРАВИЛЬНО
Logger.log('Playing station: ${station.name}'); // ← Только название
Logger.log('User ID: ${user.id}'); // ← Только ID, не данные

// ❌ НЕПРАВИЛЬНО
Logger.log('API Key: ${AppConfig.apiKey}'); // ← Никогда не логировать ключи!
Logger.log('Token: $authToken'); // ← Никогда не логировать токены!
Logger.log('Password: $password'); // ← Никогда не логировать пароли!
```

### Безопасная сеть

```dart
// ✅ ПРАВИЛЬНО - HTTPS
final url = Uri.https('api.sakhalive.ru', '/stations');

// ❌ НЕПРАВИЛЬНО - HTTP
final url = Uri.http('api.sakhalive.ru', '/stations'); // ← Небезопасно!
```

---

## 📋 Security Review Template

```markdown
## Security Review Report

### Дата
<дата проверки>

### Область проверки
<файлы/модули>

### Найденные проблемы

#### 🔴 Critical (0)
<критичные уязвимости>

#### 🟠 High (0)
<серьёзные проблемы>

#### 🟡 Medium (0)
<проблемы средней важности>

#### 🟢 Low (0)
<незначительные проблемы>

### Рекомендации

1. <рекомендация 1>
2. <рекомендация 2>

### Статус
✅ PASS / ❌ FAIL
```

---

## 🎓 Best Practices

### ✅ DO

```dart
// Использовать .env для секретов
final apiKey = dotenv.env['API_KEY'];

// HTTPS для всех запросов
final url = Uri.https('api.example.com', '/path');

// Валидация данных
if (input.isEmpty || input.length > 100) {
  throw ValidationException('Invalid input');
}

// Безопасное хранение
await FlutterSecureStorage().write(key: 'token', value: encryptedToken);

// Отключение логов в production
if (!kReleaseMode) {
  Logger.log('Debug: $value');
}
```

### ❌ DON'T

```dart
// Hardcoded ключи
const apiKey = 'sk_1234567890'; // ❌

// HTTP запросы
final url = Uri.http('api.example.com'); // ❌

// Логирование секретов
Logger.log('Token: $token'); // ❌

// Eval / exec
eval(userInput); // ❌

// Сохранение паролей
await prefs.setString('password', password); // ❌
```

---

## 🔐 Шифрование данных

### Для чувствительных данных

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorage = FlutterSecureStorage();

// Сохранение
await secureStorage.write(key: 'auth_token', value: encryptedToken);

// Чтение
final token = await secureStorage.read(key: 'auth_token');

// Удаление
await secureStorage.delete(key: 'auth_token');
```

---

## 📚 Ресурсы

- [OWASP Mobile Top 10](https://owasp.org/www-project-mobile-top-10/)
- [Flutter Security](https://docs.flutter.dev/security)
- [Dart Security](https://dart.dev/security)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
