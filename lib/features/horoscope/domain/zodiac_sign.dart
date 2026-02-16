class ZodiacSign {
  final String id;
  final String name;

  const ZodiacSign({required this.id, required this.name});

  static const List<ZodiacSign> all = [
    ZodiacSign(id: 'aries', name: 'Овен'),
    ZodiacSign(id: 'taurus', name: 'Телец'),
    ZodiacSign(id: 'gemini', name: 'Близнецы'),
    ZodiacSign(id: 'cancer', name: 'Рак'),
    ZodiacSign(id: 'leo', name: 'Лев'),
    ZodiacSign(id: 'virgo', name: 'Дева'),
    ZodiacSign(id: 'libra', name: 'Весы'),
    ZodiacSign(id: 'scorpio', name: 'Скорпион'),
    ZodiacSign(id: 'sagittarius', name: 'Стрелец'),
    ZodiacSign(id: 'capricorn', name: 'Козерог'),
    ZodiacSign(id: 'aquarius', name: 'Водолей'),
    ZodiacSign(id: 'pisces', name: 'Рыбы'),
  ];
}
