// lib/core/env_loader.dart
// Этот файл будет использоваться только для нативных платформ

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'utils/logger.dart';

class EnvLoader {
  static Future<void> loadEnv() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      Logger.warn('Could not load .env file: $e', tag: 'EnvLoader');
    }
  }

  static String getEnvValue(String key, String defaultValue) {
    return dotenv.env[key] ?? defaultValue;
  }
}
