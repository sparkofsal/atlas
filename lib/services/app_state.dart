import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/mock_countries.dart';
import '../data/mock_beliefs.dart';
import '../models/belief.dart';
import '../models/country_collection.dart';
import '../models/daily_state.dart';
import '../models/discovery_run.dart';
import '../models/goal_reward_event.dart';
import '../models/guess_result.dart';
import '../models/item_interaction.dart';
import '../models/level_up_event.dart';
import '../models/play_style.dart';
import '../models/player_identity.dart';
import '../models/progression_unlock_event.dart';
import '../models/run_reward_event.dart';
import '../models/session_goal.dart';
import 'collection_migration_service.dart';
import 'collection_service.dart';
import 'daily_service.dart';
import 'goal_service.dart';
import 'interaction_service.dart';
import 'progression_service.dart';
import 'run_service.dart';

class AppState extends ChangeNotifier {
  static const String favoritesKey = 'favorites';
  static const String xpKey = 'xp';
  static const String rewardedKey = 'rewarded';

  static const String dailyDateKey = 'daily_date';
  static const String dailyBeliefCompletedKey = 'daily_belief_completed';
  static const String dailySayingCompletedKey = 'daily_saying_completed';
  static const String lastActiveDateKey = 'last_active_date';
  static const String currentStreakKey = 'current_streak';
  static const String bestStreakKey = 'best_streak';

  static const String interactionsKey = 'item_interactions';
  static const String countryCollectionsKey = 'country_collections';
  static const String collectionMigrationVersionKey =
      'collection_migration_version';

  static const String usernameKey = 'player_username';
  static const String avatarIdKey = 'player_avatar_id';
  static const String profileSetupCompletedKey = 'profile_setup_completed';

  static const String currentComboKey = 'current_combo';
  static const String bestComboKey = 'best_combo';
  static const String lastGuessCorrectKey = 'last_guess_correct';

  static const String lastPlayStyleKey = 'last_play_style';
  static const String lastSelectedCountryKey = 'last_selected_country';

  static const String sessionGoalsKey = 'session_goals';
  static const String sessionGoalsDateKey = 'session_goals_date';
  static const String recentGoalTemplatesKey = 'recent_goal_templates';

  static const String activeRunKey = 'active_run';
  static const String activeRunDateKey = 'active_run_date';
  static const String recentRunTypesKey = 'recent_run_types';

  final Set<String> _favoriteBeliefIds = {};
  final Set<String> _rewardedBeliefIds = {};
  final Map<String, ItemInteraction> _interactions = {};
  final Map<String, CountryCollection> _countryCollections = {};

  List<SessionGoal> _activeGoals = [];
  List<String> _recentGoalTemplateIds = [];
  String _goalsDateKey = '';

  DiscoveryRun? _activeRun;
  List<String> _recentRunTypes = [];
  String _runDateKey = '';

  int _xp = 0;
  int _currentCombo = 0;
  int _bestCombo = 0;
  bool _lastGuessCorrect = false;

  String _lastSelectedPlayStyleId = PlayStyle.exploreFreely.id;
  String? _lastSelectedCountryCode;

  late DailyState _dailyState;
  PlayerIdentity _playerIdentity = PlayerIdentity.initial();

  LevelUpEvent? _pendingLevelUpEvent;
  GoalRewardEvent? _pendingGoalRewardEvent;
  RunRewardEvent? _pendingRunRewardEvent;
  ProgressionUnlockEvent? _pendingProgressionUnlockEvent;

  AppState() {
    _dailyState = DailyState.initial(DailyService.todayKey());
  }

  Set<String> get favoriteBeliefIds => _favoriteBeliefIds;
  Set<String> get rewardedBeliefIds => _rewardedBeliefIds;
  int get xp => _xp;

  int get currentCombo => _currentCombo;
  int get bestCombo => _bestCombo;
  bool get lastGuessCorrect => _lastGuessCorrect;

  DailyState get dailyState => _dailyState;
  bool get dailyBeliefCompleted => _dailyState.dailyBeliefCompleted;
  bool get dailySayingCompleted => _dailyState.dailySayingCompleted;
  int get currentStreak => _dailyState.currentStreak;
  int get bestStreak => _dailyState.bestStreak;

  PlayerIdentity get playerIdentity => _playerIdentity;
  String get username => _playerIdentity.username;
  String get avatarId => _playerIdentity.avatarId;
  bool get hasCompletedProfileSetup => _playerIdentity.hasCompletedProfileSetup;

  LevelUpEvent? get pendingLevelUpEvent => _pendingLevelUpEvent;
  GoalRewardEvent? get pendingGoalRewardEvent => _pendingGoalRewardEvent;
  RunRewardEvent? get pendingRunRewardEvent => _pendingRunRewardEvent;
  ProgressionUnlockEvent? get pendingProgressionUnlockEvent =>
      _pendingProgressionUnlockEvent;

  List<SessionGoal> get activeGoals => _activeGoals;
  DiscoveryRun? get activeRun => _activeRun;

  PlayStyle get activePlayStyle => PlayStyleX.fromId(_lastSelectedPlayStyleId);
  String? get lastSelectedCountryCode => _lastSelectedCountryCode;

  int get favoritesCount => _favoriteBeliefIds.length;
  int get totalDiscoveries => _rewardedBeliefIds.length;
  int get countriesExplored =>
      getCountryProgressList().where((item) => item.discoveredCount > 0).length;

  int get dailyCompletedCount =>
      (dailyBeliefCompleted ? 1 : 0) + (dailySayingCompleted ? 1 : 0);

  String get nextComboGoalHint {
    if (_currentCombo == 0) {
      return 'Start a combo with a correct guess';
    }
    if (_currentCombo < 5) {
      return '${5 - _currentCombo} more correct for combo x5';
    }
    return 'Combo x$_currentCombo is active';
  }

  String? get nearCountryGoalHint {
    final progressList = getCountryProgressList()
        .where(
          (item) =>
              item.discoveredCount > 0 &&
              item.discoveredCount < item.totalCount,
        )
        .toList();

    if (progressList.isEmpty) return null;

    progressList.sort((a, b) {
      final remainingA = a.totalCount - a.discoveredCount;
      final remainingB = b.totalCount - b.discoveredCount;
      return remainingA.compareTo(remainingB);
    });

    final target = progressList.first;
    final remaining = target.totalCount - target.discoveredCount;

    if (remaining <= 2) {
      final country = mockCountries.firstWhere(
        (item) => item.code == target.countryCode,
      );
      return 'Only $remaining more item${remaining == 1 ? '' : 's'} to complete ${country.name}';
    }

    return null;
  }

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

  Future<void> setPlayStyle(PlayStyle style, {String? countryCode}) async {
    _lastSelectedPlayStyleId = style.id;
    if (countryCode != null) {
      _lastSelectedCountryCode = countryCode;
    }
    await _saveExplorationState();
    notifyListeners();
  }

  Future<void> setSelectedCountryCode(String? countryCode) async {
    _lastSelectedCountryCode = countryCode;
    await _saveExplorationState();
    notifyListeners();
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

  void clearPendingGoalRewardEvent() {
    _pendingGoalRewardEvent = null;
    notifyListeners();
  }

  void clearPendingRunRewardEvent() {
    _pendingRunRewardEvent = null;
    notifyListeners();
  }

  void clearPendingProgressionUnlockEvent() {
    _pendingProgressionUnlockEvent = null;
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

  void _setProgressionUnlockEventIfNeeded(int oldLevel, int newLevel) {
    final message = ProgressionService.unlockMessageForLevelCrossed(
      oldLevel: oldLevel,
      newLevel: newLevel,
    );

    if (message == null) return;

    _pendingProgressionUnlockEvent = ProgressionUnlockEvent(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      message: message,
    );
  }

  void _rememberGoalTemplate(String templateId) {
    _recentGoalTemplateIds.add(templateId);
    if (_recentGoalTemplateIds.length > 8) {
      _recentGoalTemplateIds =
          _recentGoalTemplateIds.sublist(_recentGoalTemplateIds.length - 8);
    }
  }

  void _rememberRunType(String runType) {
    _recentRunTypes.add(runType);
    if (_recentRunTypes.length > 6) {
      _recentRunTypes = _recentRunTypes.sublist(_recentRunTypes.length - 6);
    }
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

  Future<void> _ensureGoalsCurrent() async {
    final today = DailyService.todayKey();

    if (_goalsDateKey != today || _activeGoals.length < 2) {
      _goalsDateKey = today;
      _activeGoals = GoalService.generateGoals(
        todayKey: today,
        xp: _xp,
        xpToNextLevel: xpToNextLevel,
        currentCombo: _currentCombo,
        totalDiscoveries: totalDiscoveries,
        countriesExplored: countriesExplored,
        dailyCompletedCount: dailyCompletedCount,
        progressList: getCountryProgressList(),
        recentTemplateIds: _recentGoalTemplateIds,
      );
      await _saveGoals();
      return;
    }

    _activeGoals = _activeGoals
        .map(
          (goal) => GoalService.updateProgress(
            goal: goal,
            xp: _xp,
            currentCombo: _currentCombo,
            totalDiscoveries: totalDiscoveries,
            countriesExplored: countriesExplored,
            dailyCompletedCount: dailyCompletedCount,
            progressList: getCountryProgressList(),
          ),
        )
        .toList();
    await _saveGoals();
  }

  Future<void> _ensureRunCurrent() async {
    final today = DailyService.todayKey();

    if (_runDateKey != today || _activeRun == null) {
      _runDateKey = today;
      _activeRun = RunService.generateRun(
        todayKey: today,
        currentCombo: _currentCombo,
        progressList: getCountryProgressList(),
        recentRunTypes: _recentRunTypes,
        playerLevel: level,
      );
      await _saveRun();
    }
  }

  Future<void> _refreshGoalsAndRewards() async {
    await _ensureGoalsCurrent();

    int bonusXp = 0;
    final updatedGoals = <SessionGoal>[];
    final completedMessages = <String>[];

    for (final goal in _activeGoals) {
      final updated = GoalService.updateProgress(
        goal: goal,
        xp: _xp,
        currentCombo: _currentCombo,
        totalDiscoveries: totalDiscoveries,
        countriesExplored: countriesExplored,
        dailyCompletedCount: dailyCompletedCount,
        progressList: getCountryProgressList(),
      );

      if (updated.completed && !updated.rewarded) {
        final rewardedGoal = updated.copyWith(rewarded: true);
        updatedGoals.add(rewardedGoal);
        bonusXp += rewardedGoal.rewardXp;
        _rememberGoalTemplate(rewardedGoal.templateId);
        completedMessages.add(
          'Goal complete: ${rewardedGoal.title} • +${rewardedGoal.rewardXp} XP',
        );
      } else {
        updatedGoals.add(updated);
      }
    }

    _activeGoals = updatedGoals;

    if (bonusXp > 0) {
      _xp += bonusXp;
      _pendingGoalRewardEvent = GoalRewardEvent(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        message: completedMessages.first,
      );
      await _saveXp();
    }

    await _saveGoals();
  }

  Future<void> _refreshRunProgress({Belief? discoveredBelief}) async {
    await _ensureRunCurrent();
    if (_activeRun == null) return;

    DiscoveryRun updatedRun = _activeRun!;

    if (discoveredBelief != null) {
      updatedRun = RunService.updateRunForDiscovery(
        run: updatedRun,
        belief: discoveredBelief,
        currentCombo: _currentCombo,
        progressList: getCountryProgressList(),
        rewardedIds: _rewardedBeliefIds,
      );
    }

    updatedRun = RunService.updateRunForCombo(
      run: updatedRun,
      currentCombo: _currentCombo,
    );

    if (updatedRun.completed && !updatedRun.rewarded) {
      final oldLevel = level;
      final rewardedRun = updatedRun.copyWith(rewarded: true);
      _activeRun = rewardedRun;
      _xp += rewardedRun.rewardXp;
      _rememberRunType(rewardedRun.runType);

      _pendingRunRewardEvent = RunRewardEvent(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        message:
            'Run complete: ${rewardedRun.title} • +${rewardedRun.rewardXp} XP',
      );

      await _saveRun();
      await _saveXp();
      _setLevelUpEventIfNeeded(oldLevel, level);
      _setProgressionUnlockEventIfNeeded(oldLevel, level);
      return;
    }

    _activeRun = updatedRun;
    await _saveRun();
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
    _currentCombo = prefs.getInt(currentComboKey) ?? 0;
    _bestCombo = prefs.getInt(bestComboKey) ?? 0;
    _lastGuessCorrect = prefs.getBool(lastGuessCorrectKey) ?? false;

    _lastSelectedPlayStyleId =
        prefs.getString(lastPlayStyleKey) ?? PlayStyle.exploreFreely.id;
    _lastSelectedCountryCode = prefs.getString(lastSelectedCountryKey);

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
      bestStreak: prefs.getInt(bestStreakKey) ?? 0,
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

    final savedGoalsRaw = prefs.getString(sessionGoalsKey);
    _activeGoals = [];
    if (savedGoalsRaw != null && savedGoalsRaw.isNotEmpty) {
      final decoded = jsonDecode(savedGoalsRaw) as List<dynamic>;
      _activeGoals = decoded
          .map((item) => SessionGoal.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    _goalsDateKey = prefs.getString(sessionGoalsDateKey) ?? '';
    _recentGoalTemplateIds =
        prefs.getStringList(recentGoalTemplatesKey) ?? [];

    final savedRunRaw = prefs.getString(activeRunKey);
    _activeRun = null;
    if (savedRunRaw != null && savedRunRaw.isNotEmpty) {
      _activeRun = DiscoveryRun.fromJson(
        Map<String, dynamic>.from(jsonDecode(savedRunRaw)),
      );
    }
    _runDateKey = prefs.getString(activeRunDateKey) ?? '';
    _recentRunTypes = prefs.getStringList(recentRunTypesKey) ?? [];

    _dailyState = DailyService.syncState(_dailyState);
    await _saveDailyState();
    await _runCollectionBackfillIfNeeded(prefs);
    await _ensureGoalsCurrent();
    await _ensureRunCurrent();

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
    await prefs.setInt(bestStreakKey, _dailyState.bestStreak);
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

  Future<void> _saveChallengeState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(currentComboKey, _currentCombo);
    await prefs.setInt(bestComboKey, _bestCombo);
    await prefs.setBool(lastGuessCorrectKey, _lastGuessCorrect);
  }

  Future<void> _saveExplorationState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(lastPlayStyleKey, _lastSelectedPlayStyleId);
    if (_lastSelectedCountryCode != null) {
      await prefs.setString(lastSelectedCountryKey, _lastSelectedCountryCode!);
    } else {
      await prefs.remove(lastSelectedCountryKey);
    }
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_activeGoals.map((g) => g.toJson()).toList());
    await prefs.setString(sessionGoalsKey, encoded);
    await prefs.setString(sessionGoalsDateKey, _goalsDateKey);
    await prefs.setStringList(recentGoalTemplatesKey, _recentGoalTemplateIds);
  }

  Future<void> _saveRun() async {
    final prefs = await SharedPreferences.getInstance();
    if (_activeRun != null) {
      await prefs.setString(activeRunKey, jsonEncode(_activeRun!.toJson()));
    } else {
      await prefs.remove(activeRunKey);
    }
    await prefs.setString(activeRunDateKey, _runDateKey);
    await prefs.setStringList(recentRunTypesKey, _recentRunTypes);
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
    await _refreshGoalsAndRewards();
    await _refreshRunProgress();
    await _saveXp();
    _setLevelUpEventIfNeeded(oldLevel, level);
    _setProgressionUnlockEventIfNeeded(oldLevel, level);
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
    await _refreshGoalsAndRewards();
    await _refreshRunProgress();
    await _saveXp();

    _setLevelUpEventIfNeeded(oldLevel, level);
    _setProgressionUnlockEventIfNeeded(oldLevel, level);
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

  Future<GuessResult> submitGuess(Belief belief, String selectedAnswer) async {
    final current = getInteraction(belief.id);

    if (current.hasGuessed) {
      return GuessResult.empty();
    }

    final oldLevel = level;
    final prompt = InteractionService.buildPrompt(belief);
    final isCorrect = selectedAnswer == prompt.correctAnswer;

    final comboBefore = _currentCombo;
    int comboAfter = 0;
    bool comboBroken = false;

    int baseXp = isCorrect ? 10 : 3;
    int comboBonusXp = 0;
    int discoveryXp = 0;
    int milestoneXp = 0;
    int surpriseXp = 0;
    String? surpriseMessage;

    if (isCorrect) {
      _currentCombo += 1;
      comboAfter = _currentCombo;
      if (_currentCombo > _bestCombo) {
        _bestCombo = _currentCombo;
      }
      comboBonusXp = ProgressionService.comboBonusForLevel(
        combo: _currentCombo,
        level: level,
      );
    } else {
      comboBroken = _currentCombo > 0;
      _currentCombo = 0;
      comboAfter = 0;
    }

    bool discoveryAwarded = false;
    if (!_rewardedBeliefIds.contains(belief.id)) {
      _rewardedBeliefIds.add(belief.id);
      await _saveRewarded();

      discoveryXp = belief.xpReward;
      discoveryAwarded = true;

      final milestoneXpResult = await _registerCountryDiscovery(belief);
      milestoneXp += milestoneXpResult;
    }

    surpriseXp =
        InteractionService.surpriseBonus(belief, _currentCombo, isCorrect);
    surpriseMessage =
        InteractionService.surpriseMessage(belief, _currentCombo, isCorrect);

    final updated = current.copyWith(
      hasGuessed: true,
      selectedAnswer: selectedAnswer,
      isCorrect: isCorrect,
      guessRewarded: true,
      discoveryRewarded: discoveryAwarded || current.discoveryRewarded,
    );

    _interactions[belief.id] = updated;
    _lastGuessCorrect = isCorrect;

    final totalXp =
        baseXp + comboBonusXp + discoveryXp + milestoneXp + surpriseXp;

    _xp += totalXp;

    await _saveInteractions();
    await _saveXp();
    await _saveChallengeState();
    await _refreshGoalsAndRewards();
    if (discoveryAwarded) {
      await _refreshRunProgress(discoveredBelief: belief);
    } else {
      await _refreshRunProgress();
    }

    _setLevelUpEventIfNeeded(oldLevel, level);
    _setProgressionUnlockEventIfNeeded(oldLevel, level);
    notifyListeners();

    return GuessResult(
      alreadyGuessed: false,
      isCorrect: isCorrect,
      totalXp: totalXp,
      baseXp: baseXp,
      comboBonusXp: comboBonusXp,
      discoveryXp: discoveryXp,
      milestoneXp: milestoneXp,
      surpriseXp: surpriseXp,
      comboBefore: comboBefore,
      comboAfter: comboAfter,
      comboBroken: comboBroken,
      surpriseMessage: surpriseMessage,
    );
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
    await _refreshGoalsAndRewards();
    await _refreshRunProgress();

    _setLevelUpEventIfNeeded(oldLevel, level);
    _setProgressionUnlockEventIfNeeded(oldLevel, level);
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
    await _refreshGoalsAndRewards();
    await _refreshRunProgress();

    _setLevelUpEventIfNeeded(oldLevel, level);
    _setProgressionUnlockEventIfNeeded(oldLevel, level);
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
    await _refreshGoalsAndRewards();
    await _refreshRunProgress();

    _setLevelUpEventIfNeeded(oldLevel, level);
    _setProgressionUnlockEventIfNeeded(oldLevel, level);
    notifyListeners();
    return true;
  }
}