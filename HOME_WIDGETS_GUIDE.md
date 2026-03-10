# Home Screen Widgets Guide

> Руководство по настройке и использованию виджетов для главного экрана

## 📱 Обзор

Виджет SakhaLive Radio позволяет пользователям быстро запускать радио и видеть текущую станцию прямо с главного экрана устройства.

### Возможности:
- 📻 Отображение текущей станции
- 🎵 Показать название трека (если доступно)
- ▶️ Кнопка Play/Pause
- 🔗 Быстрый запуск приложения

---

## 🏗 Архитектура

```
lib/features/widgets/
├── data/
│   ├── models/
│   │   └── widget_data.dart       # Модель данных виджета
│   └── repository/
│       └── home_widget_repository.dart  # Репозиторий для работы с виджетом
├── providers/
│   └── home_widget_provider.dart  # Riverpod провайдеры
└── widgets.dart                   # Экспорт фичи
```

---

## 🔧 Настройка для Android

### 1. Файлы виджета

Файлы уже созданы в:
- `android/app/src/main/res/layout/sakha_live_widget.xml` - Layout виджета
- `android/app/src/main/res/xml/sakha_live_widget_info.xml` - Конфигурация виджета
- `android/app/src/main/kotlin/.../SakhaLiveWidget.kt` - Kotlin код виджета

### 2. AndroidManifest.xml

Виджет уже зарегистрирован в `AndroidManifest.xml`:

```xml
<receiver
    android:name=".SakhaLiveWidget"
    android:exported="true">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
        <action android:name="com.sakhalive.PLAY_PAUSE" />
        <action android:name="com.sakhalive.OPEN_APP" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/sakha_live_widget_info" />
</receiver>
```

### 3. Добавление виджета на главный экран

1. Долгое нажатие на пустом месте главного экрана
2. Выберите "Виджеты"
3. Найдите "SakhaLive Radio"
4. Перетащите виджет на экран

---

## 🔧 Настройка для iOS

### 1. Создание Widget Extension

Откройте `ios/Runner.xcworkspace` в Xcode:

1. **File → New → Target...**
2. Выберите **Widget Extension**
3. Назовите `SakhaLiveWidget`
4. Выберите группу `Runner`
5. Нажмите "Finish"

### 2. Настройка Group ID

1. В Xcode выберите проект Runner
2. Выберите target **SakhaLiveWidget**
3. Вкладка **Signing & Capabilities**
4. Добавьте **App Groups**:
   - Group ID: `group.com.sakhalive.shared`

### 3. Настройка основного приложения

1. В Xcode выберите проект Runner
2. Выберите target **Runner**
3. Вкладка **Signing & Capabilities**
4. Добавьте **App Groups**:
   - Group ID: `group.com.sakhalive.shared`

### 4. Копирование файлов

Скопируйте созданный файл `SakhaLiveWidget.swift` в папку виджета в Xcode.

### 5. Info.plist

Добавьте в `ios/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>sakhalive</string>
        </array>
    </dict>
</array>
```

### 6. Добавление виджета на главный экран

1. Долгое нажатие на пустом месте главного экрана
2. Нажмите "+" в верхнем углу
3. Найдите "SakhaLive"
4. Выберите размер виджета
5. Нажмите "Add Widget"

---

## 💻 Использование в коде

### Обновление данных виджета

Виджет автоматически обновляется при изменении состояния плеера благодаря интеграции с `player_provider`.

```dart
// В player_provider.dart
ref.read(homeWidgetStateProvider.notifier).updateFromPlayerState(
  stationName: station.name,
  currentTrack: station.desc,
  albumArt: artUri?.toString(),
  isPlaying: true,
);
```

### Ручное обновление

```dart
final widgetNotifier = ref.read(homeWidgetStateProvider.notifier);

await widgetNotifier.updateFromPlayerState(
  stationName: 'Европа Плюс',
  currentTrack: 'Imagine Dragons - Believer',
  isPlaying: true,
);
```

---

## 🎨 Дизайн виджета

### Android
- **Размер:** 180x120dp (минимальный)
- **Фон:** #1A1A1A (тёмный)
- **Акцент:** #F2C94C (жёлтый)
- **Кнопки:** Play/Pause, Открыть приложение

### iOS
- **Размер:** System Small
- **Фон:** #1A1A1A (тёмный)
- **Акцент:** Yellow
- **Кнопки:** Play/Pause, Открыть приложение

---

## 🐛 Отладка

### Логирование

Виджет использует `Logger` для отладки:

```
[HomeWidget] Widget clicked: sakhalive://widget_action
[HomeWidget] Error updating widget: ...
```

### Частые проблемы

#### Android

| Проблема | Решение |
|----------|---------|
| Виджет не обновляется | Проверьте `updatePeriodMillis` в xml |
| Кнопки не работают | Проверьте IntentFilter в Manifest |
| Ошибка компиляции | Убедитесь что Kotlin файл в правильной папке |

#### iOS

| Проблема | Решение |
|----------|---------|
| Виджет не показывает данные | Проверьте App Groups |
| Widget не появляется в списке | Пересоберите проект в Xcode |
| Ошибка компиляции Swift | Проверьте версию iOS (минимум 14.0) |

---

## 📦 Зависимости

```yaml
dependencies:
  home_widget: ^0.4.1
```

---

## 📝 Тестирование

### Android Emulator
1. Запустите эмулятор
2. Добавьте виджет на главный экран
3. Запустите приложение
4. Включите радио
5. Проверьте обновление виджета

### iOS Simulator
1. Запустите симулятор
2. Добавьте виджет через "+" меню
3. Запустите приложение
4. Включите радио
5. Проверьте обновление виджета

---

## 🔄 Будущие улучшения

- [ ] Виджет с списком избранных станций
- [ ] Виджет погоды
- [ ] Виджет гороскопа
- [ ] Кастомизируемые размеры
- [ ] Темы виджетов (светлая/тёмная)

---

## 📚 Ресурсы

- [home_widget package](https://pub.dev/packages/home_widget)
- [Android App Widgets](https://developer.android.com/guide/topics/appwidgets)
- [iOS WidgetKit](https://developer.apple.com/documentation/widgetkit)
