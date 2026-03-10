import 'package:just_audio_background/just_audio_background.dart';

/// Инициализация just_audio_background для работы в фоне
Future<void> initAudioBackground() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.sakhalive.radio.audio',
    androidNotificationChannelName: 'SakhaLive Radio Playback',
    androidNotificationOngoing: true,
    androidNotificationIcon: 'mipmap/ic_launcher',
    androidShowNotificationBadge: true,
    artDownscaleWidth: 300,
    artDownscaleHeight: 300,
  );
}
