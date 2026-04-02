import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  static const String favoritesKey = 'favorites';
  static const String xpKey = 'xp';
  static const String rewardedKey = 'rewarded';

  final Set<String> _favoriteBeliefIds = {};
  final Set<String> _rewardedBeliefIds = {};
  int _xp = 0;

  Set<String> get favoriteBeliefIds => _favoriteBeliefIds;
  Set<String> get rewardedBeliefIds => _rewardedBeliefIds;
  int get xp => _xp;

  bool isFavorite(String beliefId) {
    return _favoriteBeliefIds.contains(beliefId);
  }

  int get level {
    if (_xp >= 350) return 5;
    if (_xp >= 220) return 4;
    if (_xp >= 120) return 3;
    if (_xp >= 50) return 2;
    return 1;
  }

  int get nextLevelXp {
    switch (level) {
      case 1:
        return 50;
      case 2:
        return 120;
      case 3:
        return 220;
      case 4:
        return 350;
      default:
        return 350;
    }
  }

  double get levelProgress {
    if (level >= 5) return 1.0;

    int currentLevelMin;
    int nextLevelMax;

    switch (level) {
      case 1:
        currentLevelMin = 0;
        nextLevelMax = 50;
        break;
      case 2:
        currentLevelMin = 50;
        nextLevelMax = 120;
        break;
      case 3:
        currentLevelMin = 120;
        nextLevelMax = 220;
        break;
      case 4:
        currentLevelMin = 220;
        nextLevelMax = 350;
        break;
      default:
        currentLevelMin = 0;
        nextLevelMax = 50;
    }

    return (_xp - currentLevelMin) / (nextLevelMax - currentLevelMin);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFavorites = prefs.getStringList(favoritesKey) ?? [];
    final savedXp = prefs.getInt(xpKey) ?? 0;
    final savedRewarded = prefs.getStringList(rewardedKey) ?? [];

    _favoriteBeliefIds
      ..clear()
      ..addAll(savedFavorites);

    _rewardedBeliefIds
      ..clear()
      ..addAll(savedRewarded);

    _xp = savedXp;
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(favoritesKey, _favoriteBeliefIds.toList());
  }

  Future<void> _saveXp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(xpKey, _xp);
  }

  Future<void> _saveRewarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(rewardedKey, _rewardedBeliefIds.toList());
  }

  Future<void> toggleFavorite(String beliefId) async {
    if (_favoriteBeliefIds.contains(beliefId)) {
      _favoriteBeliefIds.remove(beliefId);
    } else {
      _favoriteBeliefIds.add(beliefId);
    }

    await _saveFavorites();
    notifyListeners();
  }

  Future<void> addXp(int amount) async {
    _xp += amount;
    await _saveXp();
    notifyListeners();
  }

  Future<bool> rewardIfFirstTime(String beliefId, int xpAmount) async {
    if (_rewardedBeliefIds.contains(beliefId)) {
      return false;
    }

    _rewardedBeliefIds.add(beliefId);
    await _saveRewarded();

    _xp += xpAmount;
    await _saveXp();

    notifyListeners();
    return true;
  }
}