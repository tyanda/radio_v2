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
import 'package:radio_v2/features/radio/services/radio_browser_metadata_service.dart';
import 'package:radio_v2/features/radio/services/album_art_service.dart';
import 'package:radio_v2/core/providers.dart';
import '../../../../../core/utils/logger.dart';

@immutable
class PlayerState {
  final bool isPlaying;
  final Station? currentStation;
  final String? trackTitle; // Название текущего трека
  final String? trackArtist; // Артист трека
  final String? albumArt; // Обложка альбома из метаданных
  final double volume;
  final bool showVolumeSlider;
  final bool isBuffering;

  const PlayerState({
    this.isPlaying = false,
    this.currentStation,
    this.trackTitle,
    this.trackArtist,
    this.albumArt,
    this.volume = 0.65,
    this.showVolumeSlider = false,
    this.isBuffering = false,
  });

  PlayerState copyWith({
    bool? isPlaying,
    Station? currentStation,
    String? trackTitle,
    String? trackArtist,
    String? albumArt,
    double? volume,
    bool? showVolumeSlider,
    bool? isBuffering,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentStation: currentStation ?? this.currentStation,
      trackTitle: trackTitle ?? this.trackTitle,
      trackArtist: trackArtist ?? this.trackArtist,
      albumArt: albumArt ?? this.albumArt,
      volume: volume ?? this.volume,
      showVolumeSlider: showVolumeSlider ?? this.showVolumeSlider,
      isBuffering: isBuffering ?? this.isBuffering,
    );
  }
}

class PlayerNotifier extends AsyncNotifier<PlayerState> {
  late final RadioPlayer _radioPlayer;
  final RadioBrowserMetadataService _metadataService =
      RadioBrowserMetadataService();
  final AlbumArtService _albumArtService = AlbumArtService();
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _processingStateSubscription;
  StreamSubscription? _mediaItemSubscription;
  StreamSubscription? _metadataSubscription;
  StreamSubscription? _nextSubscription;
  StreamSubscription? _prevSubscription;
  String? _lastSearchKey; // Для кэширования последнего поиска обложки

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
    final audioHandler = ref.read(audioHandlerProvider);
    _radioPlayer = RadioPlayer(audioHandler: audioHandler);

    // Listen to skip actions from the notification
    _nextSubscription = audioHandler.onNext.listen((_) => playNextStation());
    _prevSubscription = audioHandler.onPrev.listen((_) => playPreviousStation());

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

    // Listen to media item changes (track metadata from ICY)
    _mediaItemSubscription = _radioPlayer.mediaItemStream.listen((mediaItem) {
      final currentState = state.asData?.value;
      if (currentState != null && mediaItem != null) {
        String? albumArt = mediaItem.artUri?.toString();

        if (albumArt == null) {
          final searchKey = '${mediaItem.artist}-${mediaItem.title}';
          if (_lastSearchKey != searchKey) {
            _lastSearchKey = searchKey;
            _fetchAlbumArt(mediaItem.artist, mediaItem.title);
          }
        }

        state = AsyncData(
          currentState.copyWith(
            trackTitle: mediaItem.title,
            trackArtist: mediaItem.artist,
            albumArt: albumArt ?? currentState.albumArt,
          ),
        );
      }
    });

    ref.onDispose(() {
      _playerStateSubscription?.cancel();
      _processingStateSubscription?.cancel();
      _mediaItemSubscription?.cancel();
      _metadataSubscription?.cancel();
      _nextSubscription?.cancel();
      _prevSubscription?.cancel();
      _metadataService.stopFetchingMetadata();
      _metadataService.dispose();
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

          if (!kIsWeb) {
            Future.microtask(() async {
              try {
                await _radioPlayer.play();
              } catch (e) {
                Logger.error("Auto-play failed: $e", tag: 'Player');
              }
            });
          }
        }
      } catch (e) {
        Logger.error("Auto-play error: $e", tag: 'Player');
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

    if (currentState.currentStation?.name == station.name) {
      if (currentState.isPlaying) {
        await _radioPlayer.pause();
      } else {
        await _radioPlayer.play();
      }
      return;
    }

    try {
      state = AsyncData(
        currentState.copyWith(
          currentStation: station,
          isPlaying: false,
          isBuffering: true,
        ),
      );

      await _radioPlayer.stop();
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

      _metadataService.stopFetchingMetadata();
      final radioBrowserUuid = station.metadata?['radio_browser_uuid'];
      if (radioBrowserUuid != null) {
        _metadataService.startFetchingMetadata(radioBrowserUuid);
        _metadataSubscription?.cancel();
        _metadataSubscription = _metadataService.metadataStream.listen((songTitle) {
          final s = state.asData?.value;
          if (s != null) {
            state = AsyncData(s.copyWith(
              trackTitle: songTitle?.isNotEmpty == true ? songTitle : station.name,
              trackArtist: null,
            ));
          }
        });
      }

      await _radioPlayer.play();
    } catch (e) {
      Logger.error("playStation error: $e", tag: 'Player');
      state = AsyncData(currentState.copyWith(isPlaying: false, isBuffering: false));
    }
  }

  Future<void> stop() async {
    final currentState = state.asData?.value;
    if (currentState == null) return;
    await _radioPlayer.stop();
    state = AsyncData(currentState.copyWith(isPlaying: false));
  }

  Future<void> setVolume(double volume) async {
    final currentState = state.asData?.value;
    if (currentState == null) return;
    await _radioPlayer.setVolume(volume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('volume', volume);
    state = AsyncData(currentState.copyWith(volume: volume));
  }

  Future<void> toggleVolumeSlider() async {
    final currentState = state.asData?.value;
    if (currentState == null) return;
    final newShowVolume = !currentState.showVolumeSlider;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showVolume', newShowVolume);
    state = AsyncData(currentState.copyWith(showVolumeSlider: newShowVolume));
  }

  Future<void> playNextStation() async {
    final currentState = state.asData?.value;
    if (currentState?.currentStation == null) return;

    final stations = ref.read(stationListProvider);
    final currentIndex = stations.indexWhere((s) => s.name == currentState!.currentStation!.name);
    if (currentIndex < 0) return;

    final nextIndex = (currentIndex + 1) % stations.length;
    await playStation(stations[nextIndex]);
  }

  Future<void> playPreviousStation() async {
    final currentState = state.asData?.value;
    if (currentState?.currentStation == null) return;

    final stations = ref.read(stationListProvider);
    final currentIndex = stations.indexWhere((s) => s.name == currentState!.currentStation!.name);
    if (currentIndex < 0) return;

    final prevIndex = currentIndex - 1 < 0 ? stations.length - 1 : currentIndex - 1;
    await playStation(stations[prevIndex]);
  }

  Future<void> _fetchAlbumArt(String? artist, String? title) async {
    try {
      final artUrl = await _albumArtService.searchAlbumArt(artist: artist, title: title);
      final currentState = state.asData?.value;
      if (artUrl != null && currentState != null && currentState.trackTitle == title) {
        state = AsyncData(currentState.copyWith(albumArt: artUrl));
      }
    } catch (e) {
      Logger.log("AlbumArt error: $e", tag: 'Player');
    }
  }
}

final playerProvider = AsyncNotifierProvider<PlayerNotifier, PlayerState>(PlayerNotifier.new);
