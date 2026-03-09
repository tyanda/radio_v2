import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:sakha_live/features/radio/domain/station.dart';

import '../../../../core/design/design.dart';

/// Оптимизированная карточка радиостанции
///
/// Оптимизации:
/// - ImageCache для предотвращения повторной загрузки обложек
/// - RepaintBoundary для изоляции перерисовки
/// - Пауза анимаций при скрытии
/// - Кэширование акцентного цвета
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
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  late AnimationController _liveController;
  late Animation<double> _liveAnimation;
  late Future<Color> _accentFuture;

  bool _isHovered = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _hoverController = AnimationController(
      duration: AppEffects.durationNormal,
      vsync: this,
    );

    _hoverAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );

    _liveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _liveAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _liveController, curve: Curves.easeInOut),
    );

    _accentFuture = _resolveAccentColor();
  }

  @override
  void didUpdateWidget(covariant RadioCardV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.station.id != widget.station.id ||
        oldWidget.station.logoUrl != widget.station.logoUrl ||
        oldWidget.station.art != widget.station.art) {
      _accentFuture = _resolveAccentColor();
    }
  }

  // Автоматическая пауза анимаций при скрытии экрана
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // Пауза всех анимаций для экономии ресурсов
        _pulseController.stop();
        _liveController.stop();
        break;
      case AppLifecycleState.resumed:
        // Восстановление анимаций
        if (!_pulseController.isAnimating) {
          _pulseController.repeat(reverse: true);
        }
        if (!_liveController.isAnimating) {
          _liveController.repeat();
        }
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
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
                child: FutureBuilder<Color>(
                  future: _accentFuture,
                  builder: (context, snapshot) {
                    final accentColor =
                        snapshot.data ?? theme.colorScheme.primary;
                    return _buildCard(theme, isDark, accentColor);
                  },
                ),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isActive
              ? [
                  accentColor.withValues(alpha: 0.95),
                  Color.alphaBlend(
                    AppColors.primary.withValues(alpha: 0.18),
                    accentColor.withValues(alpha: 0.76),
                  ),
                ]
              : [
                  SakhaFuturism.glassFill(
                    isDark,
                    opacity: _isHovered ? 0.80 : 0.74,
                  ),
                  Color.alphaBlend(
                    accentColor.withValues(alpha: _isHovered ? 0.16 : 0.08),
                    SakhaFuturism.glassFill(
                      isDark,
                      opacity: _isHovered ? 0.58 : 0.50,
                    ),
                  ),
                ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: widget.isActive
              ? accentColor.withValues(alpha: 0.95)
              : SakhaFuturism.glassBorder(isDark, accent: accentColor),
          width: widget.isActive ? 1.4 : (_isHovered ? 1.2 : 1),
        ),
        boxShadow: [
          ...SakhaFuturism.shadow(
            isDark,
            accent: accentColor,
            lift: widget.isActive ? 1.25 : (_isHovered ? 1.12 : 1),
          ),
          if (widget.isActive)
            BoxShadow(
              color: accentColor.withValues(alpha: 0.34),
              blurRadius: 36,
              spreadRadius: 2,
              offset: const Offset(0, 14),
            ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (widget.isActive)
            Positioned(
              right: -5,
              bottom: -5,
              child: Opacity(
                opacity: 0.45,
                child: Lottie.asset(
                  'assets/animations/radio_pulse.json',
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(
              top: 10,
              left: 12,
              right: 12,
              bottom: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildImageSection(accentColor)),
                const SizedBox(height: 12),
                _buildTextSection(theme, accentColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(Color accentColor) {
    final hasLogoUrl =
        widget.station.logoUrl != null && widget.station.logoUrl!.isNotEmpty;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black.withValues(alpha: 0.92),
                accentColor.withValues(alpha: 0.30),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: widget.isActive ? 0.18 : 0.08,
              ),
            ),
          ),
          child: hasLogoUrl
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  // Оптимизация: CachedNetworkImage с кэшем под размер карточки
                  child: CachedNetworkImage(
                    imageUrl: widget.station.logoUrl!,
                    fit: BoxFit.cover,
                    // Кэширование с размером под карточку (~120x120px)
                    memCacheWidth: 256,
                    memCacheHeight: 256,
                    maxWidthDiskCache: 256,
                    maxHeightDiskCache: 256,
                    fadeInDuration: const Duration(milliseconds: 300),
                    fadeOutDuration: const Duration(milliseconds: 300),
                    cacheKey: widget.station.id,
                    useOldImageOnUrlChange: true,
                    placeholder: (context, url) => _buildPlaceholder(),
                    errorWidget: (context, url, error) => _buildPlaceholder(),
                  ),
                )
              : widget.station.art.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  // Оптимизация: Image.asset с кэшированием под размер
                  child: Image.asset(
                    widget.station.art,
                    fit: BoxFit.cover,
                    cacheWidth: 256,
                    cacheHeight: 256,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholder();
                    },
                  ),
                )
              : _buildPlaceholder(),
        ),
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
                    borderRadius: BorderRadius.circular(AppEffects.radiusFull),
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
                      color: Colors.black.withValues(alpha: 0.44),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.16),
                      ),
                    ),
                    child: Icon(
                      widget.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline_rounded,
                      color: widget.isFavorite
                          ? const Color(0xFFFF4B5C)
                          : Colors.white,
                      size: 18,
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

  Widget _buildTextSection(ThemeData theme, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.station.name.toUpperCase(),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: widget.isActive ? Colors.black : theme.colorScheme.onSurface,
            letterSpacing: -0.4,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (widget.station.desc.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            widget.station.desc,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 10,
              color: widget.isActive
                  ? Colors.black.withValues(alpha: 0.66)
                  : theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Future<Color> _resolveAccentColor() async {
    try {
      final ImageProvider? provider =
          widget.station.logoUrl != null && widget.station.logoUrl!.isNotEmpty
          ? CachedNetworkImageProvider(widget.station.logoUrl!)
          : widget.station.art.isNotEmpty
          ? AssetImage(widget.station.art)
          : null;

      if (provider == null) {
        return AppColors.primary;
      }

      final palette = await PaletteGenerator.fromImageProvider(
        provider,
        size: const Size(96, 96),
        maximumColorCount: 12,
      );

      return palette.vibrantColor?.color ??
          palette.dominantColor?.color ??
          palette.lightVibrantColor?.color ??
          AppColors.primary;
    } catch (_) {
      return AppColors.primary;
    }
  }
}

enum ViewType { grid, list, horizontal }
