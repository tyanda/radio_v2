import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Современный SplashScreen с анимациями
///
/// Особенности:
/// - Пульсирующая анимация логотипа
/// - Градиентный фон с частицами
/// - Плавный прогресс загрузки
/// - Анимированный индикатор загрузки
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Пульсация логотипа
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Вращение элементов
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _rotateAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );

    // Прогресс загрузки
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeIn),
    );

    _progressController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0F0F),
              Color(0xFF1A1A1A),
              Color(0xFF0F0F0F),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Фоновые частицы
            ..._buildBackgroundParticles(),
            // Основной контент
            Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Анимированный логотип
                        _buildAnimatedLogo(),
                        const SizedBox(height: 32),
                        // Название
                        _buildTitle(),
                        const SizedBox(height: 12),
                        // Подзаголовок
                        _buildSubtitle(),
                        const SizedBox(height: 40),
                        // Индикатор прогресса
                        _buildProgressIndicator(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundParticles() {
    return List.generate(8, (index) {
      return AnimatedBuilder(
        animation: _rotateAnimation,
        builder: (context, child) {
          final angle = (2 * math.pi / 8) * index;
          final distance = 150.0 + (index % 3) * 50;
          return Positioned(
            left: MediaQuery.of(context).size.width / 2 +
                math.cos(angle + _rotateAnimation.value) * distance -
                4,
            top: MediaQuery.of(context).size.height / 2 +
                math.sin(angle + _rotateAnimation.value) * distance -
                4,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _rotateAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotateAnimation.value * 0.1,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFF2C94C), Color(0xFFF59E0B)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF2C94C).withValues(alpha: 0.4),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0F0F0F),
              ),
              padding: const EdgeInsets.all(16),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/load.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                height: 1.0,
              ),
              children: [
                TextSpan(
                  text: 'Sakha',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'Live',
                  style: TextStyle(
                    color: Color(0xFFF2C94C),
                    shadows: [
                      Shadow(
                        color: Color(0xFFF2C94C),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        'Ваше любимое радио',
        style: TextStyle(
          fontSize: 14,
          color: Colors.white.withValues(alpha: 0.6),
          letterSpacing: 3,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Кольцевой индикатор
          AnimatedBuilder(
            animation: _rotateAnimation,
            builder: (context, child) {
              return SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Фоновое кольцо
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 2,
                        ),
                      ),
                    ),
                    // Вращающееся кольцо
                    Transform.rotate(
                      angle: _rotateAnimation.value,
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFFF2C94C),
                          ),
                        ),
                      ),
                    ),
                    // Центральный элемент
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF2C94C),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF2C94C).withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Текстовый индикатор
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              final progress = (_progressAnimation.value * 100).toInt();
              return Text(
                'Загрузка... $progress%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.5),
                  letterSpacing: 1,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
