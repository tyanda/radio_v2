import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/radio/presentation/widgets/radio_card_v2.dart';

/// Состояние режима отображения
class ViewModeState {
  final ViewType radioViewType; // Режим для радио (Плитка/Список/Лента)

  const ViewModeState({this.radioViewType = ViewType.grid});

  ViewModeState copyWith({ViewType? radioViewType}) {
    return ViewModeState(radioViewType: radioViewType ?? this.radioViewType);
  }
}

class ViewModeNotifier extends AsyncNotifier<ViewModeState> {
  static const String _radioViewKey = 'radio_view_type';

  @override
  Future<ViewModeState> build() async {
    // Начальная загрузка настроек
    return await _loadSettings();
  }

  Future<ViewModeState> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final viewIndex = prefs.getInt(_radioViewKey) ?? 0;

      final viewType =
          ViewType.values.isNotEmpty && viewIndex < ViewType.values.length
          ? ViewType.values[viewIndex]
          : ViewType.grid;

      return ViewModeState(radioViewType: viewType);
    } catch (e) {
      // При ошибке используем значение по умолчанию
      return const ViewModeState(radioViewType: ViewType.grid);
    }
  }

  /// Установка режима отображения для радио
  Future<void> setRadioViewType(ViewType viewType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_radioViewKey, viewType.index);
      final currentState = await future;
      state = AsyncValue.data(currentState.copyWith(radioViewType: viewType));
    } catch (e) {
      // Игнорируем ошибку сохранения
    }
  }

  /// Получить текущий режим отображения для радио
  ViewType get radioViewType => state.value?.radioViewType ?? ViewType.grid;
}

final viewModeProvider = AsyncNotifierProvider<ViewModeNotifier, ViewModeState>(
  ViewModeNotifier.new,
);
