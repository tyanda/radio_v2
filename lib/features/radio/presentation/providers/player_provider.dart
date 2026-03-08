import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sakha_live/features/radio/domain/station.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sakha_live/core/providers/radio_providers.dart';
import 'package:sakha_live/features/radio/data/radio_player.dart';
import 'package:sakha_live/features/radio/services/radio_browser_metadata_service.dart';
import 'package:sakha_live/features/radio/services/album_art_service.dart';
import 'package:sakha_live/core/providers.dart';
import 'package:sakha_live/features/widgets/widgets.dart';
import '../../../../../core/utils/logger.dart';
import '../../../charts/data/models/chart_item.dart';

@immutable
class PlayerState {
  final bool isPlaying;
  final Station? currentStation;
  final String? trackTitle; // Название текущего трека
  final String? trackArtist; // Артист трека
  final String? albumArt; // Обложка альбома из метаданных
  final String? currentTrackId; // ID текущего трека (для чарта)
  final double volume;
  final bool showVolumeSlider;
  final bool isBuffering;

  const PlayerState({
    this.isPlaying = false,
    this.currentStation,
    this.trackTitle,
    this.trackArtist,
    this.albumArt,
    this.currentTrackId,
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
    String? currentTrackId,
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
      currentTrackId: currentTrackId ?? this.currentTrackId,
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

  // Очередь треков для чарта
  List<ChartItem> _playlistTracks = [];
  int _currentPlaylistIndex = -1;
  StreamSubscription? _playlistStateSubscription;
  bool _isSwitchingTrack =
      false; // Флаг для предотвращения рекурсивных переключений

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

    // На вебе создаём RadioPlayer без AudioHandler
    if (kIsWeb) {
      _radioPlayer = RadioPlayer(audioHandler: null);
    } else {
      if (audioHandler == null) {
        throw Exception('AudioHandler не доступен на этой платформе');
      }
      _radioPlayer = RadioPlayer(audioHandler: audioHandler);
    }

    // Listen to skip actions from the notification (только для нативных платформ)
    if (!kIsWeb && audioHandler != null) {
      _nextSubscription = audioHandler.onNext.listen((_) => playNextStation());
      _prevSubscription = audioHandler.onPrev.listen(
        (_) => playPreviousStation(),
      );
    }

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

    // Подписка на изменение состояния плеера для автопереключения треков в плейлисте
    _playlistStateSubscription = _radioPlayer.playerStateStream.listen((
      playerState,
    ) {
      // Если трек закончился и есть следующий в плейлисте
      // Проверяем флаг _isSwitchingTrack для предотвращения рекурсивных вызовов
      if (!_isSwitchingTrack &&
          playerState.processingState == ProcessingState.completed &&
          _currentPlaylistIndex >= 0 &&
          _currentPlaylistIndex < _playlistTracks.length - 1) {
        // Переключаем на следующий трек
        _playNextPlaylistTrack();
      }
    });

    ref.onDispose(() {
      _playerStateSubscription?.cancel();
      _processingStateSubscription?.cancel();
      _mediaItemSubscription?.cancel();
      _metadataSubscription?.cancel();
      _nextSubscription?.cancel();
      _prevSubscription?.cancel();
      _playlistStateSubscription?.cancel();
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

          if (!kIsWeb) {
            final artUri = station.art.isNotEmpty
                ? await _getAssetUri(station.art)
                : null;

            await _radioPlayer.playStream(
              url: station.url,
              title: station.name,
              artist: station.desc,
              album: 'SakhaLive',
              artUri: artUri?.toString(),
            );

            Future.microtask(() async {
              try {
                await _radioPlayer.play();
              } catch (e) {
                Logger.error("Auto-play failed: $e", tag: 'Player');
              }
            });
          } else {
            // На Web только устанавливаем текущую станцию без загрузки потока
            // Загрузка начнется когда пользователь нажмет Play
            Logger.log(
              "Web: Auto-play skipped in build(), station set to ${station.name}",
              tag: 'Player',
            );
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

  Future<void> playTrack(dynamic track) async {
    final currentState = state.asData?.value;
    if (currentState == null || track.previewUrl == null) return;

    // Если этот же трек уже играет, ставим на паузу
    if (currentState.currentTrackId == track.id && currentState.isPlaying) {
      await _radioPlayer.pause();
      return;
    }

    try {
      state = AsyncData(
        currentState.copyWith(
          currentStation: null, // Сбрасываем станцию при игре трека
          currentTrackId: track.id, // Сохраняем ID трека для идентификации
          trackTitle: track.title,
          trackArtist: track.artist,
          albumArt: track.coverUrl,
          isPlaying: false,
          isBuffering: true,
        ),
      );

      await _radioPlayer.stop();
      await _radioPlayer.playStream(
        url: track.previewUrl!,
        title: track.title,
        artist: track.artist ?? 'SakhaLive',
        album: 'Top Chart',
        artUri: track.coverUrl,
      );

      await _radioPlayer.play();
      state = AsyncData(
        state.asData!.value.copyWith(isPlaying: true, isBuffering: false),
      );
    } catch (e) {
      Logger.error("playTrack error: $e", tag: 'Player');
      state = AsyncData(
        currentState.copyWith(isPlaying: false, isBuffering: false),
      );
    }
  }

  /// Воспроизведение плейлиста чарта с очередью треков
  Future<void> playPlaylist(List<ChartItem> tracks, int startIndex) async {
    final currentState = state.asData?.value;
    if (currentState == null || tracks.isEmpty) return;

    final track = tracks[startIndex];
    if (track.previewUrl == null) return;

    try {
      // Фильтруем треки без previewUrl
      final validTracks = tracks
          .where((t) => t.previewUrl != null && t.previewUrl!.isNotEmpty)
          .toList();

      if (validTracks.isEmpty) return;

      // Находим индекс текущего трека в отфильтрованном списке
      final validStartIndex = validTracks.indexWhere((t) => t.id == track.id);
      _currentPlaylistIndex = validStartIndex >= 0 ? validStartIndex : 0;
      _playlistTracks = validTracks;

      state = AsyncData(
        currentState.copyWith(
          currentStation: null,
          currentTrackId: track.id,
          trackTitle: track.title,
          trackArtist: track.artist,
          albumArt: track.coverUrl,
          isPlaying: false,
          isBuffering: true,
        ),
      );

      await _radioPlayer.stop();
      await _radioPlayer.playStream(
        url: track.previewUrl!,
        title: track.title,
        artist: track.artist ?? 'SakhaLive',
        album: 'Top Chart',
        artUri: track.coverUrl,
      );

      await _radioPlayer.play();
      state = AsyncData(
        state.asData!.value.copyWith(isPlaying: true, isBuffering: false),
      );

      Logger.log(
        '🎵 Playlist started with ${validTracks.length} tracks, from index $_currentPlaylistIndex',
        tag: 'Player',
      );
    } catch (e) {
      Logger.error("playPlaylist error: $e", tag: 'Player');
      state = AsyncData(
        currentState.copyWith(isPlaying: false, isBuffering: false),
      );
    }
  }

  /// Переключение на следующий трек в плейлисте
  Future<void> _playNextPlaylistTrack() async {
    // Защита от рекурсивных вызовов
    if (_isSwitchingTrack) return;

    if (_currentPlaylistIndex < 0 ||
        _currentPlaylistIndex >= _playlistTracks.length - 1) {
      return; // Нет следующего трека
    }

    _isSwitchingTrack = true;

    try {
      final nextIndex = _currentPlaylistIndex + 1;
      final nextTrack = _playlistTracks[nextIndex];

      if (nextTrack.previewUrl == null) {
        // Пропускаем трек без previewUrl
        _currentPlaylistIndex = nextIndex;
        await _playNextPlaylistTrack();
        return;
      }

      final currentState = state.asData?.value;
      if (currentState == null) return;

      Logger.log(
        '🎵 Playlist: auto-switching to track ${nextIndex + 1}: ${nextTrack.title}',
        tag: 'Player',
      );

      state = AsyncData(
        currentState.copyWith(
          currentTrackId: nextTrack.id,
          trackTitle: nextTrack.title,
          trackArtist: nextTrack.artist,
          albumArt: nextTrack.coverUrl,
          isBuffering: true,
        ),
      );

      // Сначала устанавливаем новый поток, потом останавливаем старый
      await _radioPlayer.playStream(
        url: nextTrack.previewUrl!,
        title: nextTrack.title,
        artist: nextTrack.artist ?? 'SakhaLive',
        album: 'Top Chart',
        artUri: nextTrack.coverUrl,
      );

      await _radioPlayer.play();
      _currentPlaylistIndex = nextIndex;

      state = AsyncData(
        state.asData!.value.copyWith(isPlaying: true, isBuffering: false),
      );
    } catch (e) {
      Logger.error("Error switching playlist track: $e", tag: 'Player');
      rethrow;
    } finally {
      _isSwitchingTrack = false;
    }
  }

  Future<void> playStation(Station station) async {
    final currentState = state.asData?.value;
    if (currentState == null) return;

    // Сбрасываем плейлист при переключении на радио
    _playlistTracks = [];
    _currentPlaylistIndex = -1;
    _isSwitchingTrack = false;

    // Сравниваем по id для корректного определения той же станции
    if (currentState.currentStation?.id == station.id) {
      if (currentState.isPlaying) {
        await _radioPlayer.pause();
      } else {
        await _radioPlayer.play();
      }
      return;
    }

    try {
      Logger.log(
        "📻 Switching to station: ${station.name} (id: ${station.id})",
        tag: 'Player',
      );

      // СНАЧАЛА обновляем состояние с новыми метаданными станции
      state = AsyncData(
        currentState.copyWith(
          currentStation: station,
          // Сбрасываем метаданные трека при переключении на радио
          trackTitle: station.name,
          trackArtist: null,
          albumArt: null,
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
        album: 'SakhaLive',
        artUri: artUri?.toString(),
      );

      // Сбрасываем старую подписку на метаданные
      _metadataService.stopFetchingMetadata();
      _metadataSubscription?.cancel();

      final radioBrowserUuid = station.metadata?['radio_browser_uuid'];
      if (radioBrowserUuid != null) {
        _metadataService.startFetchingMetadata(radioBrowserUuid);
        // Подписываемся на новые метаданные
        _metadataSubscription = _metadataService.metadataStream.listen((
          songTitle,
        ) {
          final s = state.asData?.value;
          if (s != null) {
            state = AsyncData(
              s.copyWith(
                trackTitle: songTitle?.isNotEmpty == true
                    ? songTitle
                    : station.name,
                trackArtist: null,
              ),
            );
          }
        });
      }

      await _radioPlayer.play();

      // ФИНАЛЬНОЕ обновление состояния - берём актуальное состояние
      final newState = state.asData?.value;
      if (newState != null) {
        state = AsyncData(
          newState.copyWith(isPlaying: true, isBuffering: false),
        );
      }

      // Обновляем виджет
      ref
          .read(homeWidgetStateProvider.notifier)
          .updateFromPlayerState(
            stationName: station.name,
            currentTrack: station.desc,
            albumArt: artUri?.toString(),
            isPlaying: true,
          );

      Logger.log("✅ Station switched: ${station.name}", tag: 'Player');
    } catch (e) {
      Logger.error("playStation error: $e", tag: 'Player');
      final currentState = state.asData?.value;
      if (currentState != null) {
        state = AsyncData(
          currentState.copyWith(isPlaying: false, isBuffering: false),
        );
      }
    }
  }

  Future<void> stop() async {
    final currentState = state.asData?.value;
    if (currentState == null) return;
    await _radioPlayer.stop();
    state = AsyncData(currentState.copyWith(isPlaying: false));

    // Обновляем виджет
    ref
        .read(homeWidgetStateProvider.notifier)
        .updateFromPlayerState(
          stationName: currentState.currentStation?.name ?? 'SakhaLive',
          isPlaying: false,
        );
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
    final currentIndex = stations.indexWhere(
      (s) => s.name == currentState!.currentStation!.name,
    );
    if (currentIndex < 0) return;

    final nextIndex = (currentIndex + 1) % stations.length;
    await playStation(stations[nextIndex]);
  }

  Future<void> playPreviousStation() async {
    final currentState = state.asData?.value;
    if (currentState?.currentStation == null) return;

    final stations = ref.read(stationListProvider);
    final currentIndex = stations.indexWhere(
      (s) => s.name == currentState!.currentStation!.name,
    );
    if (currentIndex < 0) return;

    final prevIndex = currentIndex - 1 < 0
        ? stations.length - 1
        : currentIndex - 1;
    await playStation(stations[prevIndex]);
  }

  Future<void> _fetchAlbumArt(String? artist, String? title) async {
    try {
      final artUrl = await _albumArtService.searchAlbumArt(
        artist: artist,
        title: title,
      );
      final currentState = state.asData?.value;
      if (artUrl != null &&
          currentState != null &&
          currentState.trackTitle == title) {
        state = AsyncData(currentState.copyWith(albumArt: artUrl));
      }
    } catch (e) {
      Logger.log("AlbumArt error: $e", tag: 'Player');
    }
  }
}

final playerProvider = AsyncNotifierProvider<PlayerNotifier, PlayerState>(
  PlayerNotifier.new,
);
