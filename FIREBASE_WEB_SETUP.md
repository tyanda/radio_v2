# Настройка Firebase для веб-версии

## ✅ Ключи уже настроены!

Firebase ключи были автоматически добавлены из `google-services.json`:
- **Проект:** sakhalive-ticker
- **API Key:** `AIzaSyApqgccLr4zrPFv5PIXgQiJa4BKfSRkw7Q`

## Структура загрузки ключей

1. **Загрузка из `.env`** (assets) — основной источник
2. **Переопределение из localStorage** — для отладки
3. **Fallback значения** — если ключи всё ещё пустые

## Проверка работы

Откройте консоль браузера (F12) и проверьте логи:
- Должно появиться сообщение: `=== AppConfig initialized (Web) ===`
- `FIREBASE_WEB_API_KEY: SET`
- Ошибки Firebase должны исчезнуть

## Безопасность

Firebase Web API Key **не является секретным ключом** и может храниться в клиентском коде. 
Для дополнительной защиты настройте **Firebase Security Rules** и ограничьте домены в Firebase Console.

---

## Справка: Как получить новые ключи

### Вариант 1: Добавить Firebase Web API Key в `.env`

1. Откройте [Firebase Console](https://console.firebase.google.com/project/sakhalive-ticker/settings/general)
2. Перейдите в раздел **"Ваши приложения"**
3. Найдите **Web App** (или создайте новое, если нет)
4. В разделе **"SDK setup and configuration"** найдите `firebaseConfig`
5. Скопируйте значение `apiKey` (формат: `AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`)
6. Вставьте ключ в файл `.env`:

```env
FIREBASE_WEB_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

7. Пересоберите приложение:
```bash
flutter build web --release
```

### Вариант 2: Использовать localStorage (для разработки)

Откройте консоль браузера (F12) и выполните:

```javascript
localStorage.setItem('FIREBASE_WEB_API_KEY', 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
location.reload();
```

### Вариант 3: Хардкод в `config_web.dart` (не рекомендуется для продакшена)

Откройте `lib/core/config_web.dart` и добавьте ключ напрямую:

```dart
static String firebaseWebApiKey = 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
```
