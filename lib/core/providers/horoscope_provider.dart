import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radio_v2/core/utils/logger.dart';
import 'package:radio_v2/features/horoscope/data/implementations/horoscope_repository_impl.dart';
import 'package:radio_v2/features/horoscope/data/models/horoscope_data.dart';
import 'package:radio_v2/features/horoscope/data/services/horoscope_service.dart';
import 'package:radio_v2/features/horoscope/domain/zodiac_sign.dart';

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
      Logger.log('Loading horoscope for: ${sign.name}', tag: 'HoroscopeProvider');
      final horoscopeData = await _repository.getHoroscope(sign.id, 'today');
      Logger.log('Horoscope loaded: ${horoscopeData.source}', tag: 'HoroscopeProvider');
      state = state.copyWith(
        horoscopeData: horoscopeData,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      Logger.error('Failed to load horoscope: $e', tag: 'HoroscopeProvider');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void selectSign(ZodiacSign sign) async {
    // Обновляем выбранный знак
    state = state.copyWith(
      selectedSign: sign,
      isLoading: true,
      errorMessage: null,
    );

    // Загружаем гороскоп для нового знака
    try {
      final horoscopeData = await _repository.getHoroscope(sign.id, 'today');
      state = state.copyWith(horoscopeData: horoscopeData, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final horoscopeProvider = NotifierProvider<HoroscopeNotifier, HoroscopeState>(
  HoroscopeNotifier.new,
);
