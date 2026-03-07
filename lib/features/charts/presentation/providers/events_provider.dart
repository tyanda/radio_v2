import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/event_item.dart';

/// Провайдер списка событий (афиша)
final eventsProvider = Provider<List<EventItem>>((ref) {
  return [
    EventItem(
      id: 'e1',
      title: 'Open Air Yakutsk',
      date: '15 Июля',
      time: '18:00',
      location: 'Стадион Туймаада',
      price: 'от 1200₽',
      imageUrl:
          'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=400',
    ),
    EventItem(
      id: 'e2',
      title: 'Вечер Хомуса',
      date: '20 Июля',
      time: '19:30',
      location: 'Дом Дружбы',
      price: '500₽',
      imageUrl:
          'https://images.unsplash.com/photo-1514525253361-bee8718a300c?w=400',
    ),
  ];
});
