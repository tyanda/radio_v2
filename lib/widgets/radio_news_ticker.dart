import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radio_v2/core/providers/providers.dart';
import 'package:radio_v2/core/theme/app_colors.dart';
import '../core/utils/logger.dart';

/// Виджет бегущей строки с новостями
/// Получает данные через Firebase Hosting Proxy (/api/ysia)
class RadioNewsTicker extends ConsumerStatefulWidget {
  const RadioNewsTicker({super.key});

  @override
  ConsumerState<RadioNewsTicker> createState() => _RadioNewsTickerState();
}

class _RadioNewsTickerState extends ConsumerState<RadioNewsTicker> {
  String _newsText = "Загрузка ленты...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    try {
      final dio = ref.read(dioProvider);
      
      // Прямой запрос к нашему прокси-пути
      final response = await dio.get(
        '/api/ysia',
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status! < 500,
          responseType: ResponseType.plain,
        ),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = response.data.toString();
        
        // Пробуем распарсить как RSS
        String news = _parseRssToText(data);
        
        if (news.isEmpty) {
          // Если не RSS, используем как есть
          news = data.replaceAll('\n', ' ').trim();
        }
        
        if (news.isNotEmpty) {
          setState(() {
            _newsText = news.toUpperCase();
            _isLoading = false;
          });
          Logger.log('Ticker: Loaded ${news.length} chars');
        } else {
          setState(() {
            _newsText = "САХА LIVE РАДИО — ЯКУТСК";
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _newsText = "САХА LIVE РАДИО — ОСТАВАЙТЕСЬ С НАМИ";
          _isLoading = false;
        });
        Logger.error('Ticker: Status ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _newsText = "САХА LIVE РАДИО — ЯКУТСК";
        _isLoading = false;
      });
      Logger.error('Ticker Error: $e');
    }
  }

  /// Парсит RSS и возвращает текст для бегущей строки
  String _parseRssToText(String rssContent) {
    try {
      // Простая парсинг RSS для извлечения заголовков
      final titles = <String>[];
      final lines = rssContent.split('<item>');
      
      for (int i = 1; i < lines.length && titles.length < 5; i++) {
        final item = lines[i];
        final titleStart = item.indexOf('<title>');
        final titleEnd = item.indexOf('</title>');
        
        if (titleStart != -1 && titleEnd != -1) {
          final title = item.substring(titleStart + 7, titleEnd).trim();
          if (title.isNotEmpty) {
            titles.add(title);
          }
        }
      }
      
      if (titles.isNotEmpty) {
        return titles.join('  •  ');
      }
      return '';
    } catch (e) {
      Logger.error('RSS parse error: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        // [2026-02-11] Используем актуальный метод withValues
        color: AppColors.accent.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
              ),
            )
          : Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _newsText,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
