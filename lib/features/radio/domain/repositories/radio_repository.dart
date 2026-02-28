abstract class RadioRepository {
  Future<void> playStream({
    required String url,
    required String title,
    required String artist,
    required String artwork,
  });

  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> setVolume(double volume);
  Future<void> setSpeed(double speed);
  Future<void> dispose();
}
