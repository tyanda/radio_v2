# Widget Testing

## Тестирование виджетов Flutter

### Базовый тест виджета

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('должен_показывать_название_станции', (tester) async {
    // Arrange
    final testStation = RadioStation(
      id: '1',
      name: 'Europa Plus',
      streamUrl: 'https://stream.europaplus.ru/ep128',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          radioProvider.overrideWithValue(RadioState(
            stations: [testStation],
            isLoading: false,
          )),
        ],
        child: MaterialApp(
          home: RadioPlayer(),
        ),
      ),
    );

    // Act
    await tester.pump();

    // Assert
    expect(find.text('Europa Plus'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });
}
```

### Тест взаимодействия

```dart
testWidgets('должен_запускать_воспроизведение_по_кнопке', (tester) async {
  bool wasPlayed = false;

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: RadioPlayer(
          onPlay: () => wasPlayed = true,
        ),
      ),
    ),
  );

  // Нажать кнопку Play
  await tester.tap(find.byIcon(Icons.play_arrow));
  await tester.pump();

  // Проверить
  expect(wasPlayed, isTrue);
  expect(find.byIcon(Icons.pause), findsOneWidget);
});
```

### Тест с моками

```dart
@GenerateMocks([AudioPlayer])
import 'radio_player_test.mocks.dart';

testWidgets('должен_показывать_ошибку_при_неудаче', (tester) async {
  final mockPlayer = MockAudioPlayer();
  when(mockPlayer.play()).thenThrow(Exception('Network error'));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        audioPlayerProvider.overrideWithValue(mockPlayer),
      ],
      child: MaterialApp(
        home: RadioPlayer(),
      ),
    ),
  );

  await tester.tap(find.byIcon(Icons.play_arrow));
  await tester.pump();

  expect(find.text('Ошибка подключения'), findsOneWidget);
});
```

### Тест адаптивности

```dart
testWidgets('должен_корректно_отображаться_на_разных_экранах', (tester) async {
  // Mobile
  tester.view.physicalSize = const Size(375, 812);
  await tester.pumpWidget(buildApp());
  expect(find.byType(SingleChildScrollView), findsOneWidget);

  // Desktop
  tester.view.physicalSize = const Size(1920, 1080);
  await tester.pumpWidget(buildApp());
  expect(find.byType(Row), findsOneWidget);
});
```

## Паттерны

### Arrange-Act-Assert

```dart
testWidgets('тест', (tester) async {
  // Arrange - Подготовка
  final container = ProviderContainer();
  
  // Act - Действие
  await tester.pumpWidget(...);
  await tester.tap(...);
  
  // Assert - Проверка
  expect(...);
});
```

### Page Object

```dart
class RadioPlayerPage {
  final Finder playButton = find.byIcon(Icons.play_arrow);
  final Finder stationName = find.byKey(Key('station_name'));
  
  Future<void> tapPlay(WidgetTester tester) async {
    await tester.tap(playButton);
    await tester.pump();
  }
}
```
