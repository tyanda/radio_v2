import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/charts/data/models/chart_item.dart';
import '../core/utils/logger.dart';

/// Сервис для управления рекламой из Firebase Firestore
class AdsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Получает список активных видео-объявлений из коллекции 'ads'
  Future<List<ChartItem>> fetchVideoAds() async {
    try {
      final snapshot = await _firestore
          .collection('ads')
          .where('isActive', isEqualTo: true)
          .get();

      if (snapshot.docs.isEmpty) {
        Logger.log('ℹ️ Рекламные объявления не найдены в Firestore', tag: 'AdsService');
        return [];
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ChartItem(
          id: doc.id,
          type: ChartItemType.videoAd,
          title: data['title'] ?? 'Специальное предложение',
          // В Firestore используем поле videoUrl для самого видео
          videoUrl: data['videoUrl'] ?? '',
          // Ссылка для перехода при клике
          previewUrl: data['linkUrl'] ?? '', 
          actionText: data['actionText'] ?? 'Подробнее',
          duration: data['duration'] ?? '30s',
          coverUrl: data['thumbnailUrl'] ?? '',
        );
      }).toList();
    } catch (e) {
      Logger.error('❌ Ошибка загрузки рекламы из Firestore: $e', tag: 'AdsService');
      return [];
    }
  }
}
