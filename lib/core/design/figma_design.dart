import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Константы дизайна из Figma
/// Экран: iPhone 14 & 15 Pro (393x852)
class FigmaDesign {
  // Размеры экрана
  static const double screenWidth = 393.0;
  static const double screenHeight = 852.0;

  // Отступы
  static const double horizontalPadding = 16.0;
  static const double verticalPadding = 16.0;
  static const double gridSpacing = 16.0;

  // Закругления
  static const double cardRadius = 24.0;
  static const double buttonRadius = 40.0;
  static const double miniPlayerRadius = 20.0;
  static const double navBarRadius = 32.0;

  // Размеры карточек радиостанций
  static const double cardWidth = 156.0;
  static const double cardHeight = 179.0;

  // Мини-плеер
  static const double miniPlayerHeight = 80.0;
  static const double miniPlayerArtSize = 52.0;
  static const double miniPlayerButtonSize = 52.0;

  // Полный плеер
  static const double fullPlayerHeight = 136.0;
  static const double fullPlayerArtWidth = 107.0;
  static const double fullPlayerArtHeight = 93.0;
  static const double fullPlayerButtonSize = 58.0;

  // Навигация
  static const double navBarHeight = 64.0;
  static const double navIconSize = 24.0;
  static const double navActiveWidth = 80.0;
  static const double navActiveHeight = 50.0;

  // Бегущая строка
  static const double marqueeHeight = 33.0;

  // Заголовок
  static const double headerLogoSize = 40.0;
  static const double headerTitleSize = 30.0;
  static const double greetingSize = 10.0;

  // Шрифты
  static const double fontSizeLogo = 26.0;
  static const double fontSizeGreeting = 10.0;
  static const double fontSizeStationFrequency = 20.0;
  static const double fontSizeStationName = 14.0;
  static const double fontSizeMiniPlayerTitle = 14.0;
  static const double fontSizeMiniPlayerStatus = 9.0;
  static const double fontSizeFullPlayerTitle = 18.0;

  // Тени
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 4)),
  ];

  static List<BoxShadow> cardActiveShadow = [
    BoxShadow(
      color: AppColors.accent.withValues(alpha: 0.3),
      blurRadius: 20,
      spreadRadius: 2,
      offset: const Offset(0, 0),
    ),
    BoxShadow(
      color: AppColors.accent.withValues(alpha: 0.15),
      blurRadius: 40,
      spreadRadius: 5,
      offset: const Offset(0, 0),
    ),
    BoxShadow(
      color: AppColors.accent.withValues(alpha: 0.05),
      blurRadius: 60,
      spreadRadius: 10,
      offset: const Offset(0, 0),
    ),
  ];

  static const List<BoxShadow> miniPlayerShadow = [
    BoxShadow(
      color: Color(0x80000000),
      blurRadius: 40,
      offset: Offset(0, 20),
      spreadRadius: 10,
    ),
    BoxShadow(color: Color(0x4D000000), blurRadius: 30, offset: Offset(0, 10)),
  ];

  static const List<BoxShadow> navBarShadow = [
    BoxShadow(color: Color(0x99000000), blurRadius: 40, offset: Offset(0, -10)),
  ];

  static const List<BoxShadow> headerLogoShadow = [
    BoxShadow(color: Color(0x4DF2C94C), blurRadius: 16, spreadRadius: 2),
  ];
}
