import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import '../../../../core/utils/logger.dart';

/// Сервис для кэширования изображений радиостанций
///
/// Использование:
/// ```dart
/// final service = StationLogoCacheService();
/// final file = await service.getLogo('https://example.com/logo.png');
/// ```
class StationLogoCacheService {
  static const _cacheDirName = 'station_logos';
  Directory? _cacheDirectory;

  /// Получить директорию кэша
  Future<Directory> _getCacheDir() async {
    if (_cacheDirectory != null) return _cacheDirectory!;

    final baseDir = await getTemporaryDirectory();
    _cacheDirectory = Directory('${baseDir.path}/$_cacheDirName');

    if (!await _cacheDirectory!.exists()) {
      await _cacheDirectory!.create(recursive: true);
    }

    return _cacheDirectory!;
  }

  /// Получить хэш URL для использования в качестве имени файла
  String _hashUrl(String url) {
    return sha256.convert(utf8.encode(url)).toString();
  }

  /// Получить путь к файлу кэша
  Future<File> _getCacheFile(String url) async {
    final cacheDir = await _getCacheDir();
    final fileName = _hashUrl(url);
    return File('${cacheDir.path}/$fileName.png');
  }

  /// Проверить, есть ли изображение в кэше
  Future<bool> isCached(String url) async {
    try {
      final cacheFile = await _getCacheFile(url);
      return await cacheFile.exists();
    } catch (e) {
      Logger.log(
        'StationLogoCache: Error checking cache: $e',
        tag: 'StationLogo',
      );
      return false;
    }
  }

  /// Получить изображение из кэша или загрузить из сети
  Future<File?> getLogo(String url) async {
    if (kIsWeb) return null; // Web не поддерживает файловую систему

    try {
      final cacheFile = await _getCacheFile(url);

      // Проверяем кэш
      if (await cacheFile.exists()) {
        Logger.log('StationLogoCache: Hit for $url', tag: 'StationLogo');
        return cacheFile;
      }

      // Загружаем из сети
      Logger.log(
        'StationLogoCache: Miss for $url, downloading...',
        tag: 'StationLogo',
      );
      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              Logger.log(
                'StationLogoCache: Download timeout',
                tag: 'StationLogo',
              );
              return http.Response('Timeout', 408);
            },
          );

      if (response.statusCode == 200) {
        await cacheFile.writeAsBytes(response.bodyBytes);
        Logger.log('StationLogoCache: Saved to cache', tag: 'StationLogo');
        return cacheFile;
      } else {
        Logger.log(
          'StationLogoCache: Download failed (${response.statusCode})',
          tag: 'StationLogo',
        );
        return null;
      }
    } catch (e) {
      Logger.log('StationLogoCache: Error: $e', tag: 'StationLogo');
      return null;
    }
  }

  /// Загрузить изображение в кэш асинхронно (без возврата файла)
  Future<void> preloadLogo(String url) async {
    if (kIsWeb) return;

    try {
      if (await isCached(url)) return;

      final cacheFile = await _getCacheFile(url);
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        await cacheFile.writeAsBytes(response.bodyBytes);
      }
    } catch (e) {
      // Игнорируем ошибки при предзагрузке
    }
  }

  /// Очистить кэш логотипов
  Future<void> clearCache() async {
    try {
      if (_cacheDirectory != null && await _cacheDirectory!.exists()) {
        await _cacheDirectory!.delete(recursive: true);
        _cacheDirectory = null;
        await _getCacheDir(); // Пересоздаём директорию
        Logger.log('StationLogoCache: Cache cleared', tag: 'StationLogo');
      }
    } catch (e) {
      Logger.log(
        'StationLogoCache: Error clearing cache: $e',
        tag: 'StationLogo',
      );
    }
  }

  /// Получить размер кэша в байтах
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await _getCacheDir();
      int totalSize = 0;

      await for (final entity in cacheDir.list()) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      return totalSize;
    } catch (e) {
      Logger.log(
        'StationLogoCache: Error getting cache size: $e',
        tag: 'StationLogo',
      );
      return 0;
    }
  }
}
