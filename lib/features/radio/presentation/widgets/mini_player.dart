import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
import 'package:audio_service/audio_service.dart' as as_service;

import '../../../../core/design/design.dart';
import '../../../../widgets/equalizer_animation.dart';
import '../../../../widgets/shimmer_widget.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../domain/station.dart';
import '../providers/player_provider.dart' as sakha_live;
import '../providers/player_provider.dart';
import '../../../../core/providers.dart';
import '../../../player/full_player_screen.dart';
import '../../../../core/utils/logger.dart';

/// Улучшенный MiniPlayer с жестами и расширенными анимациями
///
/// Особенности:
/// - Свайп вверх для открытия слайдера громкости
/// - Свайп вправо/влево для переключения треков
/// - Двойное тап для паузы/воспроизведения
/// - Haptic feedback для всех взаимодействий
/// - Пульсирующая анимация обложки при воспроизведении
/// - Градиентные эффекты
/// - Автоматическая синхронизация метаданных из sequenceStateStream
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

  // Подписка на mediaItem для синхронизации метаданных
  StreamSubscription<as_service.MediaItem?>? _sequenceStateSubscription;

  // Флаг: играет ли сейчас трек из чарта (не радио)
  bool _isPlayingTrack = false;

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

    // Подписываемся на sequenceStateStream для обновления метаданных
    _subscribeToMediaItem();
  }

  void _subscribeToMediaItem() {
    final audioHandler = ref.read(audioHandlerProvider);
    if (audioHandler == null) return;

    // Подписываемся на mediaItemStream для синхронизации метаданных
    _sequenceStateSubscription = audioHandler.mediaItem.listen((mediaItem) {
      if (!mounted) return;

      if (mediaItem != null) {
        // Проверяем тип контента по URL
        final uriString = mediaItem.artUri.toString();
        final isStream =
            mediaItem.id.contains('stream://') ||
            uriString.contains('/stream/') ||
            uriString.contains('.m3u') ||
            uriString.contains('.pls');

        setState(() {
          _isPlayingTrack = !isStream;
        });

        Logger.log(
          'MiniPlayer: mediaItem updated, isPlayingTrack=$_isPlayingTrack, title=${mediaItem.title}, artUri=$uriString',
          tag: 'MiniPlayer',
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    _sequenceStateSubscription?.cancel();
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
        // Определяем тип контента: радио или трек
        // Приоритет: sequenceStateStream > playerState
        final isPlayingTrack =
            _isPlayingTrack ||
            (playerState.currentStation == null &&
                playerState.trackTitle != null &&
                playerState.trackTitle != playerState.currentStation?.name);

        // Плеер виден если:
        // 1. Есть активная станция (радио)
        // 2. Или есть активный трек (не радио)
        // 3. Или идет буферизация
        // Пауза НЕ скрывает плеер!
        final hasActiveStation = playerState.currentStation != null;
        final hasActiveTrack =
            playerState.currentStation == null &&
            playerState.currentTrackId != null;
        final isVisible =
            hasActiveStation || hasActiveTrack || playerState.isBuffering;

        return AnimatedOpacity(
          duration: AppEffects.durationSlow,
          curve: AppEffects.curve,
          opacity: isVisible ? 1.0 : 0.0,
          child: isVisible
              ? _buildPlayerUI(context, ref, playerState, isPlayingTrack)
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

    // Свайп влево/вправо для переключения станций (только для радио)
    final isPlayingTrack =
        playerState.currentStation == null && playerState.trackTitle != null;

    if (!isPlayingTrack && _dragOffsetX.abs() > 80) {
      final stations = ref.read(stationListProvider);
      final currentIndex = stations.indexWhere(
        (s) => s.id == playerState.currentStation?.id,
      );

      if (currentIndex >= 0) {
        if (_dragOffsetX > 0 && currentIndex > 0) {
          // Свайп вправо - предыдущая станция
          if (!kIsWeb) HapticFeedback.mediumImpact();
          playerNotifier.playStation(stations[currentIndex - 1]);
        } else if (_dragOffsetX < 0 && currentIndex < stations.length - 1) {
          // Свайп влево - следующая станция
          if (!kIsWeb) HapticFeedback.mediumImpact();
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
    sakha_live.PlayerState playerState,
    bool isPlayingTrack,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isBuffering = playerState.isBuffering;

    // Определяем отображаемые данные на основе типа контента
    // Для трека (iTunes/Chart): показываем название песни и артиста
    // Для радио: показываем название станции и "ПРЯМОЙ ЭФИР" или метаданные трека
    final displayTitle = isPlayingTrack
        ? (playerState.trackTitle ?? 'SakhaLive')
        : (playerState.currentStation?.name ?? 'SakhaLive');

    final currentStation = playerState.currentStation;

    // Вторая строка: артист (для трека) или статус (для радио)
    String? displaySubtitle;
    if (isPlayingTrack) {
      // Трек из чарта: показываем артиста
      displaySubtitle = playerState.trackArtist;
    } else {
      // Радио: показываем метаданные трека (если есть) или "ПРЯМОЙ ЭФИР"
      final hasRadioMetadata =
          playerState.trackTitle != null &&
          playerState.trackTitle != currentStation?.name;
      if (hasRadioMetadata) {
        displaySubtitle = playerState.trackTitle;
      }
      // Если нет метаданных, displaySubtitle останется null — покажем "ПРЯМОЙ ЭФИР"
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Основной контейнер мини-плеера
        GestureDetector(
          onTap: () {
            _triggerBounce();
            if (!kIsWeb) HapticFeedback.lightImpact();
            // Открыть полный плеер
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const FullPlayerScreen()),
            );
          },
          onDoubleTap: () {
            _triggerBounce();
            if (!kIsWeb) HapticFeedback.mediumImpact();
            if (playerState.isPlaying) {
              ref.read(playerProvider.notifier).stop();
            } else {
              // Если играет трек из чарта - показываем сообщение
              if (isPlayingTrack) {
                SnackbarHelper.showError(
                  context: context,
                  message: 'Нажмите на трек в списке для воспроизведения',
                );
              } else if (currentStation != null) {
                ref.read(playerProvider.notifier).playStation(currentStation);
              }
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
                        colors: [
                          SakhaFuturism.glassFill(
                            isDark,
                            opacity: _isHovered ? 0.84 : 0.76,
                          ),
                          SakhaFuturism.glassFill(
                            isDark,
                            opacity: _isHovered ? 0.62 : 0.54,
                          ),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppEffects.radiusFull,
                      ),
                      border: Border.all(
                        color: SakhaFuturism.glassBorder(
                          isDark,
                          accent: theme.primaryColor,
                        ),
                      ),
                      boxShadow: SakhaFuturism.shadow(
                        isDark,
                        accent: theme.primaryColor,
                        lift: _isHovered ? 1.15 : 1.05,
                      ),
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
                                isPlayingTrack,
                                isDark,
                              ),
                            );
                          },
                        ),
                        SizedBox(width: AppSpacing.sm),
                        // Информация о треке/станции
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Название (трека или станции)
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
                                      displayTitle,
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
                              // Вторая строка: артист (для трека) ИЛИ "ПРЯМОЙ ЭФИР"/метаданные (для радио)
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
                                  : displaySubtitle != null &&
                                        displaySubtitle.isNotEmpty
                                  ? isPlayingTrack
                                        ? // Трек: показываем артиста
                                          Text(
                                            displaySubtitle,
                                            style: GoogleFonts.inter(
                                              color: isDark
                                                  ? theme.primaryColor
                                                  : AppColors.primaryDark,
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                              height: 1.0,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : // Радио: показываем метаданные трека (бегущая строка)
                                          SizedBox(
                                            height: 14,
                                            child: Marquee(
                                              text: displaySubtitle,
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
                                              accelerationDuration:
                                                  const Duration(
                                                    milliseconds: 500,
                                                  ),
                                              accelerationCurve:
                                                  Curves.easeInOut,
                                              decelerationDuration:
                                                  const Duration(
                                                    milliseconds: 500,
                                                  ),
                                              decelerationCurve:
                                                  Curves.easeInOut,
                                            ),
                                          )
                                  : // "ПРЯМОЙ ЭФИР" если нет метаданных
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
                              if (!kIsWeb) HapticFeedback.lightImpact();

                              final playerNotifier = ref.read(
                                playerProvider.notifier,
                              );

                              if (playerState.isPlaying) {
                                // Пауза - не скрывает плеер!
                                await playerNotifier.stop();
                              } else {
                                // Возобновление воспроизведения
                                try {
                                  // Если играет трек из чарта - возобновляем его
                                  if (isPlayingTrack &&
                                      playerState.currentTrackId != null) {
                                    // Получаем текущее состояние и возобновляем
                                    await playerNotifier.resume();
                                  } else if (currentStation != null) {
                                    // Радио - просто запускаем снова
                                    await playerNotifier.playStation(
                                      currentStation,
                                    );
                                  }
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
    sakha_live.PlayerState playerState,
    bool isPlayingTrack,
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
                : hasAlbumArt && isPlayingTrack
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
                      // Fallback на заглушку для треков
                      return _buildPlaceholderArt();
                    },
                  )
                : _buildStationArt(playerState.currentStation),
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

  Widget _buildStationArt(Station? currentStation) {
    if (currentStation != null && currentStation.art.isNotEmpty) {
      return Image.asset(
        currentStation.art,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderArt();
        },
      );
    }
    // Для треков из чарта показываем заглушку
    return _buildPlaceholderArt();
  }

  Widget _buildPlaceholderArt() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(AppEffects.radiusMd),
      ),
      child: const Icon(Icons.music_note, color: Colors.white, size: 20),
    );
  }
}
