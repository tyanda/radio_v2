# 🔄 Android → PWA: Что можно перенести

## ✅ Уже работает на PWA

| Функция | Статус | Примечание |
|---------|--------|------------|
| **Кэш новостей** | ✅ Работает | localStorage вместо SharedPreferences |
| **Firebase Realtime Database** | ✅ Работает | ticker сообщения |
| **Аудио плеер** | ✅ Работает | just_audio web |
| **CSP** | ✅ Настроен | Все радиостанции разрешены |
| **PWA Manifest** | ✅ Настроен | Shortcuts, categories |
| **Service Worker** | ✅ Работает | offline-first стратегия |

---

## 📤 Что взять из Android версии

### 1. **Фоновое аудио** ⚠️ Частично
**Android**: `audio_service` с уведомлениями
**PWA**: Media Session API (ограничено)

```javascript
// Можно добавить в flutter.js инициализацию
if ('mediaSession' in navigator) {
  navigator.mediaSession.setActionHandler('play', () => {/* play */});
  navigator.mediaSession.setActionHandler('pause', () => {/* pause */});
  navigator.mediaSession.setActionHandler('previoustrack', () => {/* prev */});
  navigator.mediaSession.setActionHandler('nexttrack', () => {/* next */});
}
```

**Статус**: Требует доработки в `just_audio` для веба

---

### 2. **Push уведомления** ⚠️ Ограничено
**Android**: Firebase Messaging
**PWA**: 
- ✅ Desktop (Chrome, Firefox, Edge)
- ⚠️ iOS 16.4+ (только Safari)
- ❌ iOS < 16.4

**Решение**: Добавить Web Push API

```dart
// lib/services/web_push_service.dart
import 'package:web/web.dart' as web;

class WebPushService {
  static Future<void> requestPermission() async {
    if (web.window.Notification != null) {
      final permission = await web.window.Notification.requestPermission();
      if (permission == 'granted') {
        // Подписка на push
      }
    }
  }
}
```

---

### 3. **Home Widget** ❌ Не работает
**Android**: `home_widget` пакет
**PWA**: Web App Shortcuts (уже добавлено!)

```json
// manifest.json уже имеет shortcuts
"shortcuts": [
  {
    "name": "Радио",
    "short_name": "Радио",
    "url": "/#/radio"
  }
]
```

---

### 4. **Кэш новостей** ✅ Уже работает!
**Android**: SharedPreferences
**PWA**: localStorage

**Текущая реализация** (`news_service.dart`):
```dart
// Кэш работает через SharedPreferences
// На вебе: web.window.localStorage
static const Duration _cacheDuration = Duration(minutes: 15);
```

**Проверка кэша**:
```bash
# Открыть консоль браузера на PWA
localStorage.getItem('news_cache_v3')
localStorage.getItem('news_cache_timestamp_v3')
```

---

### 5. **Геолокация** ✅ Работает
**Android**: `geolocator`
**PWA**: Geolocation API

```dart
// Уже используется в weather_provider.dart
// Работает через browser Geolocation API
```

---

### 6. **Connectivity** ⚠️ Требует проверки
**Android**: `connectivity_plus`
**PWA**: Navigator.onLine

```dart
// lib/core/utils/web_connectivity.dart
import 'package:web/web.dart' as web;

class WebConnectivity {
  static bool get isOnline => web.window.navigator.onLine;
  
  static Stream<bool> get onConnectivityChanged {
    // TODO: слушать online/offline события
  }
}
```

---

### 7. **Share** ✅ Работает
**Android**: `share_plus`
**PWA**: Web Share API

```dart
// Уже работает через share_plus
// Использует navigator.share() на вебе
```

---

### 8. **URL Launcher** ✅ Работает
**Android**: `url_launcher`
**PWA**: window.open()

```dart
// Уже работает
await launchUrl(Uri.parse('https://...'));
```

---

## 🎯 Приоритеты для PWA

### 🔴 Критично
1. **Кэш новостей** — ✅ Уже работает
2. **Аудио на вебе** — ✅ Уже работает

### 🟡 Важно
3. **Media Session API** — Улучшит управление аудио
4. **Web Push** — Для уведомлений (iOS 16.4+)

### 🟢 Желательно
5. **Connectivity monitor** — Для офлайн режима
6. **Install prompt** — Кнопка "Установить приложение"

---

## 📋 Проверка кэша новостей

### Тест 1: Открыть PWA
```
http://localhost:8080
```

### Тест 2: Проверить localStorage
```javascript
// Консоль браузера (F12)
console.log('News cache:', localStorage.getItem('news_cache_v3'));
console.log('Timestamp:', localStorage.getItem('news_cache_timestamp_v3'));
```

### Тест 3: Проверить Provider
```dart
// В коде проверить newsProvider.when
data: (news) => print('News: $news'),
loading: () => print('Loading...'),
error: (e, _) => print('Error: $e'),
```

### Тест 4: Офлайн режим
1. Открыть DevTools → Network
2. Выбрать "Offline"
3. Обновить страницу
4. Кэш должен работать 15 минут

---

## 🔧 Что добавить в PWA

### 1. Install Prompt (кнопка установки)
```html
<!-- Добавить в index.html -->
<div id="install-prompt" hidden>
  <button onclick="installPWA()">Установить приложение</button>
</div>

<script>
let deferredPrompt;
window.addEventListener('beforeinstallprompt', (e) => {
  e.preventDefault();
  deferredPrompt = e;
  document.getElementById('install-prompt').hidden = false;
});

async function installPWA() {
  if (deferredPrompt) {
    deferredPrompt.prompt();
    deferredPrompt.userChoice.then(() => {
      deferredPrompt = null;
    });
  }
}
</script>
```

### 2. Media Session
```dart
// lib/services/web_media_session.dart
import 'package:web/web.dart' as web;

class WebMediaSession {
  static void init() {
    if (web.window.navigator.mediaSession != null) {
      // Настроить media session
    }
  }
  
  static void updateMetadata({
    required String title,
    required String artist,
    required String artwork,
  }) {
    // Обновить метаданные
  }
}
```

---

## ✅ Итог

**Уже работает**:
- ✅ Кэш новостей (localStorage)
- ✅ Firebase (ticker)
- ✅ Аудио плеер
- ✅ Геолокация
- ✅ Share
- ✅ URL Launcher

**Можно улучшить**:
- 🟡 Media Session API
- 🟡 Web Push (iOS 16.4+)
- 🟡 Install Prompt
- 🟡 Connectivity monitor

**Не работает**:
- ❌ Home Widget (но есть Web Shortcuts)
- ❌ Фоновое аудио с уведомлениями (ограничено браузером)
