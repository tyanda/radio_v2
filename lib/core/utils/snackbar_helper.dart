import 'package:flutter/material.dart';
import 'package:radio_v2/core/design/app_colors.dart';
import 'package:radio_v2/l10n/app_localizations.dart';

/// Утилиты для показа Snackbar
class SnackbarHelper {
  /// Показать Snackbar с ошибкой
  static void showError({
    required BuildContext context,
    String? message,
    Duration duration = const Duration(seconds: 4),
  }) {
    final localizations = AppLocalizations.of(context);
    _showSnackbar(
      context: context,
      message: message ?? localizations.error_playback(''),
      duration: duration,
      backgroundColor: AppColors.error,
      icon: Icons.error_outline_rounded,
    );
  }

  /// Показать Snackbar с успехом
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackbar(
      context: context,
      message: message,
      duration: duration,
      backgroundColor: const Color(0xFF34C759),
      icon: Icons.check_circle_outline_rounded,
    );
  }

  /// Показать Snackbar с информацией
  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackbar(
      context: context,
      message: message,
      duration: duration,
      backgroundColor: AppColors.accent,
      icon: Icons.info_outline_rounded,
      textColor: Colors.black,
    );
  }

  /// Базовый метод показа Snackbar
  static void _showSnackbar({
    required BuildContext context,
    required String message,
    required Duration duration,
    required Color backgroundColor,
    required IconData icon,
    Color textColor = Colors.white,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
