import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design/design.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/chart_item.dart';
import '../../../radio/presentation/providers/player_provider.dart';
import '../providers/charts_provider.dart';

/// Виджет элемента песни в чарте
/// Дизайн из React-версии SakhaLive
class ChartItemTile extends ConsumerWidget {
  final ChartItem item;
  final ThemeData theme;
  final bool isDark;

  const ChartItemTile({
    super.key,
    required this.item,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider).value;

    // Определяем, играет ли текущий трек по ID
    // Для веб-версии: проверяем также trackTitle если currentTrackId не установлен
    final isCurrentPlaying =
        playerState != null &&
        playerState.currentStation == null && // Не радио
        ((playerState.currentTrackId == item.id) ||
            (kIsWeb &&
                playerState.trackTitle == item.title &&
                playerState.trackArtist == item.artist)) &&
        playerState.isPlaying;

    final isBuffering =
        playerState != null &&
        playerState.currentStation == null && // Не радио
        playerState.currentTrackId == item.id &&
        playerState.isBuffering;

    // Отладочная информация (удалить после тестирования)
    if (kIsWeb) {
      Logger.debug(
        'ChartTile: ${item.title} | currentTrackId: ${playerState?.currentTrackId} | isCurrentPlaying: $isCurrentPlaying',
        tag: 'Charts',
      );
    }

    // Используем Inkwell вместо MouseRegion для лучшей поддержки touch
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        HapticFeedback.lightImpact();
        if (item.isVideoAd) {
          _handleAdTap(context);
        } else if (item.previewUrl != null) {
          // Получаем список всех треков из виджета списка
          final chartsState = ref.read(chartsProvider);
          final chartsAsync = chartsState.value;

          if (chartsAsync != null) {
            // Фильтруем только треки (не рекламу)
            final tracks = chartsAsync.where((i) => i.isSong).toList();
            final trackIndex = tracks.indexWhere((t) => t.id == item.id);

            if (trackIndex >= 0) {
              // Воспроизводим плейлист с очередью
              ref
                  .read(playerProvider.notifier)
                  .playPlaylist(tracks, trackIndex);
            } else {
              // Fallback: играем только трек
              ref.read(playerProvider.notifier).playTrack(item);
            }
          } else {
            ref.read(playerProvider.notifier).playTrack(item);
          }
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                SakhaFuturism.glassFill(
                  isDark,
                  opacity: isCurrentPlaying ? 0.82 : 0.74,
                ),
                SakhaFuturism.glassFill(
                  isDark,
                  opacity: isCurrentPlaying ? 0.64 : 0.54,
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isCurrentPlaying
                  ? theme.primaryColor.withValues(alpha: 0.5)
                  : SakhaFuturism.glassBorder(
                      isDark,
                      accent: theme.primaryColor,
                    ),
              width: isCurrentPlaying ? 1.4 : 1,
            ),
            boxShadow: SakhaFuturism.shadow(
              isDark,
              accent: theme.primaryColor,
              lift: isCurrentPlaying ? 1.12 : 1,
            ),
          ),
          child: Row(
            children: [
              // Ранг или иконка рекламы
              SizedBox(
                width: 30,
                child: Center(
                  child: item.isVideoAd
                      ? Icon(
                          Icons.play_circle_fill_rounded,
                          color: theme.primaryColor,
                          size: 24,
                        )
                      : Text(
                          '${item.rank}',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: (item.rank ?? 0) <= 3
                                ? theme.primaryColor
                                : (isDark
                                      ? AppColors.textSecondary
                                      : AppColors.textSecondaryLight),
                          ),
                        ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              // Обложка с индикатором воспроизведения
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppEffects.radiusMd),
                    child: item.coverUrl != null && item.coverUrl!.isNotEmpty
                        ? Image.network(
                            item.coverUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholderCover(),
                          )
                        : _buildPlaceholderCover(),
                  ),
                  // Индикатор "ИГРАЕТ" на обложке
                  if (isCurrentPlaying)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              theme.primaryColor.withValues(alpha: 0.9),
                            ],
                          ),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              width: 2,
                              height: 8 - (index * 2),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: AppSpacing.md),
              // Информация о треке или Рекламный текст
              Expanded(
                child: item.isVideoAd
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              children: [
                                const TextSpan(text: "Sakha"),
                                TextSpan(
                                  text: "Live",
                                  style: TextStyle(color: theme.primaryColor),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.title.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: theme.primaryColor.withValues(alpha: 0.9),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Индикатор "СЕЙЧАС ИГРАЕТ" для активного трека
                          if (isCurrentPlaying) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              margin: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 8,
                                    height: 8,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'ИГРАЕТ',
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          Text(
                            item.title,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textPrimary
                                  : AppColors.textName,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.artist ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.textSecondary
                                  : AppColors.textSecondaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
              ),
              // Кнопка Play/Pause или Кнопка действия для рекламы
              item.isVideoAd
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(
                          AppEffects.radiusFull,
                        ),
                      ),
                      child: Text(
                        item.actionText ?? 'СМОТРЕТЬ',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        // Пауза/воспроизведение при нажатии на кнопку
                        final playerState = ref.read(playerProvider).value;
                        if (playerState != null && playerState.isPlaying) {
                          await ref.read(playerProvider.notifier).stop();
                        } else {
                          await ref.read(playerProvider.notifier).resume();
                        }
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isCurrentPlaying
                                ? theme.primaryColor
                                : theme.primaryColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: isBuffering
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isCurrentPlaying
                                          ? Colors.black
                                          : theme.primaryColor,
                                    ),
                                  ),
                                )
                              : Icon(
                                  isCurrentPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 18,
                                  color: isCurrentPlaying
                                      ? Colors.black
                                      : theme.primaryColor,
                                ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderCover() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariant : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppEffects.radiusMd),
      ),
      child: item.isVideoAd
          ? Image.asset(
              'assets/images/load.png',
              width: 30,
              height: 30,
              fit: BoxFit.contain,
            )
          : const Icon(Icons.music_note, color: Colors.white, size: 20),
    );
  }

  void _handleAdTap(BuildContext context) {
    final url = item.previewUrl ?? item.videoUrl;
    if (url != null && url.isNotEmpty) {
      Logger.log('🔗 Открытие ссылки рекламы: $url', tag: 'Ad');
    }
  }
}
