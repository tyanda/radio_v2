import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:radio_v2/features/radio/domain/station.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:radio_v2/features/radio/presentation/providers/radio_providers.dart';

@immutable
class PlayerState {
  final bool isPlaying;
  final Station? currentStation;
  final double volume;
  final bool showVolumeSlider;

  const PlayerState({
    this.isPlaying = false,
    this.currentStation,
    this.volume = 0.65,
    this.showVolumeSlider = false,
  });

  PlayerState copyWith({
    bool? isPlaying,
    Station? currentStation,
    double? volume,
    bool? showVolumeSlider,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentStation: currentStation ?? this.currentStation,
      volume: volume ?? this.volume,
      showVolumeSlider: showVolumeSlider ?? this.showVolumeSlider,
    );
  }
}

class PlayerNotifier extends AsyncNotifier<PlayerState> {
  late final AudioPlayer _player;
  StreamSubscription? _playerStateSubscription;

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

      // Write bytes to temporary file if it doesn't exist or just overwrite checks?
      // Overwriting is safer for updates.
      await file.writeAsBytes(bytes);

      // Return file URI
      return file.uri;
    } catch (e) {
      debugPrint('Error loading asset $assetPath: $e');
      return null;
    }
  }

  @override
  Future<PlayerState> build() async {
    _player = AudioPlayer();

    // Listen to player state changes
    _playerStateSubscription = _player.playerStateStream.listen((playerState) {
      final currentState = state.asData?.value;
      if (currentState != null) {
        // Update isPlaying state based on actual player status
        if (currentState.isPlaying != playerState.playing) {
          state = AsyncData(
            currentState.copyWith(isPlaying: playerState.playing),
          );
        }
      }
    });

    ref.onDispose(() {
      _playerStateSubscription?.cancel();
      _player.dispose();
    });

    final prefs = await SharedPreferences.getInstance();
    final volume = prefs.getDouble('volume') ?? 0.65;
    final showVolume = prefs.getBool('showVolume') ?? false;

    await _player.setVolume(volume);

    // Auto-play logic
    Station? initialStation;
    bool initialPlaying = false;

    final favoriteName = prefs.getString('favorite_station_v2');
    if (favoriteName != null) {
      final stations = ref.read(stationListProvider);
      try {
        final station = stations.firstWhere(
          (s) => s.name == favoriteName,
          orElse: () => stations
              .first, // Fallback not needed if we check null, but firstWhere throws
        );

        // Check if we actually found it (orElse handles missing, but let's be safe)
        if (stations.contains(station)) {
          // Simple check
          initialStation = station;

          // Prepare audio source
          final artUri = station.art.isNotEmpty
              ? await _getAssetUri(station.art)
              : null;

          await _player.setAudioSource(
            AudioSource.uri(
              Uri.parse(station.url),
              tag: MediaItem(
                id: station.url,
                album: 'Sakha Radio',
                title: station.name,
                artist: station.desc,
                artUri: artUri,
              ),
            ),
          );

          // Attempt to play
          if (!kIsWeb) {
            await _player.play();
            initialPlaying = true;
            debugPrint("Auto-playing favorite: ${station.name}");
          } else {
            debugPrint("Auto-play skipped on web to prevent NotAllowedError");
            // Station is set as current, but not playing. User must tap play manually.
          }
        }
      } catch (e) {
        debugPrint("Auto-play failed: $e");
        // If play failed, we might still want to show the station as selected but paused?
        // If initialStation was set before error, it acts as selected.
      }
    }

    return PlayerState(
      volume: volume,
      showVolumeSlider: showVolume,
      currentStation: initialStation,
      isPlaying: initialPlaying,
    );
  }

  Future<void> playStation(Station station) async {
    final currentState = state.asData?.value;
    if (currentState == null) return;

    // 1. Tapping the same station: Toggle Play/Pause
    if (currentState.currentStation?.name == station.name) {
      if (currentState.isPlaying) {
        // If playing, pause it. Notification stays.
        await _player.pause();
        // Listener will update state to isPlaying: false
      } else {
        // If paused, play.
        await _player.play();
        // Listener will update state to isPlaying: true
      }
      return;
    }

    // 2. Changing station
    try {
      // Optimistic update: Show new station playing immediately
      state = AsyncData(
        currentState.copyWith(currentStation: station, isPlaying: true),
      );

      // Stop previous (or pause?) - Stop is better for switching streams to release resources
      await _player.stop();

      final artUri = station.art.isNotEmpty
          ? await _getAssetUri(station.art)
          : null;

      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(station.url),
          tag: MediaItem(
            id: station.url,
            album: 'Sakha Radio',
            title: station.name,
            artist: station.desc,
            artUri: artUri,
          ),
        ),
      );

      await _player.play();
    } catch (e) {
      debugPrint("Error playing station: $e");
      // Revert to stopped if failed? Or keep selected but paused?
      state = AsyncData(
        (state.asData?.value ?? currentState).copyWith(isPlaying: false),
      );
    }
  }

  Future<void> stop() async {
    final currentState = state.asData?.value;
    if (currentState == null) return;

    state = await AsyncValue.guard(() async {
      await _player.stop();
      return currentState.copyWith(isPlaying: false);
    });
  }

  Future<void> setVolume(double volume) async {
    final currentState = state.asData?.value;
    if (currentState == null) return;

    state = await AsyncValue.guard(() async {
      await _player.setVolume(volume);
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
