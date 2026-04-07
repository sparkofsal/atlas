import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/mock_countries.dart';
import '../models/belief.dart';
import '../models/country_collection.dart';
import '../models/daily_state.dart';
import '../models/item_interaction.dart';
import 'collection_migration_service.dart';
import 'collection_service.dart';
import 'daily_service.dart';

class AppState extends ChangeNotifier {
  static const String favoritesKey = 'favorites';
  static const String xpKey = 'xp';
  static const String rewardedKey = 'rewarded';

  static const String dailyDateKey = 'daily_date';
  static const String dailyBeliefCompletedKey = 'daily_belief_completed';
  static const String dailySayingCompletedKey = 'daily_saying_completed';
  static const String lastActiveDateKey = 'last_active_date';
  static const String currentStreakKey = 'current_streak';

  static const String interactionsKey = 'item_interactions';
  static const String countryCollectionsKey = 'country_collections';
  static const String collectionMigrationVersionKey =
      'collection_migration_version';

  final Set<String> _favoriteBeliefIds = {};
  final Set<String> _rewardedBeliefIds = {};
  final Map<String, ItemInteraction> _interactions = {};
  final Map<String, CountryCollection> _countryCollections = {};

  int _xp = 0;
  late DailyState _dailyState;

  AppState() {
    _dailyState = DailyState.initial(DailyService.todayKey());
  }

  Set<String> get favoriteBeliefIds => _favoriteBeliefIds;
  Set<String> get rewardedBeliefIds => _rewardedBeliefIds;
  int get xp => _xp;

  DailyState get dailyState => _dailyState;
  bool get dailyBeliefCompleted => _dailyState.dailyBeliefCompleted;
  bool get dailySayingCompleted => _dailyState.dailySayingCompleted;
  int get currentStreak => _dailyState.currentStreak;

  bool isFavorite(String beliefId) {
    return _favoriteBeliefIds.contains(beliefId);
  }

  ItemInteraction getInteraction(String itemId) {
    return _interactions[itemId] ?? const ItemInteraction();
  }

  CountryCollection getCountryCollection(String countryCode) {
    return _countryCollections[countryCode] ??
        CountryCollection.initial(countryCode);
  }

  List<CountryCollectionProgress> getCountryProgressList() {
    return mockCountries.map((country) {
      final collection = getCountryCollection(country.code);
      return CollectionService.buildProgress(collection);
    }).toList();
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

    _dailyState = DailyState(
      dateKey: prefs.getString(dailyDateKey) ?? DailyService.todayKey(),
      dailyBeliefCompleted: prefs.getBool(dailyBeliefCompletedKey) ?? false,
      dailySayingCompleted: prefs.getBool(dailySayingCompletedKey) ?? false,
      lastActiveDateKey: prefs.getString(lastActiveDateKey),
      currentStreak: prefs.getInt(currentStreakKey) ?? 0,
    );

    final savedInteractionsRaw = prefs.getString(interactionsKey);
    _interactions.clear();
    if (savedInteractionsRaw != null && savedInteractionsRaw.isNotEmpty) {
      final decoded = jsonDecode(savedInteractionsRaw) as Map<String, dynamic>;
      decoded.forEach((key, value) {
        _interactions[key] =
            ItemInteraction.fromJson(Map<String, dynamic>.from(value));
      });
    }

    final savedCollectionsRaw = prefs.getString(countryCollectionsKey);
    _countryCollections.clear();
    if (savedCollectionsRaw != null && savedCollectionsRaw.isNotEmpty) {
      final decoded = jsonDecode(savedCollectionsRaw) as Map<String, dynamic>;
      decoded.forEach((key, value) {
        _countryCollections[key] =
            CountryCollection.fromJson(Map<String, dynamic>.from(value));
      });
    }

    _dailyState = DailyService.syncState(_dailyState);
    await _saveDailyState();

    await _runCollectionBackfillIfNeeded(prefs);

    notifyListeners();
  }

  Future<void> _runCollectionBackfillIfNeeded(SharedPreferences prefs) async {
    final savedVersion = prefs.getInt(collectionMigrationVersionKey) ?? 0;

    if (savedVersion >= CollectionMigrationService.currentMigrationVersion) {
      return;
    }

    final result = CollectionMigrationService.backfillCollections(
      rewardedItemIds: _rewardedBeliefIds,
      interactions: _interactions,
      existingCollections: _countryCollections,
    );

    _countryCollections
      ..clear()
      ..addAll(result.updatedCollections);

    if (result.xpAwarded > 0) {
      _xp += result.xpAwarded;
      await _saveXp();
    }

    await _saveCountryCollections();
    await prefs.setInt(
      collectionMigrationVersionKey,
      CollectionMigrationService.currentMigrationVersion,
    );
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

  Future<void> _saveDailyState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(dailyDateKey, _dailyState.dateKey);
    await prefs.setBool(
      dailyBeliefCompletedKey,
      _dailyState.dailyBeliefCompleted,
    );
    await prefs.setBool(
      dailySayingCompletedKey,
      _dailyState.dailySayingCompleted,
    );

    if (_dailyState.lastActiveDateKey != null) {
      await prefs.setString(
        lastActiveDateKey,
        _dailyState.lastActiveDateKey!,
      );
    } else {
      await prefs.remove(lastActiveDateKey);
    }

    await prefs.setInt(currentStreakKey, _dailyState.currentStreak);
  }

  Future<void> _saveInteractions() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _interactions.map((key, value) => MapEntry(key, value.toJson())),
    );
    await prefs.setString(interactionsKey, encoded);
  }

  Future<void> _saveCountryCollections() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _countryCollections.map((key, value) => MapEntry(key, value.toJson())),
    );
    await prefs.setString(countryCollectionsKey, encoded);
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

  Future<void> _registerCountryDiscovery(Belief belief) async {
    final currentCollection = getCountryCollection(belief.countryCode);

    final result = CollectionService.registerDiscovery(
      collection: currentCollection,
      item: belief,
    );

    if (!result.wasNewDiscovery) return;

    _countryCollections[belief.countryCode] = result.updatedCollection;
    await _saveCountryCollections();

    if (result.xpAwarded > 0) {
      _xp += result.xpAwarded;
      await _saveXp();
    }
  }

  Future<int> submitGuess(Belief belief, String selectedAnswer) async {
    final current = getInteraction(belief.id);

    if (current.hasGuessed) {
      return 0;
    }

    final isCorrect = selectedAnswer == belief.countryName;
    int xpAwarded = isCorrect ? 10 : 3;

    bool discoveryAwarded = false;
    if (!_rewardedBeliefIds.contains(belief.id)) {
      _rewardedBeliefIds.add(belief.id);
      await _saveRewarded();
      xpAwarded += belief.xpReward;
      discoveryAwarded = true;

      await _registerCountryDiscovery(belief);
    }

    final updated = current.copyWith(
      hasGuessed: true,
      selectedAnswer: selectedAnswer,
      isCorrect: isCorrect,
      guessRewarded: true,
      discoveryRewarded: discoveryAwarded || current.discoveryRewarded,
    );

    _interactions[belief.id] = updated;
    _xp += xpAwarded;

    await _saveInteractions();
    await _saveXp();
    notifyListeners();

    return xpAwarded;
  }

  Future<int> submitReaction(String itemId, String reactionType) async {
    final current = getInteraction(itemId);

    if (current.hasReacted) {
      return 0;
    }

    final updated = current.copyWith(
      hasReacted: true,
      reactionType: reactionType,
      reactionRewarded: true,
    );

    _interactions[itemId] = updated;
    _xp += 2;

    await _saveInteractions();
    await _saveXp();
    notifyListeners();

    return 2;
  }

  Future<bool> completeDailyBelief() async {
    _dailyState = DailyService.syncState(_dailyState);

    if (_dailyState.dailyBeliefCompleted) {
      await _saveDailyState();
      notifyListeners();
      return false;
    }

    _dailyState = DailyService.completeDailyItem(
      _dailyState,
      itemType: 'belief',
    );
    _xp += 25;

    await _saveDailyState();
    await _saveXp();
    notifyListeners();
    return true;
  }

  Future<bool> completeDailySaying() async {
    _dailyState = DailyService.syncState(_dailyState);

    if (_dailyState.dailySayingCompleted) {
      await _saveDailyState();
      notifyListeners();
      return false;
    }

    _dailyState = DailyService.completeDailyItem(
      _dailyState,
      itemType: 'saying',
    );
    _xp += 25;

    await _saveDailyState();
    await _saveXp();
    notifyListeners();
    return true;
  }
}