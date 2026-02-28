import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design/design.dart';
import '../../core/providers.dart';
import '../../core/providers/radio_providers.dart';
import '../radio/presentation/providers/player_provider.dart';
import '../radio/domain/station.dart';

/// Full Player экран — полный экран плеера
class FullPlayerScreen extends ConsumerStatefulWidget {
  const FullPlayerScreen({super.key});

  @override
  ConsumerState<FullPlayerScreen> createState() => _FullPlayerScreenState();
}

class _FullPlayerScreenState extends ConsumerState<FullPlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: AppEffects.durationSlow,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );
    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerAsync = ref.watch(playerProvider);
    final isDark = ref.watch(themeProvider.select((s) => s.isDarkTheme));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.background,
                  ]
                : [
                    AppColors.primary.withValues(alpha: 0.1),
                    Colors.white,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              _buildAppBar(isDark),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      // Обложка
                      _buildAlbumArt(playerAsync, isDark),
                      SizedBox(height: AppSpacing.xxl),
                      // Информация о станции
                      _buildStationInfo(playerAsync, isDark),
                      SizedBox(height: AppSpacing.xl),
                      // Визуализатор
                      _buildVisualizer(playerAsync),
                      SizedBox(height: AppSpacing.xl),
                      // Контролы
                      _buildControls(playerAsync, isDark),
                      SizedBox(height: AppSpacing.xl),
                      // Громкость
                      _buildVolumeControl(isDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.keyboard_arrow_down_rounded, size: 32),
            color: isDark ? Colors.white : Colors.black,
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Сейчас играет',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_horiz_rounded),
            color: isDark ? Colors.white : Colors.black,
            onPressed: () {
              _showActionMenu(isDark);
            },
          ),
        ],
      ),
    );
  }

  void _showActionMenu(bool isDark) {
    final playerState = ref.read(playerProvider).value;
    final station = playerState?.currentStation;

    if (station == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardBackground : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppEffects.radiusXl)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.lg),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(AppEffects.radiusFull),
              ),
            ),
            // Actions
            _buildActionItem(
              icon: Icons.favorite_outline_rounded,
              title: 'Добавить в избранное',
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                ref.read(favoritesProvider.notifier).toggleFavorite(station.name);
                HapticFeedback.lightImpact();
              },
            ),
            _buildActionItem(
              icon: Icons.share_rounded,
              title: 'Поделиться',
              isDark: isDark,
              onTap: () async {
                final currentStation = station;
                Navigator.pop(context);
                HapticFeedback.lightImpact();

                // Простая реализация share через clipboard
                await Clipboard.setData(
                  ClipboardData(text: 'Слушаю ${currentStation.name} на SakhaLive Radio!'),
                );

                // Показываем уведомление после закрытия modal
                await Future.delayed(const Duration(milliseconds: 300));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Скопировано: "${currentStation.name}"'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppEffects.radiusLg),
                      ),
                    ),
                  );
                }
              },
            ),
            _buildActionItem(
              icon: Icons.info_outline_rounded,
              title: 'О станции',
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                _showStationInfo(station, isDark);
                HapticFeedback.lightImpact();
              },
            ),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? Colors.white70 : Colors.black87,
        size: 24,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          fontSize: 15,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showStationInfo(Station station, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardBackground : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppEffects.radiusXl),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (station.art.isNotEmpty)
              Image.asset(
                station.art,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.radio, size: 60, color: AppColors.primary),
              ),
            SizedBox(height: AppSpacing.lg),
            Text(
              station.name,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: isDark ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            if (station.desc.isNotEmpty) ...[
              SizedBox(height: AppSpacing.sm),
              Text(
                station.desc,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(AsyncValue<PlayerState> playerAsync, bool isDark) {
    final station = playerAsync.value?.currentStation;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppEffects.radiusXl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppEffects.radiusXl),
          child: station?.art.isNotEmpty ?? false
              ? Image.asset(
                  station!.art,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholder(isDark);
                  },
                )
              : _buildPlaceholder(isDark),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark ? AppColors.cardBackground : Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          size: 80,
          color: isDark ? Colors.white54 : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildStationInfo(AsyncValue<PlayerState> playerAsync, bool isDark) {
    final station = playerAsync.value?.currentStation;
    final trackTitle = playerAsync.value?.trackTitle;
    final trackArtist = playerAsync.value?.trackArtist;
    final isPlaying = playerAsync.value?.isPlaying ?? false;

    return Column(
      children: [
        // Название станции
        Text(
          station?.name ?? 'Неизвестно',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            color: isDark ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.md),
        // Информация о треке или статус
        if (trackTitle != null && trackTitle.isNotEmpty) ...[
          // Название трека
          Text(
            trackTitle,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (trackArtist != null && trackArtist.isNotEmpty) ...[
            SizedBox(height: AppSpacing.xs),
            Text(
              trackArtist,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ] else ...[
          // Статус вещания
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isPlaying)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
              if (isPlaying) SizedBox(width: AppSpacing.xs),
              if (isPlaying)
                Text(
                  'Прямой эфир',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.success,
                  ),
                ),
              if (!isPlaying)
                Text(
                  station?.desc ?? '',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildVisualizer(AsyncValue<PlayerState> playerAsync) {
    final station = playerAsync.value?.currentStation;
    final isPlaying = playerAsync.value?.isPlaying ?? false;

    return _buildStationMetadata(station, isPlaying);
  }

  Widget _buildStationMetadata(Station? station, bool isPlaying) {
    if (station == null) {
      // Плейсхолдер с логотипом приложения
      return Container(
        padding: EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppEffects.radiusXl),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Логотип приложения
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF2C94C), Color(0xFFF59E0B)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF2C94C).withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF0F0F0F),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/load.png',
                    width: 74,
                    height: 74,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'SakhaLive',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: AppColors.primary,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Ваше любимое радио',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      );
    }

    // Метаданные станции
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppEffects.radiusXl),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: isPlaying
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Логотип станции
          ClipRRect(
            borderRadius: BorderRadius.circular(AppEffects.radiusMd),
            child: SizedBox(
              width: 60,
              height: 60,
              child: station.art.isNotEmpty
                  ? Image.asset(
                      station.art,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildStationPlaceholder();
                      },
                    )
                  : _buildStationPlaceholder(),
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          // Информация
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xs),
                if (station.desc.isNotEmpty)
                  Text(
                    station.desc,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (station.frequency.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppEffects.radiusFull),
                    ),
                    child: Text(
                      station.frequency,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Индикатор воспроизведения
          if (isPlaying)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStationPlaceholder() {
    return Container(
      color: AppColors.cardBackground,
      child: Center(
        child: Icon(
          Icons.radio_rounded,
          color: Colors.white54,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildControls(AsyncValue<PlayerState> playerAsync, bool isDark) {
    final isPlaying = playerAsync.value?.isPlaying ?? false;
    final isBuffering = playerAsync.value?.isBuffering ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Предыдущая
        _buildControlButton(
          icon: Icons.skip_previous_rounded,
          size: 48,
          isDark: isDark,
          onTap: () {
            HapticFeedback.mediumImpact();
            ref.read(playerProvider.notifier).playPreviousStation();
          },
        ),
        SizedBox(width: AppSpacing.lg),
        // Play/Pause
        _buildPlayPauseButton(isPlaying, isBuffering, isDark),
        SizedBox(width: AppSpacing.lg),
        // Следующая
        _buildControlButton(
          icon: Icons.skip_next_rounded,
          size: 48,
          isDark: isDark,
          onTap: () {
            HapticFeedback.mediumImpact();
            ref.read(playerProvider.notifier).playNextStation();
          },
        ),
      ],
    );
  }

  Widget _buildPlayPauseButton(bool isPlaying, bool isBuffering, bool isDark) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          if (isPlaying) {
            ref.read(playerProvider.notifier).stop();
          } else {
            final station = ref.read(playerProvider).value?.currentStation;
            if (station != null) {
              ref.read(playerProvider.notifier).playStation(station);
            }
          }
        },
        child: AnimatedContainer(
          duration: AppEffects.durationFast,
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: isBuffering
              ? Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  ),
                )
              : Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.black,
                  size: 40,
                ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required double size,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? AppColors.cardBackground
                : Colors.white,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
            ),
          ),
          child: Icon(
            icon,
            color: isDark ? Colors.white : Colors.black,
            size: size * 0.6,
          ),
        ),
      ),
    );
  }

  Widget _buildVolumeControl(bool isDark) {
    final volume = ref.watch(playerProvider.select(
      (state) => state.value?.volume ?? 0.5,
    ));

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardBackground.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppEffects.radiusFull),
      ),
      child: Row(
        children: [
          Icon(
            Icons.volume_mute_rounded,
            color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
            size: 20,
          ),
          Expanded(
            child: Slider(
              value: volume,
              min: 0.0,
              max: 1.0,
              divisions: 20,
              activeColor: AppColors.primary,
              inactiveColor: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.2),
              thumbColor: AppColors.primary,
              onChanged: (value) {
                ref.read(playerProvider.notifier).setVolume(value);
              },
            ),
          ),
          Icon(
            Icons.volume_up_rounded,
            color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
            size: 20,
          ),
        ],
      ),
    );
  }
}
