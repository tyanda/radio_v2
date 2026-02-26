import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:radio_v2/features/radio/domain/station.dart';

/// Вертикальная карточка радиостанции в стиле «плитка»
///
/// Архитектурные принципы:
/// - Реактивность: анимация смены состояний через AnimatedContainer
/// - Автономность: занимает всё доступное пространство родителя
/// - Безопасность контента: maxLines и TextOverflow.ellipsis
class VerticalRadioCard extends StatefulWidget {
  final Station station;
  final bool isActive;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onLongPress;

  const VerticalRadioCard({
    super.key,
    required this.station,
    required this.isActive,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
    this.onLongPress,
  });

  @override
  State<VerticalRadioCard> createState() => _VerticalRadioCardState();
}

class _VerticalRadioCardState extends State<VerticalRadioCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: () {
        HapticFeedback.mediumImpact();
        widget.onLongPress?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        clipBehavior: Clip.none,
        decoration: BoxDecoration(
          color: widget.isActive 
              ? accentColor 
              : theme.cardColor,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
            color: widget.isActive
                ? accentColor
                : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
            width: widget.isActive ? 1.5 : 1.0,
          ),
          boxShadow: widget.isActive
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 0),
                  ),
                ]
              : (!isDark ? [
                  BoxShadow(
                    color: const Color(0xFF000000).withValues(alpha: 0.05), // Тень 0.05 alpha
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ] : null),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Анимация для активной станции
            if (widget.isActive)
              Positioned(
                right: -5,
                bottom: -5,
                child: Opacity(
                  opacity: 0.45,
                  child: Lottie.network(
                    'https://lottie.host/8e89f648-7d43-4177-8742-99079f53526c/rRzYqXlXjU.json',
                    width: 70,
                    height: 70,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),

            // Основной контент
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Изображение (логотип) — сверху, занимает всё доступное пространство
                  Expanded(
                    child: Stack(
                      children: [
                        // Контейнер с изображением
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF000000),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: widget.station.art.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16.0),
                                  child: Image.asset(
                                    widget.station.art,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          Icons.radio,
                                          color: Colors.grey,
                                          size: 24,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.radio,
                                    color: Colors.grey,
                                    size: 24,
                                  ),
                                ),
                        ),

                        // Иконка избранного поверх изображения с пульсацией
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              widget.onFavoriteTap?.call();
                            },
                            child: AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.4,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      widget.isFavorite
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_outline_rounded,
                                      color: widget.isFavorite
                                          ? const Color(0xFFFF0000)
                                          : Colors.white,
                                      size: 18.0,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Вертикальный отступ
                  const SizedBox(height: 12.0),

                  // Текстовый блок снизу
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Название станции
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.station.name.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w900,
                            fontSize: 16.0,
                            color: widget.isActive
                                ? Colors.black
                                : theme.colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Подзаголовок (описание)
                      if (widget.station.desc.isNotEmpty)
                        Text(
                          widget.station.desc,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 10.0,
                            color: widget.isActive 
                                ? Colors.black.withValues(alpha: 0.7)
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
