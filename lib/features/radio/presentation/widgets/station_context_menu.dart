import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/design/design.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/station.dart';

/// Контекстное меню для радиостанции
///
/// Появляется по long press на карточке
class StationContextMenu {
  static Future<void> show({
    required BuildContext context,
    required Station station,
    required bool isFavorite,
    required VoidCallback onToggleFavorite,
    VoidCallback? onShare,
  }) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;

    await showMenu<dynamic>(
      context: context,
      position: RelativeRect.fill,
      items: <PopupMenuEntry<dynamic>>[
        // Избранное
        PopupMenuItem<dynamic>(
          height: 56,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isFavorite
                      ? Colors.red.withValues(alpha: 0.1)
                      : accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_outline_rounded,
                  color: isFavorite ? Colors.red : accentColor,
                  size: 20,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFavorite ? 'В избранном' : 'В избранное',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      isFavorite
                          ? 'Удалить из избранных'
                          : 'Добавить в избранное',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.black.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          onTap: () {
            HapticFeedback.lightImpact();
            onToggleFavorite();
          },
        ),

        // Поделиться
        PopupMenuItem<dynamic>(
          height: 56,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.share_rounded,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Поделиться',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      'Отправить ссылку на станцию',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.black.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          onTap: () async {
            HapticFeedback.lightImpact();
            await _shareStation(station);
          },
        ),

        // Копировать ссылку
        PopupMenuItem<dynamic>(
          height: 56,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.link_rounded,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Копировать ссылку',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      'Скопировать URL потока',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.black.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          onTap: () {
            HapticFeedback.lightImpact();
            _copyStreamUrl(station);
          },
        ),

        // Разделитель
        const PopupMenuDivider(height: 1),

        // Информация о станции
        PopupMenuItem<dynamic>(
          height: 56,
          enabled: false,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: isDark ? Colors.white : Colors.black,
                  size: 20,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.name,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      station.frequency.isNotEmpty
                          ? station.frequency
                          : 'Online',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.black.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
      color: isDark ? AppColors.cardBackground : Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppEffects.radiusLg),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  static Future<void> _shareStation(Station station) async {
    try {
      final shareText =
          '🎵 Слушаю ${station.name} (${station.frequency}) в приложении SakhaLive!';

      await Share.share(
        shareText,
        subject: '${station.name} - SakhaLive',
      );

      Logger.log('Станция partag: ${station.name}', tag: 'Share');
    } catch (e) {
      Logger.error('Ошибка шеринга: $e', tag: 'Share');
    }
  }

  static void _copyStreamUrl(Station station) {
    try {
      Clipboard.setData(ClipboardData(text: station.url));
      Logger.log('URL скопирован: ${station.name}', tag: 'Clipboard');
    } catch (e) {
      Logger.error('Ошибка копирования: $e', tag: 'Clipboard');
    }
  }
}
