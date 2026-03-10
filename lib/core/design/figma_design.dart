import 'package:flutter/material.dart';
import 'design.dart';

/// Константы дизайна из Figma
/// Экран: iPhone 14 & 15 Pro (393x852)
///
/// @deprecated Используйте новые дизайн-токены из [AppSpacing], [AppEffects]
class FigmaDesign {
  // Размеры экрана
  @Deprecated('Используйте MediaQuery.of(context).size.width')
  static const double screenWidth = 393.0;

  @Deprecated('Используйте MediaQuery.of(context).size.height')
  static const double screenHeight = 852.0;

  // Отступы → AppSpacing
  @Deprecated('Используйте AppSpacing.lg')
  static const double horizontalPadding = 16.0;

  @Deprecated('Используйте AppSpacing.lg')
  static const double verticalPadding = 16.0;

  @Deprecated('Используйте AppSpacing.lg')
  static const double gridSpacing = 16.0;

  // Закругления → AppEffects
  @Deprecated('Используйте AppEffects.radiusXl')
  static const double cardRadius = 24.0;

  @Deprecated('Используйте AppEffects.radiusFull')
  static const double buttonRadius = 40.0;

  @Deprecated('Используйте AppEffects.radiusLg')
  static const double miniPlayerRadius = 20.0;

  @Deprecated('Используйте AppEffects.radiusFull')
  static const double navBarRadius = 32.0;

  // Размеры карточек радиостанций
  @Deprecated('Используйте LayoutBuilder для адаптивности')
  static const double cardWidth = 156.0;

  @Deprecated('Используйте LayoutBuilder для адаптивности')
  static const double cardHeight = 179.0;

  // Мини-плеер
  @Deprecated('Хардкод высота, используйте constraints')
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

  // Шрифты → AppTypography
  @Deprecated('Используйте AppTypography.displaySmall')
  static const double fontSizeLogo = 26.0;

  @Deprecated('Используйте AppTypography.labelSmall')
  static const double fontSizeGreeting = 10.0;

  @Deprecated('Используйте AppTypography.titleLarge')
  static const double fontSizeStationFrequency = 20.0;

  @Deprecated('Используйте AppTypography.bodyMedium')
  static const double fontSizeStationName = 14.0;

  @Deprecated('Используйте AppTypography.titleMedium')
  static const double fontSizeMiniPlayerTitle = 14.0;

  @Deprecated('Используйте AppTypography.labelSmall')
  static const double fontSizeMiniPlayerStatus = 9.0;

  @Deprecated('Используйте AppTypography.titleLarge')
  static const double fontSizeFullPlayerTitle = 18.0;

  // Тени → AppEffects
  @Deprecated('Используйте AppEffects.shadowMd')
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 4)),
  ];

  @Deprecated('Используйте AppEffects.glowPrimary')
  static List<BoxShadow> cardActiveShadow = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: 2,
      offset: const Offset(0, 0),
    ),
    BoxShadow(
      color: AppColors.primary.withOpacity(0.15),
      blurRadius: 40,
      spreadRadius: 5,
      offset: const Offset(0, 0),
    ),
    BoxShadow(
      color: AppColors.primary.withOpacity(0.05),
      blurRadius: 60,
      spreadRadius: 10,
      offset: const Offset(0, 0),
    ),
  ];

  @Deprecated('Используйте AppEffects.shadowXl')
  static const List<BoxShadow> miniPlayerShadow = [
    BoxShadow(
      color: Color(0x80000000),
      blurRadius: 40,
      offset: Offset(0, 20),
      spreadRadius: 10,
    ),
    BoxShadow(color: Color(0x4D000000), blurRadius: 30, offset: Offset(0, 10)),
  ];

  @Deprecated('Используйте AppEffects.shadowLg')
  static const List<BoxShadow> navBarShadow = [
    BoxShadow(color: Color(0x99000000), blurRadius: 40, offset: Offset(0, -10)),
  ];

  @Deprecated('Используйте AppEffects.shadowPrimary')
  static const List<BoxShadow> headerLogoShadow = [
    BoxShadow(color: Color(0x4DF2C94C), blurRadius: 16, spreadRadius: 2),
  ];
}
