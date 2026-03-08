import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design.dart';
import '../../data/models/chart_item.dart';
import '../../../radio/presentation/providers/player_provider.dart';

/// Виджет видео-рекламы с 30-секундным видео из Firebase Firestore
/// Адаптация React-версии для Flutter
///
/// Firebase Firestore:
/// - artifacts/sakhalive-remote/videoUrl
class VideoAdCard extends ConsumerStatefulWidget {
  final ChartItem item;
  final bool isDark;

  const VideoAdCard({super.key, required this.item, required this.isDark});

  @override
  ConsumerState<VideoAdCard> createState() => _VideoAdCardState();
}

class _VideoAdCardState extends ConsumerState<VideoAdCard> {
  // 1. ПЕРЕМЕННЫЕ СОСТОЯНИЯ (как в React)
  bool _videoLoaded = false; // Загрузилось ли видео?
  bool _isMuted = true; // Включен или выключен звук
  VideoPlayerController? _controller;
  StreamSubscription<DocumentSnapshot>? _videoSubscription;

  @override
  void initState() {
    super.initState();
    _initFirebaseListener();
    // Видео загружается из Firebase Firestore (artifacts/sakhalive-remote/videoUrl)
  }

  // 2. ЛОГИКА ПОЛУЧЕНИЯ ССЫЛКИ (Firebase Firestore - как в React)
  void _initFirebaseListener() {
    // Ссылка на документ "sakhalive-remote" в коллекции "artifacts"
    final videoDocRef = FirebaseFirestore.instance
        .collection('artifacts')
        .doc('sakhalive-remote');

    // onSnapshot следит за базой: как только меняешь ссылку в Firebase,
    // эта функция сразу срабатывает и обновляет видео в приложении
    _videoSubscription = videoDocRef.snapshots().listen(
      (snap) {
        if (snap.exists) {
          final data = snap.data();
          final videoUrl = data?['videoUrl'] as String?;

          if (videoUrl != null && videoUrl.isNotEmpty) {
            _initVideoPlayer(videoUrl);
          }
        }
      },
      onError: (error) {
        debugPrint('❌ VideoAd: Ошибка Firestore: $error');
      },
    );
  }

  // 3. ВИЗУАЛЬНЫЙ ПЛЕЕР (аналог <video> в React)
  void _initVideoPlayer(String url) async {
    // key={myVideoUrl} - заставляет плеер перезагрузиться при смене ссылки
    await _controller?.dispose();

    // mixWithOthers: true - видео не перехватывает Audio Focus
    // Это позволяет музыке продолжать воспроизводиться при просмотре видео
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
        allowBackgroundPlayback: false,
      ),
    );

    await _controller!
        .initialize()
        .then((_) async {
          // СНАЧАЛА устанавливаем громкость в 0 (чтобы не было звука при инициализации)
          await _controller!.setVolume(0.0);

          setState(() {
            _videoLoaded = true; // onLoadedData(() => setVideoLoaded(true))
            _isMuted = true; // Синхронизируем состояние
          });

          // autoPlay
          await _controller!.play();
          // loop
          _controller!.setLooping(true);
        })
        .catchError((error) {
          debugPrint('❌ VideoAd: Ошибка: $error');
        });
  }

  @override
  void dispose() {
    _videoSubscription?.cancel(); // return () => unsubVideo()
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            SakhaFuturism.glassFill(widget.isDark, opacity: 0.72),
            Color.alphaBlend(
              theme.primaryColor.withValues(alpha: 0.16),
              SakhaFuturism.glassFill(widget.isDark, opacity: 0.52),
            ),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: SakhaFuturism.glassBorder(
            widget.isDark,
            accent: theme.primaryColor,
          ),
          width: 1.2,
        ),
        boxShadow: SakhaFuturism.shadow(
          widget.isDark,
          accent: theme.primaryColor,
          lift: 1.1,
        ),
      ),
      child: Stack(
        children: [
          // 3. ВИЗУАЛЬНЫЙ ПЛЕЕР
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppEffects.radius2xl),
              child:
                  _videoLoaded &&
                      _controller != null &&
                      _controller!.value.isInitialized
                  ? VideoPlayer(_controller!)
                  : Container(
                      color: widget.isDark
                          ? AppColors.cardBackground.withValues(alpha: 0.9)
                          : Colors.grey.shade200,
                      child: Center(
                        child: !_videoLoaded
                            ? const SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.error_outline,
                                color: AppColors.error,
                                size: 48,
                              ),
                      ),
                    ),
            ),
          ),

          // Градиент поверх видео (для красоты)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppEffects.radius2xl),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
          ),

          // Текстовый логотип SakhaLive и информация об объявлении
          Positioned(
            left: AppSpacing.lg,
            bottom: AppSpacing.lg,
            right: AppSpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                    children: [
                      const TextSpan(text: "Sakha"),
                      TextSpan(
                        text: "Live",
                        style: TextStyle(color: theme.primaryColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'видео недели',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Кнопка Mute/Unmute (в правом верхнем углу)
          Positioned(
            top: AppSpacing.md,
            right: AppSpacing.md,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  final newMuted = !_isMuted;
                  setState(() {
                    _isMuted = newMuted;
                  });

                  // Если включаем звук (было muted, стало unmuted) - ставим радио на паузу
                  if (!newMuted) {
                    // Включаем звук видео
                    await _controller?.setVolume(1.0);
                    // Ставим радио на паузу
                    ref.read(playerProvider.notifier).stop();
                  } else {
                    // Если выключаем звук - возвращаем громкость видео в 0
                    await _controller?.setVolume(0.0);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
