import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../core/design/design.dart';

/// Улучшенный EqualizerCard с расширенными возможностями
///
/// Особенности:
/// - Несколько режимов визуализации (бары, волны, круг)
/// - Адаптивная высота
/// - Цветные градиенты
/// - Плавные анимации
class EqualizerCard extends StatefulWidget {
  final bool isActive;
  final double width;
  final double height;
  final EqualizerMode mode;
  final Color? color;

  const EqualizerCard({
    super.key,
    required this.isActive,
    this.width = 200,
    this.height = 60,
    this.mode = EqualizerMode.bars,
    this.color,
  });

  @override
  State<EqualizerCard> createState() => _EqualizerCardState();
}

enum EqualizerMode {
  bars,      // Классические бары
  waves,     // Волны
  circular,  // Круговой
  dots,      // Точки
}

class _EqualizerCardState extends State<EqualizerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _barAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Создаем независимые анимации для каждого бара
    _barAnimations = List.generate(8, (index) {
      return Tween<double>(begin: 0.1, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.1,
            0.7 + index * 0.1,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _primaryColor => widget.color ?? AppColors.primary;

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return const SizedBox.shrink();
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppEffects.radiusLg),
        border: Border.all(
          color: _primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppEffects.radiusLg),
        child: _buildEqualizer(),
      ),
    );
  }

  Widget _buildEqualizer() {
    switch (widget.mode) {
      case EqualizerMode.bars:
        return _buildBars();
      case EqualizerMode.waves:
        return _buildWaves();
      case EqualizerMode.circular:
        return _buildCircular();
      case EqualizerMode.dots:
        return _buildDots();
    }
  }

  Widget _buildBars() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(8, (index) {
          return AnimatedBuilder(
            animation: _barAnimations[index],
            builder: (context, child) {
              final height = 8.0 +
                  _barAnimations[index].value * (widget.height - 24);
              return Container(
                width: 6,
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      _primaryColor.withValues(alpha: 0.6),
                      _primaryColor,
                      AppColors.primaryLight,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppEffects.radiusSm),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildWaves() {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.width, widget.height),
            painter: WavePainter(
              progress: _controller.value,
              color: _primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCircular() {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: CustomPaint(
              size: Size(widget.height, widget.height),
              painter: CircularEqualizerPainter(
                progress: _controller.value,
                color: _primaryColor,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDots() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(12, (index) {
          return AnimatedBuilder(
            animation: _barAnimations[index % 8],
            builder: (context, child) {
              final scale = 0.3 + _barAnimations[index % 8].value * 0.7;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor.withValues(alpha: 0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/// Painter для волнового эффекта
class WavePainter extends CustomPainter {
  final double progress;
  final Color color;

  WavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final width = size.width;
    final height = size.height;

    path.moveTo(0, height / 2);

    for (double x = 0; x <= width; x++) {
      final normalizedX = x / width;
      final wave = math.sin((normalizedX + progress) * 2 * math.pi) *
          (height / 3);
      path.lineTo(x, height / 2 + wave);
    }

    canvas.drawPath(path, paint);

    // Вторая волна с прозрачностью
    paint.color = color.withValues(alpha: 0.4);
    final path2 = Path();
    path2.moveTo(0, height / 2);

    for (double x = 0; x <= width; x++) {
      final normalizedX = x / width;
      final wave = math.sin((normalizedX + progress + 0.5) * 2 * math.pi) *
          (height / 4);
      path2.lineTo(x, height / 2 + wave);
    }

    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}

/// Painter для кругового эквалайзера
class CircularEqualizerPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularEqualizerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * math.pi;
      final normalizedProgress = (progress + i * 0.05) % 1.0;
      final barLength = 8 + normalizedProgress * (radius - 16);

      final paint = Paint()
        ..color = color.withValues(alpha: 0.6 + normalizedProgress * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      final start = Offset(
        center.dx + math.cos(angle) * 12,
        center.dy + math.sin(angle) * 12,
      );

      final end = Offset(
        center.dx + math.cos(angle) * (12 + barLength),
        center.dy + math.sin(angle) * (12 + barLength),
      );

      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(CircularEqualizerPainter oldDelegate) => true;
}
