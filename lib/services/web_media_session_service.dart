// lib/services/web_media_session_service.dart
// Главный файл сервиса Media Session с условным импортом

export 'web_media_session_service_web.dart'
    if (dart.library.io) 'web_media_session_service_stub.dart';
