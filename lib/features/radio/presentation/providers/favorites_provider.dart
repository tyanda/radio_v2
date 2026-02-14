import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesNotifier extends Notifier<String?> {
  static const String _favoriteKey =
      'favorite_station_v2'; // Changed key to avoid conflict

  @override
  String? build() {
    _loadFavorite();
    return null;
  }

  Future<void> _loadFavorite() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorite = prefs.getString(_favoriteKey);
      if (favorite != null && favorite.isNotEmpty) {
        state = favorite;
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> toggleFavorite(String stationName) async {
    String? newState;

    if (state == stationName) {
      // If already favorite, remove it (toggle off)
      newState = null;
    } else {
      // Set as new favorite (replacing any previous)
      newState = stationName;
    }

    state = newState;

    try {
      final prefs = await SharedPreferences.getInstance();
      if (newState == null) {
        await prefs.remove(_favoriteKey);
      } else {
        await prefs.setString(_favoriteKey, newState);
      }
    } catch (e) {
      // Handle error
    }
  }

  bool isFavorite(String stationName) {
    return state == stationName;
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, String?>(
  FavoritesNotifier.new,
);
