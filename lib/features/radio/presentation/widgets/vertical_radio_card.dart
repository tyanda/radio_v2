import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:radio_v2/core/theme/app_colors.dart';

/// Вертикальная карточка радиостанции в стиле «плитка»
/// 
/// Архитектурные принципы:
/// - Реактивность: анимация смены состояний через AnimatedContainer
/// - Автономность: занимает всё доступное пространство родителя
/// - Безопасность контента: maxLines и TextOverflow.ellipsis
class VerticalRadioCard extends StatelessWidget {
  final dynamic station;
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        HapticFeedback.mediumImpact();
        onLongPress?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
            color: isActive ? AppColors.accent : Colors.white.withValues(alpha: 0.08),
            width: isActive ? 1.5 : 1.0,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 0),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Анимация для активной станции
            if (isActive)
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
                          child: station.art.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16.0),
                                  child: Image.asset(
                                    station.art,
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

                        // Иконка избранного поверх изображения
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onFavoriteTap?.call();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_outline_rounded,
                                color: isFavorite
                                    ? const Color(0xFFFF0000)
                                    : Colors.white,
                                size: 18.0,
                              ),
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
                      Text(
                        station.name.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w900,
                          fontSize: 16.0,
                          color: isActive ? Colors.black : Colors.white,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Подзаголовок (описание)
                      if (station.desc.isNotEmpty)
                        Text(
                          station.desc,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 10.0,
                            color: Colors.white,
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
