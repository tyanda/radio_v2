# 📱 PWA Инструкция по установке на iPhone

## ✅ Что готово

PWA (Progressive Web App) для SakhaLive Radio полностью настроено:

- ✅ Service Worker с кэшированием
- ✅ iOS meta-теги для установки на домашний экран
- ✅ Manifest.json с правильной конфигурацией
- ✅ Адаптивный дизайн для мобильных устройств
- ✅ Поддержка safe area для iPhone X и новее
- ✅ Отключен зум и выделение текста
- ✅ Fullscreen режим без адресной строки

---

## 🚀 Как запустить PWA

### Вариант 1: Локальный сервер (для тестирования)

```bash
# Запуск локального сервера
cd build/web
python -m http.server 8080

# Или используйте npx
npx serve build/web
```

Откройте в Safari на iPhone: `http://<IP-адрес-компьютера>:8080`

### Вариант 2: Firebase Hosting (рекомендуется)

```bash
# Деплой на Firebase
firebase deploy --only hosting

# После деплоя откройте URL в Safari
# https://sakhalive.web.app
```

### Вариант 3: Любой HTTPS сервер

PWA требует **HTTPS** (кроме localhost)!

---

## 📲 Как установить на iPhone (iOS)

### Шаг 1: Откройте в Safari
1. Откройте Safari на iPhone
2. Перейдите на URL вашего PWA (например, `https://sakhalive.web.app`)

### Шаг 2: Нажмите "Поделиться"
Нажмите иконку **"Поделиться"** в нижней панели Safari (квадрат со стрелкой вверх)

### Шаг 3: "На экран «Домой»"
Прокрутите вниз и выберите **"На экран «Домой»** (Add to Home Screen)

### Шаг 4: Подтвердите
Введите название (например, "SakhaLive") и нажмите **"Добавить"**

### Готово! 🎉
Иконка появится на домашнем экране. При запуске:
- ✅ Откроется без адресной строки (fullscreen)
- ✅ Работает как нативное приложение
- ✅ Кэшируется для офлайн-доступа

---

## 📲 Как установить на Android

### Вариант 1: Через браузер
1. Откройте Chrome на Android
2. Перейдите на сайт PWA
3. Появится уведомление "Установить приложение"
4. Нажмите **"Установить"**

### Вариант 2: Через меню
1. Откройте сайт в Chrome
2. Нажмите ⋮ (три точки) → **"Установить приложение"**

---

## ⚙️ Технические детали

### Manifest.json
```json
{
  "name": "SakhaLive Radio",
  "short_name": "SakhaLive",
  "display": "standalone",
  "start_url": "/",
  "background_color": "#0A0A0A",
  "theme_color": "#0A0A0A"
}
```

### Service Worker
- **Стратегия**: online-first с кэшированием
- **Кэш**: Все ресурсы кэшируются после первой загрузки
- **Обновление**: При изменении версии service worker

### iOS PWA возможности
- ✅ Fullscreen режим
- ✅ Иконка на домашнем экране
- ✅ Splash screen
- ✅ Работа в фоне (ограничено)
- ⚠️ Push уведомления не поддерживаются на iOS < 16.4
- ⚠️ Фоновое аудио может быть ограничено

---

## 🔧 Тестирование PWA

### Lighthouse (Chrome DevTools)
1. Откройте Chrome DevTools (F12)
2. Вкладка **Lighthouse**
3. Выберите **PWA**
4. Нажмите **Analyze page load**

### Проверка Service Worker
1. Откройте DevTools → **Application**
2. Раздел **Service Workers**
3. Проверьте статус: **activated**

### Тест офлайн-режима
1. Откройте DevTools → **Network**
2. Выберите **Offline**
3. Обновите страницу
4. Приложение должно загрузиться из кэша

---

## 🐛 Возможные проблемы

### 1. PWA не устанавливается
- ✅ Проверьте HTTPS (или localhost)
- ✅ Проверьте manifest.json валидность
- ✅ Service Worker должен быть активен

### 2. Аудио не работает в фоне
- iOS ограничивает фоновое аудио в PWA
- Используйте нативное приложение для полной поддержки

### 3. Push уведомления не работают
- iOS < 16.4 не поддерживает push в PWA
- Требуется iOS 16.4+

---

## 📊 Размер сборки

```
build/web/
├── main.dart.js      (~2-3 MB сжатый)
├── flutter.js        (~15 KB)
├── manifest.json     (~1.5 KB)
└── assets/           (~5-10 MB)
```

**Итого**: ~15-20 MB (кэшируется после первой загрузки)

---

## 🔗 Ссылки

- [Apple PWA Documentation](https://developer.apple.com/documentation/webkit/making_add_to_home_screen_more_powerful)
- [MDN PWA Guide](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps)
- [Flutter Web Deployment](https://docs.flutter.dev/platform-integration/web/initialization)

---

**Собрано**: 8 марта 2026 г.  
**Версия**: 1.0.6+3  
**Стратегия**: offline-first
