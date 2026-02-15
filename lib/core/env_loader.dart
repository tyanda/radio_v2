// lib/core/env_loader.dart
// Этот файл будет использоваться только для нативных платформ

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvLoader {
  static Future<void> loadEnv() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint('Could not load .env file: $e');
    }
  }

  static String getEnvValue(String key, String defaultValue) {
    return dotenv.env[key] ?? defaultValue;
  }
}