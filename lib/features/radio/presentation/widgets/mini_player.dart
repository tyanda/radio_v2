import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
import 'package:audio_service/audio_service.dart' as as_service;
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/design/design.dart';
import '../../../../widgets/equalizer_animation.dart';
import '../../../../widgets/shimmer_widget.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../domain/station.dart';
import '../providers/player_provider.dart' show playerProvider;
import '../../../../core/providers.dart';
import '../../../player/full_player_screen.dart';

/// Оптимизированный MiniPlayer с изолированными анимациями и точечными подписками
class MiniPlayer extends ConsumerStatefulWidget {
  const MiniPlayer({super.key});

  @override
  ConsumerState<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends ConsumerState<MiniPlayer>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool _isHovered = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  double _dragOffsetX = 0;
  StreamSubscription<as_service.MediaItem?>? _sequenceStateSubscription;
  bool _isPlayingTrack = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _subscribeToMediaItem();
  }

  void _subscribeToMediaItem() {
    final audioHandler = ref.read(audioHandlerProvider);
    if (audioHandler == null) return;

    _sequenceStateSubscription = audioHandler.mediaItem.listen((mediaItem) {
      if (!mounted) return;
      if (mediaItem != null) {
        final uriString = mediaItem.artUri.toString();
        final isStream =
            mediaItem.id.contains('stream://') ||
            uriString.contains('/stream/') ||
            uriString.contains('.m3u') ||
            uriString.contains('.pls');

        if (_isPlayingTrack != !isStream) {
          setState(() {
            _isPlayingTrack = !isStream;
          });
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_pulseController.isAnimating) _pulseController.repeat(reverse: true);
    } else {
      if (_pulseController.isAnimating) _pulseController.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    _bounceController.dispose();
    _sequenceStateSubscription?.cancel();
    super.dispose();
  }

  void _triggerBounce() {
    _bounceController.forward().then((_) => _bounceController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    // ОПТИМИЗАЦИЯ: подписываемся только на необходимые поля состояния
    final isPlaying = ref.watch(playerProvider.select((s) => s.value?.isPlaying ?? false));
    final isBuffering = ref.watch(playerProvider.select((s) => s.value?.isBuffering ?? false));
    final trackTitle = ref.watch(playerProvider.select((s) => s.value?.trackTitle));
    final trackArtist = ref.watch(playerProvider.select((s) => s.value?.trackArtist));
    final albumArt = ref.watch(playerProvider.select((s) => s.value?.albumArt));
    final currentStation = ref.watch(playerProvider.select((s) => s.value?.currentStation));
    final currentTrackId = ref.watch(playerProvider.select((s) => s.value?.currentTrackId));

    // Логика видимости
    final hasActiveStation = currentStation != null;
    final hasActiveTrack = currentStation == null && currentTrackId != null;
    final isVisible = hasActiveStation || hasActiveTrack || isBuffering;

    if (!isVisible) return const SizedBox.shrink();

    return AnimatedOpacity(
      duration: AppEffects.durationSlow,
      curve: AppEffects.curve,
      opacity: 1.0,
      child: _buildPlayerUI(
        context, 
        isPlaying: isPlaying,
        isBuffering: isBuffering,
        trackTitle: trackTitle,
        trackArtist: trackArtist,
        albumArt: albumArt,
        currentStation: currentStation,
        currentTrackId: currentTrackId,
      ),
    );
  }

  void _handleDragEnd(DragEndDetails details) {
    final playerState = ref.read(playerProvider).value;
    if (playerState == null || playerState.currentStation == null) return;

    if (_dragOffsetX.abs() > 80) {
      final stations = ref.read(stationListProvider);
      final currentIndex = stations.indexWhere((s) => s.id == playerState.currentStation?.id);

      if (currentIndex >= 0) {
        if (_dragOffsetX > 0 && currentIndex > 0) {
          if (!kIsWeb) HapticFeedback.mediumImpact();
          ref.read(playerProvider.notifier).playStation(stations[currentIndex - 1]);
        } else if (_dragOffsetX < 0 && currentIndex < stations.length - 1) {
          if (!kIsWeb) HapticFeedback.mediumImpact();
          ref.read(playerProvider.notifier).playStation(stations[currentIndex + 1]);
        }
      }
    }
    setState(() => _dragOffsetX = 0);
  }

  Widget _buildPlayerUI(
    BuildContext context, {
    required bool isPlaying,
    required bool isBuffering,
    String? trackTitle,
    String? trackArtist,
    String? albumArt,
    Station? currentStation,
    String? currentTrackId,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isActuallyPlayingTrack = _isPlayingTrack || (currentStation == null && trackTitle != null);
    final displayTitle = isActuallyPlayingTrack ? (trackTitle ?? 'SakhaLive') : (currentStation?.name ?? 'SakhaLive');
    
    String? displaySubtitle;
    if (isActuallyPlayingTrack) {
      displaySubtitle = trackArtist;
    } else if (trackTitle != null && trackTitle != currentStation?.name) {
      displaySubtitle = trackTitle;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            _triggerBounce();
            if (!kIsWeb) HapticFeedback.lightImpact();
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FullPlayerScreen()));
          },
          onDoubleTap: () {
            _triggerBounce();
            if (!kIsWeb) HapticFeedback.mediumImpact();
            if (isPlaying) {
              ref.read(playerProvider.notifier).stop();
            } else if (currentStation != null) {
              ref.read(playerProvider.notifier).playStation(currentStation);
            }
          },
          onPanUpdate: (d) => setState(() => _dragOffsetX += d.delta.dx),
          onPanEnd: _handleDragEnd,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: ScaleTransition(
              scale: _bounceAnimation,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 280),
                height: 64.0,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      SakhaFuturism.glassFill(isDark, opacity: _isHovered ? 0.84 : 0.76),
                      SakhaFuturism.glassFill(isDark, opacity: _isHovered ? 0.62 : 0.54),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppEffects.radiusFull),
                  border: Border.all(color: SakhaFuturism.glassBorder(isDark, accent: theme.primaryColor)),
                  boxShadow: SakhaFuturism.shadow(isDark, accent: theme.primaryColor, lift: _isHovered ? 1.15 : 1.05),
                ),
                child: Row(
                  children: [
                    // ИЗОЛИРОВАННАЯ АНИМАЦИЯ ОБЛОЖКИ
                    RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) => Transform.scale(
                          scale: isPlaying && !isBuffering ? _pulseAnimation.value : 1.0,
                          child: _buildAlbumArt(context, isPlaying, isBuffering, albumArt, currentStation, currentTrackId, isActuallyPlayingTrack, isDark),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          isBuffering
                              ? ShimmerWidget.text(width: 120, height: 14)
                              : Text(
                                  displayTitle,
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 13.0, letterSpacing: -0.5, height: 1.0),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          SizedBox(height: AppSpacing.xs),
                          _buildSubtitle(context, isBuffering, isActuallyPlayingTrack, displaySubtitle, isDark),
                        ],
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    _buildPlayButton(context, isPlaying, isBuffering, currentStation, isActuallyPlayingTrack, currentTrackId),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle(BuildContext context, bool isBuffering, bool isTrack, String? subtitle, bool isDark) {
    final theme = Theme.of(context);
    final style = GoogleFonts.inter(
      color: isDark ? theme.primaryColor : AppColors.primaryDark,
      fontSize: 8.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      height: 1.0,
    );

    if (isBuffering) return ShimmerWidget.text(width: 80, height: 10);
    if (subtitle == null || subtitle.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 5, height: 5, color: isDark ? theme.primaryColor : AppColors.primaryDark),
          SizedBox(width: AppSpacing.xs),
          Text(AppLocalizations.of(context).live_broadcast, style: style.copyWith(letterSpacing: 1.2)),
        ],
      );
    }

    if (isTrack) {
      return Text(subtitle, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
    }

    // Оптимизированная бегущая строка
    return SizedBox(
      height: 14,
      child: Marquee(
        text: subtitle,
        style: style,
        velocity: 15,
        blankSpace: 50,
        pauseAfterRound: const Duration(seconds: 2),
        accelerationDuration: const Duration(milliseconds: 500),
        decelerationDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context, bool isPlaying, bool isBuffering, Station? station, bool isTrack, String? trackId) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () async {
        _triggerBounce();
        if (!kIsWeb) HapticFeedback.lightImpact();
        final notifier = ref.read(playerProvider.notifier);
        if (isPlaying) {
          await notifier.stop();
        } else {
          if (isTrack && trackId != null) {
            await notifier.resume();
          } else if (station != null) {
            await notifier.playStation(station);
          }
        }
      },
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [theme.primaryColor, theme.primaryColor.withValues(alpha: 0.8)]),
          boxShadow: _isHovered ? AppEffects.glowPrimary : AppEffects.shadowPrimary,
        ),
        child: isBuffering
            ? Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(theme.brightness == Brightness.dark ? Colors.white : Colors.black))))
            : Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.black, size: 22),
      ),
    );
  }

  Widget _buildAlbumArt(BuildContext context, bool isPlaying, bool isBuffering, String? albumArtUrl, Station? station, String? trackId, bool isTrack, bool isDark) {
    final hasAlbumArt = albumArtUrl != null && albumArtUrl.isNotEmpty;
    final artKey = ValueKey('art-${station?.id ?? trackId}-$albumArtUrl');

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppEffects.radiusMd),
          child: SizedBox(
            width: 44, height: 44,
            child: isBuffering
                ? _buildBufferingPlaceholder(isDark)
                : hasAlbumArt && isTrack
                    ? CachedNetworkImage(
                        key: artKey, imageUrl: albumArtUrl, fit: BoxFit.cover,
                        memCacheWidth: 100, memCacheHeight: 100,
                        placeholder: (c, u) => _buildLoadingPlaceholder(),
                        errorWidget: (c, e, s) => _buildPlaceholderArt(),
                      )
                    : _buildStationArt(station),
          ),
        ),
        if (isPlaying && !isBuffering) ...[
          Positioned.fill(child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppEffects.radiusMd), border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3), width: 2)))),
          Positioned.fill(child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppEffects.radiusMd), color: Colors.black45), child: Center(child: EqualizerAnimation(isActive: true, size: 20)))),
        ],
      ],
    );
  }

  Widget _buildStationArt(Station? station) {
    if (station != null && station.art.isNotEmpty) {
      return CachedNetworkImage(
        key: ValueKey('station-${station.id}'), imageUrl: station.art, fit: BoxFit.cover,
        memCacheWidth: 100, memCacheHeight: 100,
        placeholder: (c, u) => _buildLoadingPlaceholder(),
        errorWidget: (c, e, s) => _buildPlaceholderArt(),
      );
    }
    return _buildPlaceholderArt();
  }

  Widget _buildLoadingPlaceholder() => Container(decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppEffects.radiusMd)), child: const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.primary)))));
  Widget _buildBufferingPlaceholder(bool isDark) => Container(decoration: BoxDecoration(color: isDark ? AppColors.cardBackground : Colors.grey.shade200, borderRadius: BorderRadius.circular(AppEffects.radiusMd)), child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))))));
  Widget _buildPlaceholderArt() => Container(decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(AppEffects.radiusMd)), child: const Icon(Icons.music_note, color: Colors.white, size: 20));
}
