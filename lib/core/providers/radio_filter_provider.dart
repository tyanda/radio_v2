import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider для управления состоянием поиска и фильтров в RadioCardsView
class RadioFilterState {
  final String searchQuery;
  final bool showFavoritesOnly;
  final bool isSearchFocused;

  const RadioFilterState({
    this.searchQuery = '',
    this.showFavoritesOnly = false,
    this.isSearchFocused = false,
  });

  RadioFilterState copyWith({
    String? searchQuery,
    bool? showFavoritesOnly,
    bool? isSearchFocused,
  }) {
    return RadioFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      showFavoritesOnly: showFavoritesOnly ?? this.showFavoritesOnly,
      isSearchFocused: isSearchFocused ?? this.isSearchFocused,
    );
  }
}

class RadioFilterNotifier extends StateNotifier<RadioFilterState> {
  RadioFilterNotifier() : super(const RadioFilterState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleFavoritesFilter() {
    state = state.copyWith(
      showFavoritesOnly: !state.showFavoritesOnly,
    );
  }

  void setFavoritesFilter(bool value) {
    state = state.copyWith(showFavoritesOnly: value);
  }

  void focusSearch() {
    state = state.copyWith(isSearchFocused: true);
  }

  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      isSearchFocused: false,
    );
  }

  void clearFocus() {
    state = state.copyWith(isSearchFocused: false);
  }
}

final radioFilterProvider = StateNotifierProvider<RadioFilterNotifier, RadioFilterState>(
  (ref) => RadioFilterNotifier(),
);
