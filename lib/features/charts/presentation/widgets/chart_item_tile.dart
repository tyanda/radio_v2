import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design/design.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/chart_item.dart';
import '../../../radio/presentation/providers/player_provider.dart';

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
    final isCurrentPlaying =
        playerState?.trackTitle == item.title &&
        (playerState?.isPlaying ?? false);
    final isBuffering =
        playerState?.trackTitle == item.title &&
        (playerState?.isBuffering ?? false);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (item.isVideoAd) {
            _handleAdTap(context);
          } else if (item.previewUrl != null) {
            ref.read(playerProvider.notifier).playTrack(item);
          }
        },
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardBackground : Colors.white,
            borderRadius: BorderRadius.circular(AppEffects.radius2xl),
            border: Border.all(
              color: isCurrentPlaying
                  ? theme.primaryColor.withValues(alpha: 0.5)
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05)),
              width: isCurrentPlaying ? 2 : 1,
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
              // Обложка
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
                  : MouseRegion(
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
