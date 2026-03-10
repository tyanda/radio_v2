import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakha_live/core/utils/logger.dart';
import 'package:sakha_live/features/horoscope/data/implementations/horoscope_repository_impl.dart';
import 'package:sakha_live/features/horoscope/data/models/horoscope_data.dart';
import 'package:sakha_live/features/horoscope/data/services/horoscope_service.dart';
import 'package:sakha_live/features/horoscope/domain/zodiac_sign.dart';

@immutable
class HoroscopeState {
  final ZodiacSign selectedSign;
  final HoroscopeData? horoscopeData;
  final bool isLoading;
  final String? errorMessage;

  const HoroscopeState({
    required this.selectedSign,
    this.horoscopeData,
    this.isLoading = false,
    this.errorMessage,
  });

  HoroscopeState copyWith({
    ZodiacSign? selectedSign,
    HoroscopeData? horoscopeData,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HoroscopeState(
      selectedSign: selectedSign ?? this.selectedSign,
      horoscopeData: horoscopeData ?? this.horoscopeData,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class HoroscopeNotifier extends Notifier<HoroscopeState> {
  late HoroscopeRepositoryImpl _repository;

  @override
  HoroscopeState build() {
    final service = HoroscopeService();
    _repository = HoroscopeRepositoryImpl(service);
    final initialSign = ZodiacSign.all.first;

    // Загружаем гороскоп асинхронно после инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHoroscope(initialSign);
    });

    return HoroscopeState(selectedSign: initialSign, isLoading: true);
  }

  Future<void> _loadHoroscope(ZodiacSign sign) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      Logger.log(
        'Loading horoscope for: ${sign.name}',
        tag: 'HoroscopeProvider',
      );
      final horoscopeData = await _repository.getHoroscope(sign.id, 'today');

      if (horoscopeData.text.isEmpty) {
        throw Exception('Пустой ответ от сервера');
      }

      state = state.copyWith(
        horoscopeData: horoscopeData,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      Logger.error('Failed to load horoscope: $e', tag: 'HoroscopeProvider');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Не удалось загрузить прогноз. Попробуйте позже.',
      );
    }
  }

  Future<void> refresh() async {
    await HoroscopeService.clearCache();
    await _loadHoroscope(state.selectedSign);
  }

  void selectSign(ZodiacSign sign) {
    if (state.selectedSign.id == sign.id && state.horoscopeData != null) return;

    state = state.copyWith(
      selectedSign: sign,
      isLoading: true,
      errorMessage: null,
    );
    _loadHoroscope(sign);
  }
}

final horoscopeProvider = NotifierProvider<HoroscopeNotifier, HoroscopeState>(
  HoroscopeNotifier.new,
);
