# 🌐 Web Deployment Guide - Sakha Radio

## ✅ Сборка веб-версии

### 1. Локальная сборка
```bash
flutter build web --release
```

**Результат:**
- Папка: `build/web`
- Размер: ~40 MB (включая шрифты)
- Файлы: HTML, CSS, JS, assets

### 2. Тестирование локально
```bash
# Запуск в Chrome
flutter run -d chrome

# Или локальный сервер
cd build/web
python -m http.server 8080
# Открыть: http://localhost:8080
```

---

## 🚀 Деплой на Firebase Hosting

### Предварительные требования
```bash
# Установить Firebase CLI
npm install -g firebase-tools

# Логин
firebase login
```

### Деплой
```bash
# Сборка
flutter build web --release

# Деплой
firebase deploy --only hosting

# Или полный деплой (hosting + functions + database)
firebase deploy
```

**URL после деплоя:** `https://sakhalive-ticker.web.app`

---

## ⚙️ Конфигурация API ключей для Web

### Вариант 1: Firebase Environment Variables (Рекомендуется)
```bash
firebase functions:config:set \
  openweather.key="YOUR_KEY" \
  api_ninjas.key="YOUR_KEY" \
  api_verve.key="YOUR_KEY"
```

### Вариант 2: localStorage (Текущий)
Открыть консоль браузера (F12) и выполнить:
```javascript
localStorage.setItem('OPENWEATHER_API_KEY', 'your_key_here');
localStorage.setItem('FIREBASE_WEB_API_KEY', 'your_key_here');
localStorage.setItem('API_NINJAS_KEY', 'your_key_here');
localStorage.setItem('API_VERVE_KEY', 'your_key_here');
localStorage.setItem('RSS_FEED_URL', 'https://ysia.ru/feed/');
```

### Вариант 3: .env файл (CI/CD)
Создать `.env` перед сборкой:
```bash
echo "OPENWEATHER_API_KEY=your_key" > .env
# ... остальные ключи
flutter build web --release
```

---

## 🔧 Оптимизация для Web

### 1. Wasm (WebAssembly) - Экспериментально
```bash
flutter build web --release --wasm
```
**Преимущества:**
- Быстрее загрузка
- Лучшая производительность

### 2. CanvasKit vs HTML
```bash
# HTML (меньше размер)
flutter build web --release --web-renderer html

# CanvasKit (лучше качество)
flutter build web --release --web-renderer canvaskit
```

### 3. Tree Shaking
Включён по умолчанию. Уменьшает размер шрифтов на ~95%.

---

## 🐛 CORS Proxy для Web

### Проблема
Браузер блокирует прямые запросы к `horo.mail.ru` из-за CORS.

### Решение
Использовать proxy-сервер:

**Локально:**
```bash
cd cloudflare-worker
npm install
npm run dev
# Proxy: http://localhost:8788
```

**Production:**
Разместить Cloudflare Worker (см. `cloudflare-worker/worker.js`)

---

## 📊 Проверка веб-версии

### Чек-лист
```
[ ] Радио играет
[ ] Переключение станций
[ ] Избранное (пульсация)
[ ] Погода загружается
[ ] Гороскоп работает
[ ] Бегущая строка обновляется
[ ] Адаптивность (мобильная версия)
[ ] Firebase подключён
[ ] Нет ошибок в консоли (F12)
```

### Консоль разработчика
```
F12 → Console
- Проверить на ошибки
- Проверить загрузку ресурсов
- Проверить API запросы (Network tab)
```

---

## 🎯 Production Checklist

```bash
# 1. Обновить version в pubspec.yaml
version: 1.0.0+1

# 2. Сборка
flutter build web --release

# 3. Тест
firebase hosting:channel:deploy test
# URL: https://<channel>-sakhalive-ticker.web.app

# 4. Деплой
firebase deploy --only hosting

# 5. Проверить
# https://sakhalive-ticker.web.app
```

---

## 📈 Мониторинг

### Firebase Console
1. Открыть: https://console.firebase.google.com
2. Проект: sakhalive-ticker
3. Hosting → Проверить статус
4. Analytics → Проверить активность

### Google Analytics
Добавить в `web/index.html`:
```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
```

---

## 🔒 Безопасность

### Никогда не коммитьте API ключи в git!
```bash
# Добавить в .gitignore
.env
firebase.json
**/config_*.dart
```

### Используйте Firebase Security Rules
```javascript
// firebase.json
{
  "hosting": {
    "headers": [
      {
        "source": "**",
        "headers": [
          {
            "key": "X-Content-Type-Options",
            "value": "nosniff"
          }
        ]
      }
    ]
  }
}
```

---

## 🆘 Troubleshooting

### Ошибка: "Failed to load API"
**Решение:** Проверить API ключи в localStorage

### Ошибка: "CORS blocked"
**Решение:** Использовать proxy-сервер

### Ошибка: "Firebase not initialized"
**Решение:** Проверить `firebase_options.dart` и ключи

### Белый экран
**Решение:** 
1. Открыть консоль (F12)
2. Проверить ошибки
3. Проверить загрузку `flutter_bootstrap.js`

---

## 📞 Контакты

Вопросы и предложения: [Your Contact]

**Документация:**
- [Flutter Web](https://docs.flutter.dev/platform-integration/web)
- [Firebase Hosting](https://firebase.google.com/docs/hosting)
- [Wasm](https://docs.flutter.dev/platform-integration/web/wasm)
