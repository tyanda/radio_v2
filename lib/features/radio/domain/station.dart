class Station {
  final String? id;
  final String name;
  final String desc;
  final String art;
  final String icon;
  final String url;
  final String frequency;
  final String? logoUrl; // URL логотипа для загрузки из интернета
  final Map<String, String>? metadata;

  Station({
    this.id,
    required this.name,
    required this.desc,
    required this.art,
    required this.icon,
    required this.url,
    required this.frequency,
    this.logoUrl,
    this.metadata,
  });
}
