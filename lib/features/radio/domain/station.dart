class Station {
  final dynamic id; // Может быть int или String
  final String name;
  final String desc;
  final String art;
  final String icon;
  final String url;
  final String frequency;

  Station({
    this.id,
    required this.name,
    required this.desc,
    required this.art,
    required this.icon,
    required this.url,
    required this.frequency,
  });
}
