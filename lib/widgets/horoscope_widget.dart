import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../core/providers.dart';

// Перечисление всех знаков зодиака
enum ZodiacSign {
  aries('aries', 'Овен'),
  taurus('taurus', 'Телец'),
  gemini('gemini', 'Близнецы'),
  cancer('cancer', 'Рак'),
  leo('leo', 'Лев'),
  virgo('virgo', 'Дева'),
  libra('libra', 'Весы'),
  scorpio('scorpio', 'Скорпион'),
  sagittarius('sagittarius', 'Стрелец'),
  capricorn('capricorn', 'Козерог'),
  aquarius('aquarius', 'Водолей'),
  pisces('pisces', 'Рыбы');

  const ZodiacSign(this.value, this.displayName);
  final String value;
  final String displayName;
}

class HoroscopeSelectorPage extends StatefulWidget {
  const HoroscopeSelectorPage({super.key});

  @override
  State<HoroscopeSelectorPage> createState() => _HoroscopeSelectorPageState();
}

class _HoroscopeSelectorPageState extends State<HoroscopeSelectorPage> {
  ZodiacSign _selectedZodiacSign = ZodiacSign.virgo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('Гороскоп'),
        backgroundColor: const Color(0xFF0F0F0F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Выберите знак зодиака:',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: ZodiacSign.values.map((sign) {
                return ChoiceChip(
                  label: Text(sign.displayName),
                  selected: _selectedZodiacSign == sign,
                  selectedColor: Colors.yellow,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedZodiacSign = sign;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Expanded(child: HoroscopePage(zodiacSign: _selectedZodiacSign)),
          ],
        ),
      ),
    );
  }
}

class HoroscopePage extends StatefulWidget {
  final ZodiacSign zodiacSign;

  const HoroscopePage({super.key, required this.zodiacSign});

  @override
  State<HoroscopePage> createState() => _HoroscopePageState();
}

class _HoroscopePageState extends State<HoroscopePage> {
  String _horoscopeText = "Загрузка прогноза...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCachedHoroscope();
    _fetchHoroscope();
  }

  @override
  void didUpdateWidget(HoroscopePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.zodiacSign != oldWidget.zodiacSign) {
      _loadCachedHoroscope();
      _fetchHoroscope();
    }
  }

  // Загружаем закэшированный гороскоп при запуске
  Future<void> _loadCachedHoroscope() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedHoroscope = prefs.getString(
      '${widget.zodiacSign.value}_horoscope',
    );
    String? cacheDate = prefs.getString('${widget.zodiacSign.value}_date');

    // Проверяем, что кэш не старше одного дня
    if (cachedHoroscope != null && cacheDate != null) {
      DateTime currentDate = DateTime.now();
      DateTime cachedDateTime =
          DateTime.tryParse(cacheDate) ??
          currentDate.add(const Duration(days: -1));

      if (currentDate.difference(cachedDateTime).inHours < 24) {
        setState(() {
          _horoscopeText = cachedHoroscope;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchHoroscope() async {
    try {
      // Генерируем заглушечный гороскоп для выбранного знака зодиака
      final String horoscopeText = _generateSampleHoroscope(
        widget.zodiacSign.value,
      );

      // Сохраняем полученный гороскоп в кэш
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '${widget.zodiacSign.value}_horoscope',
        horoscopeText,
      );
      await prefs.setString(
        '${widget.zodiacSign.value}_date',
        DateTime.now().toIso8601String(),
      );

      setState(() {
        _horoscopeText = horoscopeText;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _horoscopeText = "Ошибка: $e";
        _isLoading = false;
      });
    }
  }

  String _generateSampleHoroscope(String sign) {
    // Создаем образцы текстов гороскопа для разных знаков зодиака
    Map<String, String> sampleHoroscopes = {
      'aries':
          'Сегодня Овнам стоит проявить инициативу. Возможны успехи в профессиональной сфере. Не бойтесь новых начинаний.',
      'taurus':
          'Благоприятный день для решения финансовых вопросов. Избегайте конфликтов, сохраняйте спокойствие.',
      'gemini':
          'Коммуникации будут на высоте. Отличное время для встреч и общения. Возможны интересные знакомства.',
      'cancer':
          'Эмоциональный день. Обратите внимание на семью и домашний уют. Интуиция особенно сильна.',
      'leo':
          'День приносит возможности для самореализации. Ваша харизма будет особенно заметна. Уверенно двигайтесь к цели.',
      'virgo':
          'Внимательность к деталям принесет пользу. Рационализируйте свои планы и подходы к работе.',
      'libra':
          'Баланс важен во всем. Сегодня отличный день для заключения соглашений и установления контактов.',
      'scorpio':
          'Интенсивный день. Глубокие эмоции и интуитивные прозрения помогут принять важные решения.',
      'sagittarius':
          'Приключения и путешествия в центре внимания. Отличное время для расширения кругозора.',
      'capricorn':
          'Практический подход к делам будет вознагражден. Сосредоточьтесь на долгосрочных целях.',
      'aquarius':
          'Необычные идеи и нестандартные решения принесут успех. Социальные связи окажутся полезными.',
      'pisces':
          'Творческие порывы и духовное развитие на первом плане. Интуиция особенно сильна сегодня.',
    };

    // Если для данного знака нет специфического гороскопа, возвращаем общий
    return sampleHoroscopes[sign] ??
        'Сегодня благоприятный день для саморазвития и новых начинаний. Следуйте своим инстинктам.';
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Обновляем гороскоп при жесте pull-to-refresh
        await _fetchHoroscope();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            // Используем withValues вместо deprecated withOpacity
            color: Colors.yellow.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.yellow.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.menu_book, color: Colors.yellow),
                      const SizedBox(width: 12),
                      Text(
                        "${widget.zodiacSign.displayName} на сегодня",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final themeState = ref.watch(themeProvider);
                      final themeNotifier = ref.read(themeProvider.notifier);
                      return Switch(
                        value: themeState.isDarkTheme,
                        onChanged: (bool newValue) {
                          themeNotifier.toggleTheme();
                        },
                        activeTrackColor: Colors.yellow.withValues(alpha: 0.5),
                        activeThumbColor: Colors.yellow,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.yellow)
                  : Text(
                      _horoscopeText,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.white70,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
