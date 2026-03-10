/// Модель события (афиша)
class EventItem {
  final String id;
  final String title;
  final String date;
  final String time;
  final String location;
  final String price;
  final String imageUrl;
  final String? url;

  const EventItem({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.price,
    required this.imageUrl,
    this.url,
  });
}
