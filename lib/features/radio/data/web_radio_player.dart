import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import '../../../core/utils/logger.dart';

/// Класс для управления воспроизведением радио-потока на Web
/// Использует HTML5 Audio API вместо just_audio
class WebRadioPlayer {
  web.HTMLAudioElement? _audio;
  bool _isPlaying = false;
  bool _isBuffering = false;
  String? _currentUrl;
  bool _isLoaded = false;

  final _playerStateController = StreamController<bool>.broadcast();
  Stream<bool> get playerStateStream => _playerStateController.stream;

  final _bufferingController = StreamController<bool>.broadcast();
  Stream<bool> get bufferingStateStream => _bufferingController.stream;

  final _errorController = StreamController<String>.broadcast();
  Stream<String> get errorStream => _errorController.stream;

  // Completer для ожидания готовности аудио
  Completer<void>? _loadCompleter;

  WebRadioPlayer() {
    _audio = web.HTMLAudioElement();
    _setupListeners();
  }

  void _setupListeners() {
    if (_audio == null) return;

    // Обработка начала воспроизведения
    _audio!.addEventListener('play', (web.Event event) {
      Logger.log("WebRadioPlayer: onplay", tag: 'WebRadioPlayer');
      _isPlaying = true;
      _isBuffering = false;
      _playerStateController.add(_isPlaying);
      _bufferingController.add(_isBuffering);
    }.toJS);

    // Обработка паузы
    _audio!.addEventListener('pause', (web.Event event) {
      Logger.log("WebRadioPlayer: onpause", tag: 'WebRadioPlayer');
      _isPlaying = false;
      _playerStateController.add(_isPlaying);
    }.toJS);

    // Обработка ожидания данных (буферизация)
    _audio!.addEventListener('waiting', (web.Event event) {
      Logger.log("WebRadioPlayer: onwaiting - buffering", tag: 'WebRadioPlayer');
      _isBuffering = true;
      _bufferingController.add(_isBuffering);
    }.toJS);

    // Обработка воспроизведения (данные есть)
    _audio!.addEventListener('playing', (web.Event event) {
      Logger.log("WebRadioPlayer: onplaying - ready", tag: 'WebRadioPlayer');
      _isBuffering = false;
      _bufferingController.add(_isBuffering);
    }.toJS);

    // Обработка ошибок
    _audio!.addEventListener('error', (web.Event event) {
      final error = _audio?.error;
      final errorMessage = error != null 
          ? "WebRadioPlayer: Error ${error.code}: ${error.message}" 
          : "WebRadioPlayer: Unknown error";
      Logger.error(errorMessage, tag: 'WebRadioPlayer');
      _errorController.add(errorMessage);
      _isBuffering = false;
      _bufferingController.add(_isBuffering);
    }.toJS);

    // Обработка загрузки данных
    _audio!.addEventListener('canplay', (web.Event event) {
      Logger.log("WebRadioPlayer: oncanplay", tag: 'WebRadioPlayer');
      _isBuffering = false;
      _isLoaded = true;
      _bufferingController.add(_isBuffering);
      _loadCompleter?.complete();
      _loadCompleter = null;
    }.toJS);

    _audio!.addEventListener('canplaythrough', (web.Event event) {
      Logger.log("WebRadioPlayer: oncanplaythrough", tag: 'WebRadioPlayer');
      _isBuffering = false;
      _isLoaded = true;
      _bufferingController.add(_isBuffering);
      _loadCompleter?.complete();
      _loadCompleter = null;
    }.toJS);

    // Обработка завершения загрузки
    _audio!.addEventListener('loadeddata', (web.Event event) {
      Logger.log("WebRadioPlayer: onloadeddata", tag: 'WebRadioPlayer');
      _isLoaded = true;
    }.toJS);

    _audio!.addEventListener('loadedmetadata', (web.Event event) {
      Logger.log("WebRadioPlayer: onloadedmetadata", tag: 'WebRadioPlayer');
    }.toJS);
  }

  /// Загрузка потока
  Future<void> loadStream(String url) async {
    if (_audio == null) throw Exception("Audio element not initialized");

    try {
      Logger.log("WebRadioPlayer: Loading stream: $url", tag: 'WebRadioPlayer');
      _currentUrl = url;
      _isBuffering = true;
      _isLoaded = false;
      _loadCompleter = Completer<void>();
      _bufferingController.add(_isBuffering);

      _audio!.src = url;
      _audio!.load();

      // Ждем события canplay перед возвратом
      Logger.log("WebRadioPlayer: Waiting for canplay event...", tag: 'WebRadioPlayer');
      await _loadCompleter!.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          Logger.error("WebRadioPlayer: Timeout waiting for canplay", tag: 'WebRadioPlayer');
          throw TimeoutException("Stream loading timeout");
        },
      );
      Logger.log("WebRadioPlayer: Stream is ready to play", tag: 'WebRadioPlayer');
    } catch (e) {
      Logger.error("WebRadioPlayer: loadStream error: $e", tag: 'WebRadioPlayer');
      _isBuffering = false;
      _isLoaded = false;
      _bufferingController.add(_isBuffering);
      rethrow;
    }
  }

  /// Воспроизведение
  Future<void> play() async {
    if (_audio == null) throw Exception("Audio element not initialized");

    try {
      Logger.log("WebRadioPlayer: Attempting to play, isLoaded: $_isLoaded", tag: 'WebRadioPlayer');
      
      // Если ещё не загружено, пробуем загрузить
      if (!_isLoaded) {
        Logger.log("WebRadioPlayer: Not loaded yet, attempting to play anyway", tag: 'WebRadioPlayer');
      }
      
      await _audio!.play().toDart;
      _isPlaying = true;
      _playerStateController.add(_isPlaying);
      Logger.log("WebRadioPlayer: Playing", tag: 'WebRadioPlayer');
    } catch (e) {
      Logger.error("WebRadioPlayer: play error: $e", tag: 'WebRadioPlayer');
      rethrow;
    }
  }

  /// Пауза
  Future<void> pause() async {
    if (_audio == null) throw Exception("Audio element not initialized");

    try {
      Logger.log("WebRadioPlayer: Pausing", tag: 'WebRadioPlayer');
      _audio!.pause();
      _isPlaying = false;
      _playerStateController.add(_isPlaying);
    } catch (e) {
      Logger.error("WebRadioPlayer: pause error: $e", tag: 'WebRadioPlayer');
      rethrow;
    }
  }

  /// Возобновление воспроизведения (для потокового радио)
  Future<void> resume() async {
    if (_audio == null) throw Exception("Audio element not initialized");

    try {
      Logger.log("WebRadioPlayer: Resuming playback", tag: 'WebRadioPlayer');
      
      // Если уже есть источник и он загружен, просто играем
      if (_isLoaded && _currentUrl != null) {
        await _audio!.play().toDart;
        _isPlaying = true;
        _playerStateController.add(_isPlaying);
        Logger.log("WebRadioPlayer: Resumed from loaded state", tag: 'WebRadioPlayer');
        return;
      }
      
      // Иначе загружаем поток заново
      if (_currentUrl != null) {
        await loadStream(_currentUrl!);
        await _audio!.play().toDart;
        _isPlaying = true;
        _playerStateController.add(_isPlaying);
        Logger.log("WebRadioPlayer: Resumed by reloading stream", tag: 'WebRadioPlayer');
      }
    } catch (e) {
      Logger.error("WebRadioPlayer: resume error: $e", tag: 'WebRadioPlayer');
      rethrow;
    }
  }

  /// Остановка
  Future<void> stop() async {
    if (_audio == null) throw Exception("Audio element not initialized");

    try {
      Logger.log("WebRadioPlayer: Stopping", tag: 'WebRadioPlayer');
      _audio!.pause();
      _audio!.src = '';
      _audio!.load();
      _isPlaying = false;
      _isBuffering = false;
      _isLoaded = false;
      _loadCompleter?.complete();
      _loadCompleter = null;
      _playerStateController.add(_isPlaying);
      _bufferingController.add(_isBuffering);
    } catch (e) {
      Logger.error("WebRadioPlayer: stop error: $e", tag: 'WebRadioPlayer');
      rethrow;
    }
  }

  /// Установка громкости
  Future<void> setVolume(double volume) async {
    if (_audio == null) throw Exception("Audio element not initialized");
    
    final clampedVolume = volume.clamp(0.0, 1.0);
    _audio!.volume = clampedVolume;
    Logger.log("WebRadioPlayer: Volume set to $clampedVolume", tag: 'WebRadioPlayer');
  }

  /// Текущее состояние воспроизведения
  bool get isPlaying => _isPlaying;

  /// Текущее состояние буферизации
  bool get isBuffering => _isBuffering;

  /// Текущий URL
  String? get currentUrl => _currentUrl;

  /// Очистка ресурсов
  Future<void> dispose() async {
    try {
      Logger.log("WebRadioPlayer: Disposing", tag: 'WebRadioPlayer');
      await stop();
      _audio = null;
      await _playerStateController.close();
      await _bufferingController.close();
      await _errorController.close();
    } catch (e) {
      Logger.error("WebRadioPlayer: dispose error: $e", tag: 'WebRadioPlayer');
    }
  }
}
