import 'dart:async';
import 'radio_player_interface.dart';

/// Заглушка для мобильных платформ (Android/iOS)
/// На этих платформах используется just_audio через radio_player.dart
class StubRadioPlayer implements RadioPlayerInterface {
  final _playerStateController = StreamController<bool>.broadcast();
  @override
  Stream<bool> get playerStateStream => _playerStateController.stream;

  final _bufferingController = StreamController<bool>.broadcast();
  @override
  Stream<bool> get bufferingStateStream => _bufferingController.stream;

  final _errorController = StreamController<String>.broadcast();
  @override
  Stream<String> get errorStream => _errorController.stream;

  @override
  bool get isPlaying => false;

  @override
  bool get isBuffering => false;

  @override
  String? get currentUrl => null;

  @override
  Future<void> loadStream(String url) async {
    throw UnimplementedError('WebRadioPlayer не поддерживается на мобильных платформах');
  }

  @override
  Future<void> play() async {
    throw UnimplementedError('WebRadioPlayer не поддерживается на мобильных платформах');
  }

  @override
  Future<void> pause() async {
    throw UnimplementedError('WebRadioPlayer не поддерживается на мобильных платформах');
  }

  @override
  Future<void> resume() async {
    throw UnimplementedError('WebRadioPlayer не поддерживается на мобильных платформах');
  }

  @override
  Future<void> stop() async {
    throw UnimplementedError('WebRadioPlayer не поддерживается на мобильных платформах');
  }

  @override
  Future<void> setVolume(double volume) async {
    throw UnimplementedError('WebRadioPlayer не поддерживается на мобильных платформах');
  }

  @override
  Future<void> dispose() async {
    await _playerStateController.close();
    await _bufferingController.close();
    await _errorController.close();
  }
}

/// Фабричная функция для мобильных платформ (возвращает заглушку)
RadioPlayerInterface createRadioPlayerImpl() => StubRadioPlayer();
