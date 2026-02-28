import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design/design.dart';
import '../../core/providers.dart';
import '../radio/presentation/providers/player_provider.dart';
import '../../widgets/equalizer_card.dart';

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
              // TODO: Меню действий
            },
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
    final isPlaying = playerAsync.value?.isPlaying ?? false;

    return Column(
      children: [
        Text(
          station?.name ?? 'Неизвестно',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            color: isDark ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisSize: MainAxisSize.min,
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
    );
  }

  Widget _buildVisualizer(AsyncValue<PlayerState> playerAsync) {
    final isPlaying = playerAsync.value?.isPlaying ?? false;

    return EqualizerCard(
      isActive: isPlaying,
      width: 200,
      height: 50,
      mode: EqualizerMode.bars,
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
            // TODO: Предыдущая станция
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
            // TODO: Следующая станция
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
