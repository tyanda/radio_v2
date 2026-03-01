import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:radio_v2/features/radio/domain/station.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/design/design.dart';

/// Улучшенная карточка радиостанции v2
///
/// Особенности:
/// - LIVE бейдж для активной станции
/// - Частота на карточке
/// - Улучшенная визуальная иерархия
/// - Пульсирующая анимация для избранных
/// - Hover-эффекты для desktop/web
/// - 3D tilt эффект при наведении
class RadioCardV2 extends StatefulWidget {
  final Station station;
  final bool isActive;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onShare;
  final ViewType viewType;

  const RadioCardV2({
    super.key,
    required this.station,
    required this.isActive,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
    this.onLongPress,
    this.onShare,
    this.viewType = ViewType.grid,
  });

  @override
  State<RadioCardV2> createState() => _RadioCardV2State();
}

class _RadioCardV2State extends State<RadioCardV2>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  late AnimationController _liveController;
  late Animation<double> _liveAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    // Пульсация для избранных
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Hover анимация
    _hoverController = AnimationController(
      duration: AppEffects.durationNormal,
      vsync: this,
    );

    _hoverAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );

    // LIVE бейдж анимация
    _liveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _liveAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _liveController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _hoverController.dispose();
    _liveController.dispose();
    super.dispose();
  }

  void _onHoverEnter() {
    setState(() => _isHovered = true);
    _hoverController.forward();
  }

  void _onHoverExit() {
    setState(() => _isHovered = false);
    _hoverController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _onHoverEnter(),
      onExit: (_) => _onHoverExit(),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap?.call();
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          widget.onLongPress?.call();
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([_hoverAnimation, _pulseAnimation]),
          builder: (context, child) {
            // 3D tilt эффект
            final tiltAngle = _hoverAnimation.value * 0.03;
            final scale = 1.0 + (_hoverAnimation.value * 0.02);

            return Transform.scale(
              scale: scale,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(tiltAngle)
                  ..rotateY(-tiltAngle),
                child: _buildCard(theme, isDark, accentColor),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(ThemeData theme, bool isDark, Color accentColor) {
    return AnimatedContainer(
      duration: AppEffects.durationSlow,
      curve: Curves.easeInOut,
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        gradient: widget.isActive
            ? LinearGradient(
                colors: [accentColor, accentColor.withValues(alpha: 0.9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : _isHovered
            ? LinearGradient(
                colors: isDark
                    ? [
                        AppColors.cardBackground.withValues(alpha: 0.98),
                        AppColors.surface.withValues(alpha: 0.95),
                      ]
                    : [
                        Colors.white.withValues(alpha: 1.0),
                        Colors.white.withValues(alpha: 0.95),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: widget.isActive ? null : theme.cardColor,
        borderRadius: BorderRadius.circular(AppEffects.radius2xl),
        border: Border.all(
          color: widget.isActive
              ? accentColor
              : _isHovered
              ? accentColor.withValues(alpha: 0.5)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05)),
          width: widget.isActive ? 2.5 : (_isHovered ? 1.5 : 1.0),
        ),
        boxShadow: widget.isActive
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.4),
                  blurRadius: 24,
                  spreadRadius: 3,
                  offset: const Offset(0, 4),
                ),
              ]
            : _isHovered
            ? [
                ...AppEffects.shadowLg,
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.15),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : (!isDark
                  ? [
                      BoxShadow(
                        color: const Color(0xFF000000).withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null),
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
            padding: const EdgeInsets.only(
              top: 8.0,
              left: 12.0,
              right: 12.0,
              bottom: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Изображение с LIVE бейджем
                Expanded(child: _buildImageSection(isDark, accentColor)),

                // Вертикальный отступ
                const SizedBox(height: 12.0),

                // Текстовый блок
                _buildTextSection(theme, isDark, accentColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(bool isDark, Color accentColor) {
    final hasLogoUrl =
        widget.station.logoUrl != null && widget.station.logoUrl!.isNotEmpty;

    return Stack(
      children: [
        // Контейнер с изображением
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF000000),
            borderRadius: BorderRadius.circular(AppEffects.radiusXl),
          ),
          child: hasLogoUrl
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(AppEffects.radiusXl),
                  child: CachedNetworkImage(
                    imageUrl: widget.station.logoUrl!,
                    fit: BoxFit.cover,
                    fadeInDuration: const Duration(milliseconds: 300),
                    fadeOutDuration: const Duration(milliseconds: 300),
                    placeholder: (context, url) => _buildPlaceholder(),
                    errorWidget: (context, url, error) => _buildPlaceholder(),
                  ),
                )
              : widget.station.art.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(AppEffects.radiusXl),
                  child: Image.asset(
                    widget.station.art,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholder();
                    },
                  ),
                )
              : _buildPlaceholder(),
        ),

        // LIVE бейдж для активной станции
        if (widget.isActive)
          Positioned(
            top: 8,
            left: 8,
            child: AnimatedBuilder(
              animation: _liveAnimation,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: _liveAnimation.value),
                    borderRadius: BorderRadius.circular(AppEffects.radiusSm),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        // Иконка избранного с пульсацией
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
                  scale: widget.isFavorite ? _pulseAnimation.value : 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
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
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.radio,
            color: Colors.grey.withValues(alpha: 0.5),
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            widget.station.icon,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSection(ThemeData theme, bool isDark, Color accentColor) {
    return Column(
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
              fontSize: 15,
              color: widget.isActive
                  ? Colors.black
                  : theme.colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Описание
        if (widget.station.desc.isNotEmpty)
          Text(
            widget.station.desc,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 10,
              color: widget.isActive
                  ? Colors.black.withValues(alpha: 0.6)
                  : theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

/// Типы отображения карточек
enum ViewType { grid, list, horizontal }
