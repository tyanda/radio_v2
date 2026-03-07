import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/design/design.dart';
import '../../data/models/event_item.dart';

/// Виджет карточки события (афиша)
class EventCard extends StatelessWidget {
  final EventItem event;
  final bool isDark;
  final ThemeData theme;

  const EventCard({
    super.key,
    required this.event,
    required this.isDark,
    required this.theme,
  });

  Future<void> _launchUrl() async {
    if (event.url != null) {
      final uri = Uri.parse(event.url!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _launchUrl();
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardBackground : Colors.white,
            borderRadius: BorderRadius.circular(AppEffects.radius2xl),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
            ),
            boxShadow: isDark
                ? AppEffects.shadowMd
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Изображение события
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppEffects.radius2xl),
                ),
                child: Image.network(
                  event.imageUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceVariant
                            : Colors.grey.shade200,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppEffects.radius2xl),
                        ),
                      ),
                      child: const Icon(
                        Icons.event,
                        color: Colors.white,
                        size: 40,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 180,
                      color: isDark
                          ? AppColors.surfaceVariant
                          : Colors.grey.shade200,
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Информация о событии
              Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.textName,
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    // Детали события (сетка)
                    _buildDetailRow(
                      Icons.calendar_today_rounded,
                      event.date,
                      isDark,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _buildDetailRow(
                      Icons.access_time_rounded,
                      event.time,
                      isDark,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _buildDetailRow(
                      Icons.location_on_rounded,
                      event.location,
                      isDark,
                      isFullWidth: true,
                    ),
                    SizedBox(height: AppSpacing.lg),
                    // Цена и кнопка
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          event.price,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: theme.primaryColor,
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _launchUrl();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.textPrimary
                                    : AppColors.textName,
                                borderRadius: BorderRadius.circular(
                                  AppEffects.radiusLg,
                                ),
                              ),
                              child: const Text(
                                'Билеты',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String text,
    bool isDark, {
    bool isFullWidth = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: theme.primaryColor),
        SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
            ),
            maxLines: isFullWidth ? null : 1,
            overflow: isFullWidth ? null : TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
