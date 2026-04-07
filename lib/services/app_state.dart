import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/mock_countries.dart';
import '../models/belief.dart';
import '../models/country_collection.dart';
import '../models/daily_state.dart';
import '../models/item_interaction.dart';
import '../models/level_up_event.dart';
import '../models/player_identity.dart';
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

  static const String usernameKey = 'player_username';
  static const String avatarIdKey = 'player_avatar_id';
  static const String profileSetupCompletedKey = 'profile_setup_completed';

  final Set<String> _favoriteBeliefIds = {};
  final Set<String> _rewardedBeliefIds = {};
  final Map<String, ItemInteraction> _interactions = {};
  final Map<String, CountryCollection> _countryCollections = {};

  int _xp = 0;
  late DailyState _dailyState;
  PlayerIdentity _playerIdentity = PlayerIdentity.initial();

  LevelUpEvent? _pendingLevelUpEvent;

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

  PlayerIdentity get playerIdentity => _playerIdentity;
  String get username => _playerIdentity.username;
  String get avatarId => _playerIdentity.avatarId;
  bool get hasCompletedProfileSetup => _playerIdentity.hasCompletedProfileSetup;

  LevelUpEvent? get pendingLevelUpEvent => _pendingLevelUpEvent;

  int get favoritesCount => _favoriteBeliefIds.length;
  int get totalDiscoveries => _rewardedBeliefIds.length;
  int get countriesExplored =>
      getCountryProgressList().where((item) => item.discoveredCount > 0).length;

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

  static bool isValidUsername(String value) {
    final trimmed = value.trim();
    final regex = RegExp(r'^[A-Za-z0-9_]{3,16}$');
    return regex.hasMatch(trimmed);
  }

  static int xpThresholdForLevel(int level) {
    if (level <= 1) return 0;

    switch (level) {
      case 2:
        return 50;
      case 3:
        return 120;
      case 4:
        return 220;
      case 5:
        return 350;
      default:
        final n = level - 5;
        return 350 + (n * 180) + (((n - 1) * n * 25) ~/ 2);
    }
  }

  int get level {
    int currentLevel = 1;
    while (_xp >= xpThresholdForLevel(currentLevel + 1)) {
      currentLevel++;
    }
    return currentLevel;
  }

  int get nextLevelXp => xpThresholdForLevel(level + 1);

  int get xpToNextLevel {
    return nextLevelXp - _xp;
  }

  double get levelProgress {
    final currentLevelXp = xpThresholdForLevel(level);
    final nextLevelTarget = xpThresholdForLevel(level + 1);
    final span = nextLevelTarget - currentLevelXp;

    if (span <= 0) return 1.0;
    return (_xp - currentLevelXp) / span;
  }

  String titleForLevel(int currentLevel) {
    if (currentLevel >= 50) return 'Atlas Master';
    if (currentLevel >= 30) return 'Reality Challenger';
    if (currentLevel >= 20) return 'Atlas Scholar';
    if (currentLevel >= 15) return 'Mind Voyager';
    if (currentLevel >= 10) return 'World Thinker';
    if (currentLevel >= 8) return 'Knowledge Hunter';
    if (currentLevel >= 5) return 'Cultural Seeker';
    if (currentLevel >= 3) return 'Belief Explorer';
    return 'Curious Mind';
  }

  String get currentTitle => titleForLevel(level);

  void clearPendingLevelUpEvent() {
    _pendingLevelUpEvent = null;
    notifyListeners();
  }

  void _setLevelUpEventIfNeeded(int oldLevel, int newLevel) {
    if (newLevel <= oldLevel) return;

    final oldTitle = titleForLevel(oldLevel);
    final newTitle = titleForLevel(newLevel);

    _pendingLevelUpEvent = LevelUpEvent(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      oldLevel: oldLevel,
      newLevel: newLevel,
      oldTitle: oldTitle,
      newTitle: newTitle,
    );
  }

  Future<void> updatePlayerProfile({
    required String username,
    required String avatarId,
  }) async {
    final trimmed = username.trim();

    if (!isValidUsername(trimmed)) {
      return;
    }

    _playerIdentity = _playerIdentity.copyWith(
      username: trimmed,
      avatarId: avatarId,
      hasCompletedProfileSetup: true,
    );

    await _savePlayerIdentity();
    notifyListeners();
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

    _playerIdentity = PlayerIdentity(
      username: prefs.getString(usernameKey) ?? '',
      avatarId: prefs.getString(avatarIdKey) ?? 'owl',
      hasCompletedProfileSetup:
          prefs.getBool(profileSetupCompletedKey) ?? false,
    );

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

  Future<void> _savePlayerIdentity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(usernameKey, _playerIdentity.username);
    await prefs.setString(avatarIdKey, _playerIdentity.avatarId);
    await prefs.setBool(
      profileSetupCompletedKey,
      _playerIdentity.hasCompletedProfileSetup,
    );
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
    final oldLevel = level;
    _xp += amount;
    await _saveXp();
    _setLevelUpEventIfNeeded(oldLevel, level);
    notifyListeners();
  }

  Future<bool> rewardIfFirstTime(String beliefId, int xpAmount) async {
    if (_rewardedBeliefIds.contains(beliefId)) {
      return false;
    }

    final oldLevel = level;

    _rewardedBeliefIds.add(beliefId);
    await _saveRewarded();

    _xp += xpAmount;
    await _saveXp();

    _setLevelUpEventIfNeeded(oldLevel, level);
    notifyListeners();
    return true;
  }

  Future<int> _registerCountryDiscovery(Belief belief) async {
    final currentCollection = getCountryCollection(belief.countryCode);

    final result = CollectionService.registerDiscovery(
      collection: currentCollection,
      item: belief,
    );

    if (!result.wasNewDiscovery) return 0;

    _countryCollections[belief.countryCode] = result.updatedCollection;
    await _saveCountryCollections();

    return result.xpAwarded;
  }

  Future<int> submitGuess(Belief belief, String selectedAnswer) async {
    final current = getInteraction(belief.id);

    if (current.hasGuessed) {
      return 0;
    }

    final oldLevel = level;
    final isCorrect = selectedAnswer == belief.countryName;
    int xpAwarded = isCorrect ? 10 : 3;

    bool discoveryAwarded = false;
    if (!_rewardedBeliefIds.contains(belief.id)) {
      _rewardedBeliefIds.add(belief.id);
      await _saveRewarded();
      xpAwarded += belief.xpReward;
      discoveryAwarded = true;

      final milestoneXp = await _registerCountryDiscovery(belief);
      xpAwarded += milestoneXp;
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

    _setLevelUpEventIfNeeded(oldLevel, level);
    notifyListeners();

    return xpAwarded;
  }

  Future<int> submitReaction(String itemId, String reactionType) async {
    final current = getInteraction(itemId);

    if (current.hasReacted) {
      return 0;
    }

    final oldLevel = level;

    final updated = current.copyWith(
      hasReacted: true,
      reactionType: reactionType,
      reactionRewarded: true,
    );

    _interactions[itemId] = updated;
    _xp += 2;

    await _saveInteractions();
    await _saveXp();

    _setLevelUpEventIfNeeded(oldLevel, level);
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

    final oldLevel = level;

    _dailyState = DailyService.completeDailyItem(
      _dailyState,
      itemType: 'belief',
    );
    _xp += 25;

    await _saveDailyState();
    await _saveXp();

    _setLevelUpEventIfNeeded(oldLevel, level);
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

    final oldLevel = level;

    _dailyState = DailyService.completeDailyItem(
      _dailyState,
      itemType: 'saying',
    );
    _xp += 25;

    await _saveDailyState();
    await _saveXp();

    _setLevelUpEventIfNeeded(oldLevel, level);
    notifyListeners();
    return true;
  }
}