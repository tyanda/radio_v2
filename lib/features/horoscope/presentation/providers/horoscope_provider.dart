import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radio_v2/features/horoscope/domain/zodiac_sign.dart';
import 'package:radio_v2/features/radio/presentation/providers/radio_providers.dart';

@immutable
class HoroscopeState {
  final ZodiacSign selectedSign;

  const HoroscopeState({required this.selectedSign});

  HoroscopeState copyWith({ZodiacSign? selectedSign}) {
    return HoroscopeState(
      selectedSign: selectedSign ?? this.selectedSign,
    );
  }
}

class HoroscopeNotifier extends Notifier<HoroscopeState> {
  @override
  HoroscopeState build() {
    final initialSign = ref.watch(zodiacSignsProvider).first;
    return HoroscopeState(selectedSign: initialSign);
  }

  void selectSign(ZodiacSign sign) {
    state = state.copyWith(selectedSign: sign);
  }
}

final horoscopeProvider = NotifierProvider<HoroscopeNotifier, HoroscopeState>(HoroscopeNotifier.new);
