# Модуль погоды для Sakha Radio

Этот модуль предоставляет функциональность для отображения текущей погоды и прогноза в Якутске.

## Архитектура

Модуль следует принципам Clean Architecture и состоит из следующих слоев:

### 1. Presentation (Представление)
- `weather_screen.dart` - виджет экрана погоды
- Использует Provider для управления состоянием

### 2. Domain (Домен)
- `models/weather_model.dart` - модели данных погоды
- `models/weather_failure.dart` - классы для обработки ошибок

### 3. Data (Данные)
- `data/weather_repository.dart` - абстракция репозитория
- `data/weather_service.dart` - сервис для работы с API
- `data/weather_repository_impl.dart` - реализация репозитория

### 4. Providers (Провайдеры)
- `providers/weather_provider.dart` - провайдер состояния
- `providers/weather_providers.dart` - список провайдеров

## Использование

Для использования модуля в приложении:

1. Добавьте провайдер в дерево виджетов:

```dart
ChangeNotifierProvider(
  create: (context) => WeatherProvider(),
  child: WeatherScreen(),
)
```

2. Или используйте список провайдеров:

```dart
MultiProvider(
  providers: [
    ...weatherProviders,
    // другие провайдеры
  ],
  child: MyApp(),
)
```

## API

Модуль использует OpenWeatherMap API с бесплатным ключом. Для получения данных:

- Текущая погода: `/data/2.5/weather`
- Прогноз: `/data/2.5/forecast`

## Особенности

- Отображение текущей температуры, описания, ветра и влажности
- Прогноз на 5 дней с указанием времени восхода и заката
- Обработка ошибок сети и API
- Адаптивный дизайн под разные размеры экранов
- Поддержка темной темы