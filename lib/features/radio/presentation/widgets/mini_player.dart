import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:radio_v2/features/radio/domain/station.dart';
import 'package:radio_v2/features/radio/presentation/providers/player_provider.dart';
import 'package:radio_v2/widgets/equalizer_animation.dart';
import 'package:radio_v2/widgets/shimmer_widget.dart';
import 'package:radio_v2/core/utils/snackbar_helper.dart';
import '../../../../l10n/app_localizations.dart';

class MiniPlayer extends ConsumerStatefulWidget {
  const MiniPlayer({super.key});

  @override
  ConsumerState<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends ConsumerState<MiniPlayer> {
  @override
  Widget build(BuildContext context) {
    final playerAsync = ref.watch(playerProvider);

    return playerAsync.when(
      data: (playerState) {
        final isVisible =
            playerState.currentStation != null &&
            (playerState.isPlaying || playerState.isBuffering);

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
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
        // Слайдер громкости
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 280),
          crossFadeState: playerState.showVolumeSlider
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.volume_mute_rounded,
                    color: theme.colorScheme.onSurface,
                    size: 18,
                  ),
                  Expanded(
                    child: Slider(
                      value: playerState.volume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 20,
                      activeColor: theme.primaryColor,
                      inactiveColor: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      thumbColor: theme.primaryColor,
                      onChanged: (v) =>
                          ref.read(playerProvider.notifier).setVolume(v),
                    ),
                  ),
                  Icon(
                    Icons.volume_up_rounded,
                    color: theme.colorScheme.onSurface,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Основной контейнер мини-плеера
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(32.0),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.05),
                blurRadius: isDark ? 40 : 10,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          constraints: const BoxConstraints(maxWidth: 280),
          height: 64.0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Логотип
              GestureDetector(
                onTap: () =>
                    ref.read(playerProvider.notifier).toggleVolumeSlider(),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: isBuffering
                            ? Container(
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12.0),
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
                            : Image.asset(
                                currentStation.art,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade800,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: const Icon(
                                      Icons.music_note,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                    if (playerState.isPlaying && !isBuffering)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color: Colors.black.withValues(alpha: 0.40),
                          ),
                          child: const Center(
                            child: EqualizerAnimation(isActive: true, size: 20),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Информация о станции
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                    const SizedBox(height: 3),
                    isBuffering
                        ? ShimmerWidget.text(
                            width: 80,
                            height: 10,
                            textStyle: GoogleFonts.inter(
                              color: theme.primaryColor,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                AppLocalizations.of(context).live_broadcast,
                                style: GoogleFonts.inter(
                                  color: theme.primaryColor,
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
              const SizedBox(width: 10),
              // Кнопка Play/Pause
              GestureDetector(
                onTap: () async {
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
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isBuffering
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        )
                      : Icon(
                          playerState.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.black, // Контраст на желтом
                          size: 22,
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
