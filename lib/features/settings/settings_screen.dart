import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design/design.dart';
import '../../core/providers.dart';

/// Экран настроек приложения
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider.select((s) => s.isDarkTheme));

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.cardBackground : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : Colors.black),
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

          // Раздел: Аудио
          _buildSectionTitle('Аудио', isDark),
          _buildSettingsTile(
            icon: Icons.volume_up_rounded,
            title: 'Громкость',
            subtitle: 'Настройки громкости',
            isDark: isDark,
            onTap: () => _showVolumeDialog(context),
          ),
          _buildSettingsTile(
            icon: Icons.headphones_rounded,
            title: 'Фоновое воспроизведение',
            subtitle: 'Играть в фоне',
            isDark: isDark,
            trailing: Switch(
              value: true,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                // TODO: Сохранить настройку
              },
            ),
          ),

          SizedBox(height: AppSpacing.lg),

          // Раздел: Приложение
          _buildSectionTitle('Приложение', isDark),
          _buildSettingsTile(
            icon: Icons.language_rounded,
            title: 'Язык',
            subtitle: 'Русский',
            isDark: isDark,
            onTap: () => _showLanguageDialog(context),
          ),
          _buildSettingsTile(
            icon: Icons.notifications_rounded,
            title: 'Уведомления',
            subtitle: 'Настройки уведомлений',
            isDark: isDark,
            onTap: () {
              HapticFeedback.lightImpact();
              // TODO: Экран уведомлений
            },
          ),

          SizedBox(height: AppSpacing.lg),

          // Раздел: О приложении
          _buildSectionTitle('О приложении', isDark),
          _buildSettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'Версия',
            subtitle: '1.0.1',
            isDark: isDark,
            onTap: () => _showAboutDialog(context),
          ),

          SizedBox(height: AppSpacing.xxl),

          // Логотип
          Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/load.png',
                  width: 60,
                  height: 60,
                ),
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
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 22,
          ),
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
        trailing: trailing ?? Icon(
          Icons.chevron_right_rounded,
          color: isDark ? Colors.white54 : Colors.black54,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showVolumeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Громкость по умолчанию'),
        content: Slider(
          value: 0.5,
          min: 0.0,
          max: 1.0,
          divisions: 20,
          label: '50%',
          onChanged: (value) {
            // TODO: Сохранить настройку
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Язык'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Русский'),
              selected: true,
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('English'),
              selected: false,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
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
            Text('SakhaLive Radio', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text('Версия: 1.0.1'),
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
}
