class HoroscopeData {
  final String sign;
  final String title;
  final String text;
  final String period;

  const HoroscopeData({
    required this.sign,
    required this.title,
    required this.text,
    required this.period,
  });

  factory HoroscopeData.fromJson(Map<String, dynamic> json) {
    return HoroscopeData(
      sign: json['sign'] ?? '',
      title: json['title'] ?? '',
      text: json['text'] ?? '',
      period: json['period'] ?? 'today',
    );
  }

  Map<String, dynamic> toJson() {
    return {'sign': sign, 'title': title, 'text': text, 'period': period};
  }
}
