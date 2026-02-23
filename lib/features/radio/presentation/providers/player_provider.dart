import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:radio_v2/features/radio/domain/station.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:radio_v2/core/providers/radio_providers.dart';
import 'package:radio_v2/features/radio/data/radio_player.dart';
import '../../../../../core/utils/logger.dart';

@immutable
class PlayerState {
  final bool isPlaying;
  final Station? currentStation;
  final double volume;
  final bool showVolumeSlider;
  final bool isBuffering;

  const PlayerState({
    this.isPlaying = false,
    this.currentStation,
    this.volume = 0.65,
    this.showVolumeSlider = false,
    this.isBuffering = false,
  });

  PlayerState copyWith({
    bool? isPlaying,
    Station? currentStation,
    double? volume,
    bool? showVolumeSlider,
    bool? isBuffering,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentStation: currentStation ?? this.currentStation,
      volume: volume ?? this.volume,
      showVolumeSlider: showVolumeSlider ?? this.showVolumeSlider,
      isBuffering: isBuffering ?? this.isBuffering,
    );
  }
}

class PlayerNotifier extends AsyncNotifier<PlayerState> {
  late final RadioPlayer _radioPlayer;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _processingStateSubscription;

  Future<Uri?> _getAssetUri(String assetPath) async {
    if (kIsWeb) return null;
    try {
      // Load the asset as bytes
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName = Uri.parse(assetPath).pathSegments.last;
      final file = File('${tempDir.path}/$fileName');

      // Write bytes to temporary file
      await file.writeAsBytes(bytes);

      // Return file URI
      return file.uri;
    } catch (e) {
      Logger.error('Error loading asset $assetPath: $e', tag: 'Player');
      return null;
    }
  }

  @override
  Future<PlayerState> build() async {
    _radioPlayer = RadioPlayer();

    // Listen to player state changes
    _playerStateSubscription = _radioPlayer.playerStateStream.listen((
      playerState,
    ) {
      final currentState = state.asData?.value;
      if (currentState != null) {
        if (currentState.isPlaying != playerState.playing) {
          state = AsyncData(
            currentState.copyWith(isPlaying: playerState.playing),
          );
        }
      }
    });

    // Listen to processing state changes (buffering)
    _processingStateSubscription = _radioPlayer.processingStateStream.listen((
      processingState,
    ) {
      final currentState = state.asData?.value;
      if (currentState != null) {
        final isBuffering =
            processingState == ProcessingState.buffering ||
            processingState == ProcessingState.loading;
        if (currentState.isBuffering != isBuffering) {
          state = AsyncData(currentState.copyWith(isBuffering: isBuffering));
        }
      }
    });

    ref.onDispose(() {
      _playerStateSubscription?.cancel();
      _processingStateSubscription?.cancel();
      _radioPlayer.dispose();
    });

    final prefs = await SharedPreferences.getInstance();
    final volume = prefs.getDouble('volume') ?? 0.65;
    final showVolume = prefs.getBool('showVolume') ?? false;

    await _radioPlayer.setVolume(volume);

    // Auto-play logic
    Station? initialStation;
    bool initialPlaying = false;

    final favoriteName = prefs.getString('favorite_station_v2');
    if (favoriteName != null) {
      final stations = ref.read(stationListProvider);
      try {
        final station = stations.firstWhere(
          (s) => s.name == favoriteName,
          orElse: () => stations.first,
        );

        if (stations.contains(station)) {
          initialStation = station;

          final artUri = station.art.isNotEmpty
              ? await _getAssetUri(station.art)
              : null;

          await _radioPlayer.playStream(
            url: station.url,
            title: station.name,
            artist: station.desc,
            album: 'Sakha Radio',
            artUri: artUri?.toString(),
          );

          // Auto-play (non-blocking)
          if (!kIsWeb) {
            Future.microtask(() async {
              try {
                Logger.log(
                  "Auto-play: attempting to play ${station.name}",
                  tag: 'Player',
                );
                await _radioPlayer.play();
                Logger.log(
                  "Auto-play: successfully playing ${station.name}",
                  tag: 'Player',
                );
              } catch (e) {
                Logger.error(
                  "Auto-play failed for ${station.name}: $e",
                  tag: 'Player',
                );
                state = AsyncData(
                  PlayerState(
                    volume: volume,
                    showVolumeSlider: showVolume,
                    currentStation: station,
                    isPlaying: false,
                  ),
                );
              }
            });
          }
        }
      } catch (e) {
        Logger.error("Auto-play failed: $e", tag: 'Player');
        // Показываем ошибку только если есть контекст (для web)
        if (!kIsWeb) {
          Logger.error("Auto-play error details: ${e.toString()}", tag: 'Player');
        }
      }
    }

    final result = PlayerState(
      volume: volume,
      showVolumeSlider: showVolume,
      currentStation: initialStation,
      isPlaying: initialPlaying,
    );
    return result;
  }

  Future<void> playStation(Station station) async {
    final currentState = state.asData?.value;
    Logger.log(
      "playStation(): called for station ${station.name}",
      tag: 'Player',
    );

    if (currentState == null) {
      Logger.error(
        "playStation(): state is null (not ready yet)",
        tag: 'Player',
      );
      return;
    }

    Logger.log(
      "playStation(): current state - station: ${currentState.currentStation?.name}, isPlaying: ${currentState.isPlaying}",
      tag: 'Player',
    );

    // 1. Tapping the same station: Toggle Play/Pause
    if (currentState.currentStation?.name == station.name) {
      Logger.log(
        "playStation(): same station, toggling play/pause",
        tag: 'Player',
      );
      if (currentState.isPlaying) {
        Logger.log("playStation(): pausing current station", tag: 'Player');
        await _radioPlayer.pause();
      } else {
        try {
          Logger.log("playStation(): playing current station", tag: 'Player');
          await _radioPlayer.play();
        } catch (e) {
          Logger.error("playStation(): play failed: $e", tag: 'Player');
          Logger.error(
            "playStation(): play error details - ${e.toString()}",
            tag: 'Player',
          );
        }
      }
      return;
    }

    // 2. Changing station
    Logger.log(
      "playStation(): changing station to ${station.name}",
      tag: 'Player',
    );
    try {
      // Set buffering state
      Logger.log("playStation(): setting buffering state", tag: 'Player');
      state = AsyncData(
        currentState.copyWith(
          currentStation: station,
          isPlaying: true,
          isBuffering: true,
        ),
      );

      Logger.log("playStation(): stopping current stream", tag: 'Player');
      await _radioPlayer.stop();

      Logger.log("playStation(): preparing artwork", tag: 'Player');
      final artUri = station.art.isNotEmpty
          ? await _getAssetUri(station.art)
          : null;

      Logger.log("playStation(): artwork URI: $artUri", tag: 'Player');

      Logger.log("playStation(): setting up new stream", tag: 'Player');
      await _radioPlayer.playStream(
        url: station.url,
        title: station.name,
        artist: station.desc,
        album: 'Sakha Radio',
        artUri: artUri?.toString(),
      );

      try {
        Logger.log("playStation(): starting playback", tag: 'Player');
        await _radioPlayer.play();
        Logger.log("playStation(): playing ${station.name}", tag: 'Player');
      } catch (e) {
        Logger.error("playStation(): play failed: $e", tag: 'Player');
        Logger.error(
          "playStation(): play error details - ${e.toString()}",
          tag: 'Player',
        );
        state = AsyncData(
          currentState.copyWith(currentStation: station, isPlaying: false),
        );
      }
    } catch (e) {
      Logger.error(
        "playStation(): error setting up station: $e",
        tag: 'Player',
      );
      Logger.error(
        "playStation(): setup error details - ${e.toString()}",
        tag: 'Player',
      );
      state = AsyncData(
        (state.asData?.value ?? currentState).copyWith(isPlaying: false),
      );
    }
  }

  Future<void> stop() async {
    final currentState = state.asData?.value;
    if (currentState == null) return;

    state = await AsyncValue.guard(() async {
      await _radioPlayer.stop();
      return currentState.copyWith(isPlaying: false);
    });
  }

  Future<void> setVolume(double volume) async {
    final currentState = state.asData?.value;
    if (currentState == null) return;

    state = await AsyncValue.guard(() async {
      await _radioPlayer.setVolume(volume);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('volume', volume);
      return currentState.copyWith(volume: volume);
    });
  }

  Future<void> toggleVolumeSlider() async {
    final currentState = state.asData?.value;
    if (currentState == null) return;

    state = await AsyncValue.guard(() async {
      final newShowVolume = !currentState.showVolumeSlider;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('showVolume', newShowVolume);
      return currentState.copyWith(showVolumeSlider: newShowVolume);
    });
  }
}

final playerProvider = AsyncNotifierProvider<PlayerNotifier, PlayerState>(
  PlayerNotifier.new,
);
