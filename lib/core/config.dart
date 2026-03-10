// lib/core/config.dart
// Главный файл конфигурации с условным импортом

export 'config_web.dart' if (dart.library.io) 'config_native.dart';
