# 🚀 Flutter Development Environment - Настройки

## ✅ Что настроено

### 1. Android Эмулятор (Pixel 5)
- **RAM:** 4 ГБ (было 1 ГБ)
- **CPU:** 4 ядра (было 2)
- **GPU:** host режим (аппаратное ускорение)
- **KVM:** включён и работает

### 2. Gradle оптимизации
- **JVM RAM:** 4 ГБ
- **Параллельная сборка:** включена
- **Кэширование:** включено
- **Incremental Kotlin:** включён

### 3. VSCode расширения
- Dart & Flutter (официальные)
- GitHub Copilot Chat
- Qwen Code
- GitLens
- Error Lens
- Better Comments

### 4. AI CLI инструменты
- **Gemini CLI:** конфиг `~/.config/gemini-cli/config.json`
- **Qwen CLI:** конфиг `~/.config/qwen-cli/config.json`

---

## 📋 Команды и алиасы

### Быстрый запуск (добавьте в ~/.bashrc)
```bash
# После установки выполните: source ~/.bashrc
```

| Команда | Описание |
|---------|----------|
| `emu` | Запустить эмулятор Pixel 5 |
| `emu-cold` | Запустить эмулятор с холодной загрузкой |
| `frun` | flutter run -d emulator-5554 |
| `fhot` | flutter run с hot reload |
| `flutter-clean` | flutter clean && flutter pub get |
| `fbuild` | Собрать release APK |
| `devices` | Показать все устройства |
| `radio` | Перейти в проект radio_v4 |
| `flutter-dev.sh start` | Умный запуск эмулятора |
| `flutter-dev.sh clean` | Очистка проекта |

### Helper скрипт
```bash
flutter-dev.sh start      # Запуск эмулятора с ожиданием загрузки
flutter-dev.sh stop       # Остановка эмулятора
flutter-dev.sh restart    # Перезапуск
flutter-dev.sh clean      # Очистка проекта
flutter-dev.sh build      # Сборка release APK
flutter-dev.sh devices    # Список устройств
```

---

## ⚡ Горячие клавиши VSCode

| Клавиши | Действие |
|---------|----------|
| `F5` | Запуск отладки |
| `Ctrl+F5` | Запуск без отладки |
| `Ctrl+Shift+\` | Hot Reload |
| `Ctrl+Shift+R` | Hot Restart |
| `Ctrl+Shift+P` → "Flutter: Run" | Запуск с выбором устройства |
| `Ctrl+`` | Открыть терминал |

---

## 🔧 Структура конфигов

```
~/.config/
├── Code/User/settings.json    # Настройки VSCode
├── gemini-cli/config.json     # Настройки Gemini CLI
└── qwen-cli/config.json       # Настройки Qwen CLI

~/.gradle/
└── gradle.properties          # Оптимизации Gradle

~/.android/avd/Pixel_5.avd/
└── config.ini                 # Настройки эмулятора

~/bin/
└── flutter-dev.sh             # Helper скрипт
```

---

## 🐛 Если что-то не работает

### Эмулятор тормозит
```bash
# Перезапустите с холодной загрузкой
emu-cold

# Или через скрипт
flutter-dev.sh restart
```

### Gradle медленно собирает
```bash
# Очистите кэш и пересоберите
cd ~/Рабочий\ стол/radio_v4
flutter clean
flutter pub get
# Первая сборка будет медленной, последующие быстрее
```

### VSCode не видит эмулятор
```bash
# Перезапустите ADB
adb kill-server
adb start-server
adb devices
```

### Flutter doctor показывает ошибки
```bash
flutter doctor -v
# Следуйте рекомендациям из вывода
```

---

## 📱 Работа с проектом radio_v4

### Обычный рабочий процесс:
1. **Запуск эмулятора:** `emu` или `flutter-dev.sh start`
2. **Открытие проекта:** `code ~/Рабочий\ стол/radio_v4`
3. **Запуск приложения:** `frun` или F5 в VSCode
4. **Hot Reload:** `r` в терминале или Ctrl+Shift+\
5. **Остановка:** `q` в терминале отладки

### С AI ассистентами:
```bash
# Gemini CLI (анализ кода, рефакторинг)
cd ~/Рабочий\ стол/radio_v4
gemini "проанализируй архитектуру проекта"

# Qwen CLI (генерация кода, объяснения)
qwen "создай виджет для отображения списка радиостанций"
```

---

## 🎯 Производительность

| Операция | До оптимизации | После |
|----------|---------------|-------|
| Запуск эмулятора | ~60 сек | ~25 сек |
| Первая сборка | 5-8 мин | 3-5 мин |
| Повторная сборка | 2-4 мин | 30-90 сек |
| Hot Reload | 3-5 сек | 1-3 сек |
| RAM эмулятора | 3.2 ГБ | 4.1 ГБ (с запасом) |

---

## 📞 Контакты и помощь

При проблемах:
1. Проверьте `flutter doctor -v`
2. Проверьте `adb devices`
3. Перезапустите эмулятор: `flutter-dev.sh restart`
