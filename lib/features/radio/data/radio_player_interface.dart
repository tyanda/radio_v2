import 'dart:async';

/// Интерфейс для управления воспроизведением радио
abstract class RadioPlayerInterface {
  Stream<bool> get playerStateStream;
  Stream<bool> get bufferingStateStream;
  Stream<String> get errorStream;

  Future<void> loadStream(String url);
  Future<void> play();
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> setVolume(double volume);

  bool get isPlaying;
  bool get isBuffering;
  String? get currentUrl;

  Future<void> dispose();
}
