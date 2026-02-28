import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';

import '../../../../core/design/design.dart';
import '../../../../widgets/equalizer_animation.dart';
import '../../../../widgets/shimmer_widget.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../domain/station.dart';
import '../providers/player_provider.dart';
import '../../../../core/providers/radio_providers.dart';
import '../../../player/full_player_screen.dart';

/// Улучшенный MiniPlayer с жестами и расширенными анимациями
///
/// Особенности:
/// - Свайп вверх для открытия слайдера громкости
/// - Свайп вправо/влево для переключения треков
/// - Двойное тап для паузы/воспроизведения
/// - Haptic feedback для всех взаимодействий
/// - Пульсирующая анимация обложки при воспроизведении
/// - Градиентные эффекты
class MiniPlayer extends ConsumerStatefulWidget {
  const MiniPlayer({super.key});

  @override
  ConsumerState<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends ConsumerState<MiniPlayer>
    with TickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  double _dragOffsetX = 0;

  @override
  void initState() {
    super.initState();

    // Пульсация для обложки
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Bounce анимация для тапов
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _triggerBounce() {
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerAsync = ref.watch(playerProvider);

    return playerAsync.when(
      data: (playerState) {
        final isVisible =
            playerState.currentStation != null &&
            (playerState.isPlaying || playerState.isBuffering);

        return AnimatedOpacity(
          duration: AppEffects.durationSlow,
          curve: AppEffects.curve,
          opacity: isVisible ? 1.0 : 0.0,
          child: isVisible
              ? _buildPlayerUI(
                  context,
                  ref,
                  playerState,
                  playerState.currentStation!,
                )
              : const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _dragOffsetX = 0;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffsetX += details.delta.dx;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final playerNotifier = ref.read(playerProvider.notifier);
    final playerState = ref.read(playerProvider).value;

    if (playerState == null) return;

    // Свайп влево/вправо для переключения станций
    if (_dragOffsetX.abs() > 80) {
      final stations = ref.read(stationListProvider);
      final currentIndex = stations.indexWhere(
        (s) => s.id == playerState.currentStation?.id,
      );

      if (currentIndex >= 0) {
        if (_dragOffsetX > 0 && currentIndex > 0) {
          // Свайп вправо - предыдущая станция
          HapticFeedback.mediumImpact();
          playerNotifier.playStation(stations[currentIndex - 1]);
        } else if (_dragOffsetX < 0 && currentIndex < stations.length - 1) {
          // Свайп влево - следующая станция
          HapticFeedback.mediumImpact();
          playerNotifier.playStation(stations[currentIndex + 1]);
        }
      }
    }

    setState(() {
      _dragOffsetX = 0;
    });
  }

  Widget _buildPlayerUI(
    BuildContext context,
    WidgetRef ref,
    PlayerState playerState,
    Station currentStation,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isBuffering = playerState.isBuffering;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Основной контейнер мини-плеера
        GestureDetector(
          onTap: () {
            _triggerBounce();
            HapticFeedback.lightImpact();
            // Открыть полный плеер
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const FullPlayerScreen()),
            );
          },
          onDoubleTap: () {
            _triggerBounce();
            HapticFeedback.mediumImpact();
            if (playerState.isPlaying) {
              ref.read(playerProvider.notifier).stop();
            } else {
              ref.read(playerProvider.notifier).playStation(currentStation);
            }
          },
          onPanStart: _handleDragStart,
          onPanUpdate: _handleDragUpdate,
          onPanEnd: _handleDragEnd,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bounceAnimation.value,
                  child: AnimatedContainer(
                    duration: AppEffects.durationNormal,
                    curve: AppEffects.curve,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                AppColors.cardBackground.withValues(
                                  alpha: 0.98,
                                ),
                                AppColors.surface.withValues(alpha: 0.95),
                              ]
                            : [
                                Colors.white.withValues(alpha: 1.0),
                                Colors.white.withValues(alpha: 0.95),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppEffects.radiusFull,
                      ),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                      boxShadow: _isHovered
                          ? [
                              ...AppEffects.shadowLg,
                              BoxShadow(
                                color: theme.primaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                blurRadius: 20,
                                spreadRadius: 1,
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.5 : 0.05,
                                ),
                                blurRadius: isDark ? 40 : 10,
                                offset: const Offset(0, 10),
                              ),
                            ],
                    ),
                    constraints: const BoxConstraints(maxWidth: 280),
                    height: 64.0,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Анимированная обложка
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: playerState.isPlaying && !isBuffering
                                  ? _pulseAnimation.value
                                  : 1.0,
                              child: _buildAlbumArt(
                                context,
                                ref,
                                playerState,
                                currentStation,
                                isDark,
                              ),
                            );
                          },
                        ),
                        SizedBox(width: AppSpacing.sm),
                        // Информация о станции
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Название станции
                              isBuffering
                                  ? ShimmerWidget.text(
                                      width: 120,
                                      height: 14,
                                      textStyle: GoogleFonts.inter(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13.0,
                                        letterSpacing: -0.5,
                                      ),
                                    )
                                  : Text(
                                      currentStation.name,
                                      style: GoogleFonts.inter(
                                        color: theme.colorScheme.onSurface,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13.0,
                                        letterSpacing: -0.5,
                                        height: 1.0,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                              SizedBox(height: AppSpacing.xs),
                              // Название трека (бегущая строка) или "ПРЯМОЙ ЭФИР"
                              isBuffering
                                  ? ShimmerWidget.text(
                                      width: 80,
                                      height: 10,
                                      textStyle: GoogleFonts.inter(
                                        color: isDark
                                            ? theme.primaryColor
                                            : AppColors.primaryDark,
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                      ),
                                    )
                                  : playerState.trackTitle != null &&
                                        playerState.trackTitle!.isNotEmpty
                                  ? // Бегущая строка с названием трека
                                    SizedBox(
                                      height: 14,
                                      child: Marquee(
                                        text: playerState.trackTitle!,
                                        style: GoogleFonts.inter(
                                          color: isDark
                                              ? theme.primaryColor
                                              : AppColors.primaryDark,
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                          height: 1.0,
                                        ),
                                        velocity: 30,
                                        blankSpace: 50,
                                        startPadding: 0,
                                        accelerationDuration: const Duration(
                                          milliseconds: 500,
                                        ),
                                        accelerationCurve: Curves.easeInOut,
                                        decelerationDuration: const Duration(
                                          milliseconds: 500,
                                        ),
                                        decelerationCurve: Curves.easeInOut,
                                      ),
                                    )
                                  : // "ПРЯМОЙ ЭФИР" если нет названия трека
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 5,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? theme.primaryColor
                                                : AppColors.primaryDark,
                                          ),
                                        ),
                                        SizedBox(width: AppSpacing.xs),
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          ).live_broadcast,
                                          style: GoogleFonts.inter(
                                            color: isDark
                                                ? theme.primaryColor
                                                : AppColors.primaryDark,
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.2,
                                            height: 1.0,
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        // Кнопка Play/Pause с анимацией
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () async {
                              _triggerBounce();
                              HapticFeedback.lightImpact();
                              if (playerState.isPlaying) {
                                ref.read(playerProvider.notifier).stop();
                              } else {
                                try {
                                  await ref
                                      .read(playerProvider.notifier)
                                      .playStation(currentStation);
                                } catch (e) {
                                  if (context.mounted) {
                                    SnackbarHelper.showError(
                                      context: context,
                                      message: e.toString(),
                                    );
                                  }
                                }
                              }
                            },
                            child: AnimatedContainer(
                              duration: AppEffects.durationFast,
                              curve: AppEffects.curve,
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    theme.primaryColor,
                                    theme.primaryColor.withValues(alpha: 0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: _isHovered
                                    ? AppEffects.glowPrimary
                                    : AppEffects.shadowPrimary,
                              ),
                              child: isBuffering
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                      ),
                                    )
                                  : Icon(
                                      playerState.isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      color: Colors.black,
                                      size: 22,
                                    ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildAlbumArt(
    BuildContext context,
    WidgetRef ref,
    PlayerState playerState,
    Station currentStation,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final isBuffering = playerState.isBuffering;

    // Используем обложку из метаданных или картинку станции
    final albumArtUrl = playerState.albumArt;
    final hasAlbumArt = albumArtUrl != null && albumArtUrl.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppEffects.radiusMd),
          child: SizedBox(
            width: 44,
            height: 44,
            child: isBuffering
                ? Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardBackground
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(AppEffects.radiusMd),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  )
                : hasAlbumArt
                ? Image.network(
                    albumArtUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.cardBackground
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(
                            AppEffects.radiusMd,
                          ),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.primaryColor,
                              ),
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded
                                            .toDouble() /
                                        loadingProgress.expectedTotalBytes!
                                            .toDouble()
                                  : null,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback на картинку станции
                      return _buildStationArt(currentStation);
                    },
                  )
                : _buildStationArt(currentStation),
          ),
        ),
        if (playerState.isPlaying && !isBuffering) ...[
          // Пульсирующее кольцо вокруг обложки
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppEffects.radiusMd),
                border: Border.all(
                  color: theme.primaryColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
            ),
          ),
          // Индикатор воспроизведения
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppEffects.radiusMd),
                color: Colors.black.withValues(alpha: 0.40),
              ),
              child: Center(
                child: EqualizerAnimation(isActive: true, size: 20),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStationArt(Station currentStation) {
    return Image.asset(
      currentStation.art,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(AppEffects.radiusMd),
          ),
          child: const Icon(Icons.music_note, color: Colors.white, size: 20),
        );
      },
    );
  }
}
