import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../core/design/design.dart';
import '../../core/providers.dart';

// Импортируем Web Push только для веба
import '../../services/web_push_notification_service.dart'
    if (dart.library.io) '../../services/web_push_notification_service_stub.dart';

/// Экран настроек приложения
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(
      themeProvider.select((s) => s.value?.isDarkTheme ?? true),
    );

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.background
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.background
            : AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Настройки',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.lg),
        children: [
          // Раздел: Тема
          _buildSectionTitle('Внешний вид', isDark),
          _buildSettingsTile(
            icon: isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
            title: 'Тема',
            subtitle: isDark ? 'Тёмная тема' : 'Светлая тема',
            isDark: isDark,
            trailing: Switch(
              value: isDark,
              onChanged: (value) {
                HapticFeedback.mediumImpact();
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
          ),

          SizedBox(height: AppSpacing.lg),

          // Раздел: Приложение
          _buildSectionTitle('Приложение', isDark),
          _buildSettingsTile(
            icon: Icons.notifications_rounded,
            title: 'Уведомления',
            subtitle: 'Настройки уведомлений',
            isDark: isDark,
            onTap: () {
              HapticFeedback.lightImpact();
              _showNotificationsDialog(context, isDark);
            },
          ),

          SizedBox(height: AppSpacing.lg),

          // Раздел: О приложении
          _buildSectionTitle('О приложении', isDark),
          _buildSettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'Версия',
            subtitle: '1.0.6',
            isDark: isDark,
            onTap: () => _showAboutDialog(context),
          ),

          SizedBox(height: AppSpacing.xxl),

          // Логотип
          Center(
            child: Column(
              children: [
                Image.asset('assets/images/load.png', width: 60, height: 60),
                SizedBox(height: AppSpacing.md),
                Text(
                  'SakhaLive Radio',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Ваше любимое радио',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: AppColors.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    bool isDark = true,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackground : Colors.white,
        borderRadius: BorderRadius.circular(AppEffects.radiusLg),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        leading: Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              )
            : null,
        trailing:
            trailing ??
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('О приложении'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SakhaLive Radio',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text('Версия: 1.0.6'),
            SizedBox(height: 8),
            Text('Ваше любимое радио всегда с вами!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context, bool isDark) {
    final settings = ref.read(settingsProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardBackground : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppEffects.radiusXl),
        ),
        title: Row(
          children: [
            Icon(
              Icons.notifications_rounded,
              color: isDark ? AppColors.primary : AppColors.primaryDark,
            ),
            SizedBox(width: 8),
            Text(
              'Уведомления',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationOption(
              icon: Icons.play_circle_outline_rounded,
              title: 'Уведомления о воспроизведении',
              subtitle: 'Показывать уведомление при старте',
              enabled: settings.notificationsEnabled,
              isDark: isDark,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).toggleNotifications(value);
              },
            ),
            Divider(color: isDark ? Colors.white12 : Colors.black12),
            _buildNotificationOption(
              icon: Icons.info_outline_rounded,
              title: 'Информационные уведомления',
              subtitle: 'Новости и обновления',
              enabled: settings.newsNotificationsEnabled,
              isDark: isDark,
              onChanged: (value) {
                ref
                    .read(settingsProvider.notifier)
                    .toggleNewsNotifications(value);
              },
            ),

            // Web Push Notifications (только для веба)
            if (kIsWeb) ...[
              Divider(color: isDark ? Colors.white12 : Colors.black12),
              _buildWebPushOption(context, isDark),
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

  /// Опция Web Push Notifications для веба
  Widget _buildWebPushOption(BuildContext context, bool isDark) {
    final pushService = WebPushNotificationService();
    final isSupported = WebPushNotificationService.isSupported;

    return FutureBuilder<bool>(
      future: pushService.isSubscribed(),
      builder: (context, snapshot) {
        final isSubscribed = snapshot.data ?? false;

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            isSubscribed
                ? Icons.cloud_done_rounded
                : Icons.cloud_upload_rounded,
            color: isSubscribed
                ? AppColors.success
                : isDark
                ? AppColors.primary
                : AppColors.primaryDark,
          ),
          title: Text(
            isSubscribed ? 'Push включены' : 'Web Push',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          subtitle: Text(
            isSubscribed
                ? 'Вы подписаны на уведомления'
                : isSupported
                ? 'Подпишитесь на push-уведомления'
                : 'Не поддерживается в этом браузере',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          trailing: isSupported
              ? Switch(
                  value: isSubscribed,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    if (value) {
                      // Подписка
                      pushService.subscribe().then((success) {
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '✅ Вы подписаны на push-уведомления',
                              ),
                              backgroundColor: AppColors.success,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      });
                    } else {
                      // Отписка
                      pushService.unsubscribe().then((success) {
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '❌ Вы отписались от push-уведомлений',
                              ),
                              backgroundColor: AppColors.error,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      });
                    }
                  },
                )
              : Icon(
                  Icons.info_outline_rounded,
                  color: isDark ? Colors.white30 : Colors.black26,
                ),
        );
      },
    );
  }

  Widget _buildNotificationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppEffects.radiusMd),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          color: isDark ? Colors.white54 : Colors.black54,
        ),
      ),
      trailing: Switch(value: enabled, onChanged: onChanged),
    );
  }
}
