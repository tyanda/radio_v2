import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'radio_player_interface.dart';

/// Реализация для Web с использованием HTML5 Audio API
/// 
/// Поддерживает:
/// - Воспроизведение потоков и треков
/// - Событие ended для автоматического переключения треков
class WebRadioPlayer implements RadioPlayerInterface {
  web.HTMLAudioElement? _audio;
  bool _isPlaying = false;
  bool _isBuffering = false;
  String? _currentUrl;
  bool _isLoaded = false;

  final _playerStateController = StreamController<bool>.broadcast();
  @override
  Stream<bool> get playerStateStream => _playerStateController.stream;

  final _bufferingController = StreamController<bool>.broadcast();
  @override
  Stream<bool> get bufferingStateStream => _bufferingController.stream;

  final _errorController = StreamController<String>.broadcast();
  @override
  Stream<String> get errorStream => _errorController.stream;

  // Событие завершения трека (для плейлистов)
  final _endedController = StreamController<void>.broadcast();
  @override
  Stream<void> get endedStream => _endedController.stream;

  Completer<void>? _loadCompleter;

  WebRadioPlayer() {
    _audio = web.HTMLAudioElement();
    _setupListeners();
  }

  void _setupListeners() {
    if (_audio == null) return;

    _audio!.addEventListener(
      'play',
      (web.Event event) {
        _isPlaying = true;
        _isBuffering = false;
        _playerStateController.add(_isPlaying);
        _bufferingController.add(_isBuffering);
      }.toJS,
    );

    _audio!.addEventListener(
      'pause',
      (web.Event event) {
        _isPlaying = false;
        _playerStateController.add(_isPlaying);
      }.toJS,
    );

    _audio!.addEventListener(
      'waiting',
      (web.Event event) {
        _isBuffering = true;
        _bufferingController.add(_isBuffering);
      }.toJS,
    );

    _audio!.addEventListener(
      'playing',
      (web.Event event) {
        _isBuffering = false;
        _bufferingController.add(_isBuffering);
      }.toJS,
    );

    _audio!.addEventListener(
      'error',
      (web.Event event) {
        final error = _audio?.error;
        final errorMessage = error != null
            ? "Error ${error.code}: ${error.message}"
            : "Unknown error";
        _errorController.add(errorMessage);
        _isBuffering = false;
        _bufferingController.add(_isBuffering);

        if (_loadCompleter != null && !_loadCompleter!.isCompleted) {
          _loadCompleter!.completeError(errorMessage);
          _loadCompleter = null;
        }
      }.toJS,
    );

    _audio!.addEventListener(
      'canplay',
      (web.Event event) {
        _isBuffering = false;
        _isLoaded = true;
        _bufferingController.add(_isBuffering);
        if (_loadCompleter != null && !_loadCompleter!.isCompleted) {
          _loadCompleter!.complete();
          _loadCompleter = null;
        }
      }.toJS,
    );

    _audio!.addEventListener(
      'canplaythrough',
      (web.Event event) {
        _isBuffering = false;
        _isLoaded = true;
        _bufferingController.add(_isBuffering);
        if (_loadCompleter != null && !_loadCompleter!.isCompleted) {
          _loadCompleter!.complete();
          _loadCompleter = null;
        }
      }.toJS,
    );

    _audio!.addEventListener(
      'loadeddata',
      (web.Event event) {
        _isLoaded = true;
      }.toJS,
    );

    // Обработчик завершения трека (для плейлистов)
    _audio!.addEventListener(
      'ended',
      (web.Event event) {
        _endedController.add(null);
      }.toJS,
    );
  }

  @override
  Future<void> loadStream(String url) async {
    if (_audio == null) throw Exception("Audio element not initialized");

    try {
      // Cancel previous load if any
      if (_loadCompleter != null && !_loadCompleter!.isCompleted) {
        _loadCompleter!.complete();
        _loadCompleter = null;
      }

      _currentUrl = url;
      _isBuffering = true;
      _isLoaded = false;
      _loadCompleter = Completer<void>();
      _bufferingController.add(_isBuffering);

      _audio!.src = url;
      _audio!.load();

      // Wait for canplay with timeout
      try {
        await _loadCompleter!.future.timeout(const Duration(seconds: 3));
      } on TimeoutException {
        // Continue anyway - browser will load on play()
      } catch (e) {
        _isBuffering = false;
        _bufferingController.add(_isBuffering);
        rethrow;
      } finally {
        _isBuffering = false;
        _bufferingController.add(_isBuffering);
      }
    } catch (e) {
      _isBuffering = false;
      _isLoaded = false;
      _bufferingController.add(_isBuffering);
      rethrow;
    }
  }

  @override
  Future<void> play() async {
    if (_audio == null) throw Exception("Audio element not initialized");

    try {
      await _audio!.play().toDart;
      _isPlaying = true;
      _playerStateController.add(_isPlaying);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    if (_audio == null) throw Exception("Audio element not initialized");

    try {
      _audio!.pause();
      _isPlaying = false;
      _playerStateController.add(_isPlaying);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resume() async {
    if (_audio == null) throw Exception("Audio element not initialized");

    try {
      if (_isLoaded && _currentUrl != null) {
        await _audio!.play().toDart;
        _isPlaying = true;
        _playerStateController.add(_isPlaying);
        return;
      }

      if (_currentUrl != null) {
        await loadStream(_currentUrl!);
        await _audio!.play().toDart;
        _isPlaying = true;
        _playerStateController.add(_isPlaying);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    if (_audio == null) throw Exception("Audio element not initialized");

    try {
      _audio!.pause();
      await Future.delayed(const Duration(milliseconds: 50));

      _audio!.src = '';
      _audio!.load();

      _isPlaying = false;
      _isBuffering = false;
      _isLoaded = false;

      if (_loadCompleter != null && !_loadCompleter!.isCompleted) {
        _loadCompleter!.complete();
      }
      _loadCompleter = null;

      _playerStateController.add(_isPlaying);
      _bufferingController.add(_isBuffering);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    if (_audio == null) throw Exception("Audio element not initialized");

    _audio!.volume = volume.clamp(0.0, 1.0);
  }

  @override
  bool get isPlaying => _isPlaying;

  @override
  bool get isBuffering => _isBuffering;

  @override
  String? get currentUrl => _currentUrl;

  @override
  Future<void> dispose() async {
    try {
      await stop();
      _audio = null;
      await _playerStateController.close();
      await _bufferingController.close();
      await _errorController.close();
    } catch (e) {
      rethrow;
    }
  }
}

/// Фабричная функция для Web
RadioPlayerInterface createRadioPlayerImpl() => WebRadioPlayer();
