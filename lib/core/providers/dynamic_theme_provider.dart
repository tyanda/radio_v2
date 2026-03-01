import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radio_v2/features/radio/presentation/providers/player_provider.dart';
import 'package:radio_v2/core/design/design_tokens.dart';

/// Провайдер текущего динамического акцентного цвета
final dynamicColorProvider = StateProvider<Color>((ref) => AppColors.primary);

/// Менеджер динамической темы, который слушает состояние плеера
final dynamicThemeManagerProvider = Provider<void>((ref) {
  // Используем listen вместо watch в теле для побочных эффектов
  ref.listen(playerProvider, (previous, next) {
    final playerState = next.value;
    if (playerState == null) return;

    final currentStation = playerState.currentStation;
    final albumArt = playerState.albumArt;
    final imagePath = albumArt ?? currentStation?.art;

    if (imagePath != null && imagePath.isNotEmpty) {
      _updateColorFromImage(ref, imagePath);
    }
  });
});

// Храним последний обработанный путь, чтобы не делать лишних запросов
String? _lastProcessedPath;

Future<void> _updateColorFromImage(Ref ref, String imagePath) async {
  if (_lastProcessedPath == imagePath) return;
  _lastProcessedPath = imagePath;

  try {
    ImageProvider imageProvider;
    if (imagePath.startsWith('http')) {
      imageProvider = NetworkImage(imagePath);
    } else {
      imageProvider = AssetImage(imagePath);
    }

    final palette = await PaletteGenerator.fromImageProvider(
      imageProvider,
      maximumColorCount: 20,
    ).timeout(const Duration(seconds: 5));

    final color =
        palette.vibrantColor?.color ??
        palette.dominantColor?.color ??
        AppColors.primary;

    // Делаем цвет более подходящим для акцента (яркость)
    final hsl = HSLColor.fromColor(color);
    final accentColor = hsl
        .withLightness((hsl.lightness).clamp(0.4, 0.7))
        .toColor();

    // Безопасно обновляем состояние
    if (ref.read(dynamicColorProvider) != accentColor) {
      ref.read(dynamicColorProvider.notifier).state = accentColor;
    }
  } catch (e) {
    // В случае ошибки возвращаем стандартный цвет
    if (ref.read(dynamicColorProvider) != AppColors.primary) {
      ref.read(dynamicColorProvider.notifier).state = AppColors.primary;
    }
  }
}
