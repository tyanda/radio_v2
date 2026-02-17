# Настройка Google Apps Script для RSS

## Что это такое
Google Apps Script — это бесплатная платформа от Google для запуска скриптов в облаке. Мы используем её как CORS-прокси для получения RSS-ленты ysia.ru.

## Преимущества
- ✅ **Бесплатно** — 20,000 запросов/день (хватит надолго)
- ✅ **Надёжно** — инфраструктура Google (99.9% uptime)
- ✅ **Быстро** — кэширование на стороне Google
- ✅ **Нет CORS** — скрипт работает на сервере Google
- ✅ **Простая настройка** — 5 минут

## Инструкция

### Шаг 1: Создайте скрипт

1. Перейдите на https://script.google.com/
2. Нажмите **New Project** (Новый проект)
3. Дайте название: `SakhaRadio RSS Proxy`

### Шаг 2: Разместите код

Удалите весь код в редакторе и вставьте этот:

```javascript
function doGet(e) {
  // URL RSS-ленты
  var RSS_URL = 'https://ysia.ru/feed/';
  
  // Кэширование на 5 минут (уменьшает нагрузку)
  var cache = CacheService.getScriptCache();
  var cached = cache.get('rss_feed');
  
  if (cached != null) {
    // Возвращаем кэш
    return ContentService.createTextOutput(cached)
      .setMimeType(ContentService.MimeType.RSS);
  }
  
  try {
    // Делаем запрос к RSS-ленте
    var response = UrlFetchApp.fetch(RSS_URL, {
      'method': 'GET',
      'headers': {
        'User-Agent': 'Mozilla/5.0 (compatible; SakhaRadio/1.0)'
      },
      'muteHttpExceptions': true
    });
    
    if (response.getResponseCode() === 200) {
      var content = response.getContentText();
      
      // Сохраняем в кэш на 5 минут
      cache.put('rss_feed', content, 300);
      
      // Возвращаем RSS с CORS заголовками
      return ContentService.createTextOutput(content)
        .setMimeType(ContentService.MimeType.RSS);
    } else {
      return ContentService.createTextOutput('Error: ' + response.getResponseCode())
        .setMimeType(ContentService.MimeType.TEXT);
    }
  } catch (error) {
    return ContentService.createTextOutput('Error: ' + error.toString())
      .setMimeType(ContentService.MimeType.TEXT);
  }
}
```

### Шаг 3: Настройте доступ

1. Нажмите **Deploy** (Развернуть) → **New deployment** (Новое развёртывание)
2. Нажмите на шестерёнку → выберите **Web app**
3. Заполните:
   - **Description**: `RSS Proxy v1`
   - **Execute as**: `Me` (от вашего имени)
   - **Who has access**: `Anyone` (любой)
4. Нажмите **Deploy**

### Шаг 4: Получите URL

После развёртывания вы получите URL вида:
```
https://script.google.com/macros/s/AKfycbw.../exec
```

**⚠️ Важно:** Сохраните этот URL!

### Шаг 5: Обновите приложение

Откройте `lib/services/news_service.dart` и замените:

```dart
static const String _googleScriptUrl =
    'https://script.google.com/macros/s/AKfycbwlaOWXBunlIMaWhN1gM_XSzC-TM3sQP5Sysn19FEs9JkYqJj17ytZx7FZJxsSgf6d4/exec';
```

На **ваш** URL:
```dart
static const String _googleScriptUrl =
    'https://script.google.com/macros/s/ВАШ_УНИКАЛЬНЫЙ_ID/exec';
```

### Шаг 6: Протестируйте

1. Откройте ваш URL в браузере
2. Должен вернуться RSS-XML с ysia.ru
3. Соберите приложение:
   ```bash
   flutter build web --release
   ```

## Мониторинг

### Логи
В панели Google Apps Script:
1. **Executions** (Выполнения) — история запусков
2. **Cloud Logging** — детальные логи

### Лимиты
| Лимит | Значение |
|---|---|
| Запросов в день | 20,000 |
| Время выполнения | 6 минут |
| Кэш | 5 минут |

## Отладка

### Если скрипт не работает

**1. Проверьте URL**
- Убедитесь, что используете URL с `/exec`, а не `/dev`

**2. Проверьте доступ**
- Должно быть: **Who has access: Anyone**

**3. Проверьте логи**
- **Executions** → покажет ошибки

**4. Ошибка 401/403**
- Измените доступ на **Anyone**

### Если RSS не обновляется

Скрипт кэширует на 5 минут. Для сброса:
1. Откройте `lib/services/news_service.dart`
2. Вызовите `NewsService.clearCache()`
3. Или подождите 15 минут

## Сравнение решений

| Решение | Запросов/день | Надёжность | Сложность |
|---|---|---|---|
| **Google Apps Script** | 20,000 | ⭐⭐⭐⭐⭐ | ⭐ (5 мин) |
| Cloudflare Workers | 100,000 | ⭐⭐⭐⭐⭐ | ⭐⭐ (15 мин) |
| Публичные прокси | ∞ | ⭐⭐ | ⭐ (0 мин) |

## Рекомендации

1. **Используйте Google Apps Script** — оптимально для начала
2. **Кэширование включено** — снижает нагрузку
3. **Мониторьте логи** — проверяйте **Executions** раз в неделю

## Готово!

Теперь приложение будет получать RSS через Google Apps Script без CORS проблем.

---

## Приложение уже настроено!

Вам нужно только:
1. Развернуть скрипт (5 минут)
2. Заменить URL в `lib/services/news_service.dart`
3. Собрать приложение

Всё! 🎉
