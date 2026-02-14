import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show SocketException;
import 'package:marquee/marquee.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/rss_service.dart';
import 'features/weather_tab.dart';
import 'features/weather/presentation/weather_screen.dart';
import 'widgets/equalizer_animation.dart';

// Виджет мигающей точки
class BlinkingDot extends StatefulWidget {
  final Color color;
  final double size;
  final Duration blinkInterval;

  const BlinkingDot({
    super.key,
    this.color = AppColors.accent,
    this.size = 12.0,
    this.blinkInterval = const Duration(milliseconds: 800),
  });

  @override
  State<BlinkingDot> createState() => BlinkingDotState();
}

class BlinkingDotState extends State<BlinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.blinkInterval ~/ 2, // Половина интервала для плавности
      vsync: this,
    );
    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: _opacityAnimation.value),
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
              width: 1,
            ),
          ),
        );
      },
    );
  }
}

// Темы оформления
class AppColors {
  static const Color accent = Color(0xFFFFD700); // Золотой
  static const Color background = Colors.black;
  static const Color cardBackground = Color(0xFF111111);
  static const Color error = Color(0xFFEF4444);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // --- Плеер и Состояния ---
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  String _currentStationName = 'Виктория';
  double _volume = 0.65;          // от 0.0 до 1.0 (как в just_audio)
  bool _showVolume = false; // показывать/скрывать слайдер

  // --- Данные ---
  late String _greeting;
  int _currentTab = 0;
  String _latestNews = "ЗАГРУЖАЮ НОВОСТИ...";
  String _firebaseTicker = ""; // Храним текст из Firebase отдельно
  final Set<String> _favorites = {};

  // --- Гороскоп ---
  String _selectedZodiacId = 'aries';
  String _selectedZodiacName = 'Овен';
  
  static const List<Map<String, String>> _zodiacSigns = [
    {'id': 'aries', 'name': 'Овен'},
    {'id': 'taurus', 'name': 'Телец'},
    {'id': 'gemini', 'name': 'Близнецы'},
    {'id': 'cancer', 'name': 'Рак'},
    {'id': 'leo', 'name': 'Лев'},
    {'id': 'virgo', 'name': 'Дева'},
    {'id': 'libra', 'name': 'Весы'},
    {'id': 'scorpio', 'name': 'Скорпион'},
    {'id': 'sagittarius', 'name': 'Стрелец'},
    {'id': 'capricorn', 'name': 'Козерог'},
    {'id': 'aquarius', 'name': 'Водолей'},
    {'id': 'pisces', 'name': 'Рыбы'},
  ];

  // Ссылка на Firebase Realtime Database
  final DatabaseReference _tickerRef = FirebaseDatabase.instance.ref(
    'ticker_message',
  );

  // --- Таймеры и Подписки ---
  Timer? _greetingTimer;
  Timer? _newsTimer;
  bool _isNewsLoading = false;

  StreamSubscription? _tickerSubscription;

  @override
  void initState() {
    super.initState();
    _greeting = "ДОБРЫЙ ДЕНЬ 🌤️"; // Дефолтное значение
    _initPlayer();
    _loadVolumeSliderState(); // Загружаем состояние слайдера громкости
    _updateGreeting();
    _listenToTicker(); // Слушаем Firebase в реальном времени
    _fetchNews(); // Загружаем RSS

    _greetingTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) _updateGreeting();
    });

    _newsTimer = Timer.periodic(const Duration(minutes: 15), (timer) async {
      if (mounted && !_isNewsLoading) await _fetchNews();
    });
  }

  // Загрузка состояния видимости слайдера громкости
  Future<void> _loadVolumeSliderState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showVolume = prefs.getBool('showVolume') ?? false;
      _volume = prefs.getDouble('volume') ?? 0.65;
    });
    
    // Применяем уровень громкости к плееру
    await _player.setVolume(_volume);
  }

  // Сохранение состояния видимости слайдера громкости
  Future<void> _saveVolumeSliderState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showVolume', _showVolume);
    await prefs.setDouble('volume', _volume);
  }

  // Свежий подход: слушаем изменения в Firebase без перезагрузки
  void _listenToTicker() {
    _tickerSubscription = _tickerRef.onValue.listen(
      (event) {
        final String? newMessage = event.snapshot.value as String?;
        if (mounted) {
          setState(() {
            _firebaseTicker = newMessage ?? "";
            _combineAllNews(); // Пересобираем строку
          });
        }
      },
      onError: (error, stackTrace) {
        debugPrint("Firebase Ticker Error: $error");
        debugPrint("Error type: ${error.runtimeType}");
        debugPrint("Stack trace: $stackTrace");
        // Добавляем более подробную информацию об ошибке
        if (error is Exception) {
          debugPrint("Exception type: ${error.runtimeType}");
        }
      },
    );
  }

  // Объединяем новости из RSS и Ticker из Firebase
  void _combineAllNews([List<String>? rssItems]) {
    List<String> combined = [];
    if (_firebaseTicker.isNotEmpty) {
      combined.add(_firebaseTicker.toUpperCase());
    }
    if (rssItems != null && rssItems.isNotEmpty) {
      combined.addAll(rssItems);
    }

    setState(() {
      if (combined.isNotEmpty) {
        _latestNews = combined.join("  •  ");
      } else {
        _latestNews = "НЕТ АКТУАЛЬНЫХ НОВОСТЕЙ";
      }
    });
    
    // Обновляем глобальный ValueNotifier
    globalMarqueeTextNotifier.value = _latestNews;
  }

  Future<void> _fetchNews() async {
    if (_isNewsLoading) return;

    if (mounted) {
      setState(() {
        _isNewsLoading = true;
      });
    }

    try {
      // Получаем заголовки новостей через RssService
      final newsTitles = await RssService.fetchNewsTitles(limit: 10);
      final formattedTitles = newsTitles.map((title) => "🔥 $title").toList();

      if (mounted && formattedTitles.isNotEmpty) {
        _combineAllNews(formattedTitles);
        setState(() {
          _isNewsLoading = false;
        });
      } else if (mounted) {
        _combineAllNews([]);
        setState(() {
          _isNewsLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Ошибка загрузки новостей: $e");
      // Если не удалось загрузить RSS-новости, используем только сообщения из Firebase
      if (mounted) {
        setState(() {
          // Если есть сообщения из Firebase, отображаем их, иначе - "НЕТ АКТУАЛЬНЫХ НОВОСТЕЙ"
          if (_firebaseTicker.isNotEmpty) {
            _latestNews = _firebaseTicker.toUpperCase();
          } else {
            _latestNews = "НЕТ АКТУАЛЬНЫХ НОВОСТЕЙ";
          }
          _isNewsLoading = false;
        });
        // Обновляем глобальный ValueNotifier
        globalMarqueeTextNotifier.value = _latestNews;
      }
    }
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    String emoji = (hour < 6)
        ? "🌙"
        : (hour < 12)
        ? "☀️"
        : (hour < 18)
        ? "🌤️"
        : "🌆";
    String base = (hour < 6)
        ? "ДОБРОЙ НОЧИ"
        : (hour < 12)
        ? "ДОБРОЕ УТРО"
        : (hour < 18)
        ? "ДОБРЫЙ ДЕНЬ"
        : "ДОБРЫЙ ВЕЧЕР";
    if (mounted) setState(() => _greeting = "$base $emoji");
  }

  Future<void> _initPlayer() async {
    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });

    _player.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace st) {
        _showSafeErrorSnackBar('Ошибка воспроизведения: $e');
      },
    );

    // Устанавливаем начальный уровень громкости
    await _player.setVolume(_volume);
  }

  // Метод для безопасного показа ошибок (решает проблему со скриншота)
  void _showSafeErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.error,
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              // <--- Это исправляет Overflow (желтые полосы)
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _greetingTimer?.cancel();
    _newsTimer?.cancel();
    _tickerSubscription?.cancel();
    _player.stop(); // Останавливаем воспроизведение
    _player.dispose(); // Освобождаем ресурсы плеера
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent;

    switch (_currentTab) {
      case 0: // Вкладка "ЭФИР"
        mainContent = Column(
          children: [
            _buildHeader(),
            _buildMarqueeSection(),
            const SizedBox(height: 20),
            _buildLiveIndicator(),
            const SizedBox(height: 12),
            Expanded(child: _buildStationList()),
          ],
        );
        break;
      case 1: // Вкладка "ПОГОДА"
        mainContent = Column(
          children: [
            _buildHeader(),
            _buildMarqueeSection(),
            const SizedBox(height: 20),
            Expanded(child: WeatherTab()),
          ],
        );
        break;
      case 2: // Вкладка "ГОРОСКОП"
        mainContent = _buildHoroscopeTab();
        break;
      default:
        mainContent = Column(
          children: [
            _buildHeader(),
            _buildMarqueeSection(),
            const SizedBox(height: 20),
            _buildLiveIndicator(),
            const SizedBox(height: 12),
            Expanded(child: _buildStationList()),
          ],
        );
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: mainContent),
      bottomNavigationBar: _buildModernBottomBar(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const Text(
                "SakhaLive",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const CircleAvatar(
            backgroundColor: AppColors.cardBackground,
            child: Icon(Icons.person_outline, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMarqueeSection() {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Marquee(
        text: "SAKHALIVE  |  $_latestNews  ",
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
        velocity: 45,
        blankSpace: 100,
      ),
    );
  }

  Widget _buildLiveIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          BlinkingDot(
            color: AppColors.error,
            size: 8.0,
            blinkInterval: const Duration(milliseconds: 800),
          ),
          const SizedBox(width: 8),
          const Text(
            "В ЭФИРЕ",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: _stations.length,
      itemBuilder: (context, index) {
        final station = _stations[index];
        bool isCurrent = _currentStationName == station['name'];
        bool isFavorite = _favorites.contains(station['name']);

        return GestureDetector(
          onTap: () => _playStation(station),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isCurrent ? AppColors.accent : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child:
                            station['art'] != null && station['art']!.isNotEmpty
                            ? Image.asset(
                                station['art']!,
                                fit: BoxFit.cover,
                                width: 60,
                                height: 60,
                              )
                            : Center(
                                child: Text(
                                  station['icon'] ?? station['name']![0],
                                  style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                      if (isCurrent &&
                          _isPlaying) // Мигающая точка на текущей станции
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: BlinkingDot(
                            color: AppColors.accent,
                            size: 12.0,
                            blinkInterval: const Duration(milliseconds: 800),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station['name']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        station['desc']!,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.white70,
                  ),
                  onPressed: () => setState(
                    () => isFavorite
                        ? _favorites.remove(station['name'])
                        : _favorites.add(station['name']!),
                  ),
                ),
                Icon(
                  isCurrent && _isPlaying
                      ? Icons.volume_up
                      : Icons.play_arrow_outlined,
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.85,
        ), // Заменил withOpacity на withValues
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMiniPlayer(),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer() {
    final currentStation = _stations.firstWhere(
      (s) => s['name'] == _currentStationName,
      orElse: () => _stations[0],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Выдвижной слайдер громкости (как в React)
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 280),
          crossFadeState:
              _showVolume ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const SizedBox(height: 0),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.volume_mute_rounded,
                      color: Colors.white70, size: 18),
                  Expanded(
                    child: Slider(
                      value: _volume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 20,
                      activeColor: AppColors.accent,
                      inactiveColor: Colors.white24,
                      thumbColor: AppColors.accent,
                      onChanged: (v) async {
                        setState(() => _volume = v);
                        await _player.setVolume(v);
                        await _saveVolumeSliderState();
                      },
                    ),
                  ),
                  Icon(Icons.volume_up_rounded,
                      color: Colors.white70, size: 18),
                ],
              ),
            ),
          ),
        ),

        // Основная карточка мини-плеера (стекло + blur-эффект)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            // Blur-эффект (работает на iOS/Android с достаточной производительностью)
            // Если blur сильно тормозит → закомментировать BackdropFilter
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // Обложка с наложенной иконкой громкости (как в React)
                  GestureDetector(
                    onTap: () async {
                    setState(() => _showVolume = !_showVolume);
                    await _saveVolumeSliderState();
                  },
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: currentStation['art'] != null &&
                                  currentStation['art']!.isNotEmpty
                              ? Image.asset(
                                  currentStation['art']!,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 56,
                                  height: 56,
                                  color: AppColors.cardBackground,
                                  child: Center(
                                    child: Text(
                                      currentStation['name']![0],
                                      style: const TextStyle(
                                        color: AppColors.accent,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        if (_isPlaying)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.black.withValues(alpha: 0.40),
                              ),
                            ),
                          ),
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: Icon(
                              Icons.volume_up_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                        if (_isPlaying)
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: SizedBox(
                                width: 32,
                                height: 32,
                                child: EqualizerAnimation(
                                  isActive: true,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Текст + статус
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentStationName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _isPlaying
                                    ? Colors.redAccent
                                    : Colors.grey,
                                shape: BoxShape.circle,
                                boxShadow: _isPlaying
                                    ? [
                                        BoxShadow(
                                          color: Colors.redAccent.withValues(alpha: 0.6),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        )
                                      ]
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isPlaying
                                  ? "В ЭФИРЕ"
                                  : "ПАУЗА",
                              style: TextStyle(
                                color: _isPlaying
                                    ? AppColors.accent
                                    : Colors.white60,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Большая круглая кнопка Play/Pause с тенью
                  GestureDetector(
                    onTap: () {
                      if (_isPlaying) {
                        _player.pause();
                      } else {
                        _player.play();
                      }
                    },
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.45),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),

              // Навигация внизу мини-плеера (как в React)
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _navItem(Icons.radio, "ЭФИР", 0),
                    _navItem(Icons.cloud_queue, "ПОГОДА", 1),
                    _navItem(Icons.auto_stories, "ГОРОСКОП", 2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _navItem(IconData icon, String label, int index) {
    bool active = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: Column(
        children: [
          Icon(icon, color: active ? AppColors.accent : Colors.white38),
          Text(
            label,
            style: TextStyle(
              color: active ? AppColors.accent : Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  final List<Map<String, String>> _stations = [
    {
      'name': 'Виктория',
      'desc': 'Главное радио Якутии',
      'art': 'assets/images/viktoria.jpg',
      'icon': 'V',
      'url':
          'https://stream2.sakhafm.ru/stream/viktoria/af62bbdf-2e52-45da-9ef5-a2f60a66ef8a/e625247a-13b8-4c31-aaeb-06415c8b1657',
    },
    {
      'name': 'Тэтим',
      'desc': 'НВК Саха',
      'art': 'assets/images/tetim.jpg',
      'icon': 'T',
      'url': 'https://icecast-saha.cdnvideo.ru/saha',
    },
    {
      'name': 'IR Radio',
      'desc': 'Молодежные хиты',
      'art': 'assets/images/ir_radio.jpg',
      'icon': 'I',
      'url': 'https://5.129.229.244.nip.io/legacy/stream',
    },
    {
      'name': 'Европа Плюс',
      'desc': 'Мировые хиты',
      'art': 'assets/images/europa_plus.jpg',
      'icon': 'E',
      'url': 'https://ep256.hostingradio.ru:8052/europaplus256.mp3',
    },
  ];

  Future<void> _playStation(Map<String, String> station) async {
    // Проверяем, является ли станция уже выбранной
    if (_currentStationName == station['name']) {
      // Если станция уже выбрана, то останавливаем воспроизведение
      await _stopCurrentStation();
      return;
    }

    setState(() {
      _currentStationName = station['name']!;
    });

    try {
      // Останавливаем текущее воспроизведение перед установкой нового источника
      await _player.stop();

      // Устанавливаем источник аудио с настройками для потокового вещания
      await _player
          .setAudioSource(
            AudioSource.uri(
              Uri.parse(station['url']!),
              tag: MediaItem(
                id: station['url']!,
                album: station['name'],
                title: station['name']!,
                artUri: station['art']!.isNotEmpty
                    ? Uri.parse(station['art']!)
                    : null,
              ),
            ),
          )
          .timeout(
            const Duration(seconds: 15),
          ); // Увеличенный таймаут для установки источника

      // Начинаем воспроизведение
      await _player.play();

      if (mounted) {
        setState(() {
          _isPlaying = true;
        });
      }
    } catch (e) {
      if (e is SocketException || e.toString().contains('Connection reset')) {
        debugPrint("Network error: $e");
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Ошибка сети при подключении к ${station['name']}: соединение потеряно',
              ),
            ),
          );
        }
      } else {
        debugPrint("Error: $e");
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Не удалось подключиться к ${station['name']}: ${e.toString()}',
              ),
            ),
          );
        }
      }
    }
  }

  // Метод для остановки текущей станции
  Future<void> _stopCurrentStation() async {
    try {
      await _player.stop();
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    } catch (e) {
      debugPrint("Error stopping station: $e");
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  Widget _buildHoroscopeTab() {
    return Column(
      children: [
        _buildHeader(),
        _buildMarqueeSection(),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Сетка знаков зодиака (4 столбца)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.05,
                  ),
                  itemCount: _zodiacSigns.length,
                  itemBuilder: (context, index) {
                    final zodiac = _zodiacSigns[index];
                    final isSelected = zodiac['id'] == _selectedZodiacId;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedZodiacId = zodiac['id']!;
                          _selectedZodiacName = zodiac['name']!;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.accent : AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.accent : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 8)]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            zodiac['name']!,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Большая карточка гороскопа (как в React)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(36),
                    border: Border(
                      left: BorderSide(color: AppColors.accent, width: 10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_stories,
                            color: AppColors.accent,
                            size: 34,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            _selectedZodiacName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _getHoroscopeText(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.90),
                          fontSize: 16,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildSmallBadge('Удача: 92%'),
                          _buildSmallBadge('Энергия: Высокая'),
                          _buildSmallBadge('Совет дня: Шарф обязателен'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Вспомогательные методы
  String _getHoroscopeText() {
    final station = _currentStationName; // или из ValueNotifier, если используешь
    return 'Сегодня для знака $_selectedZodiacName якутское небо сулит удачу в делах. '
        'Вечер идеален для прослушивания $station в компании близких. '
        'Звёзды советуют сохранять тепло в сердце и не забывать про шарф!';
  }

  Widget _buildSmallBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
