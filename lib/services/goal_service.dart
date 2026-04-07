import '../data/mock_countries.dart';
import '../models/session_goal.dart';
import 'collection_service.dart';

class GoalService {
  static const int goalSlots = 3;

  static String _goalId(String templateId, String dateKey, int index) {
    return '$templateId-$dateKey-$index';
  }

  static SessionGoal _buildGoal({
    required String templateId,
    required String title,
    required String subtitle,
    required int target,
    required int rewardXp,
    required String dateKey,
    required Map<String, dynamic> metadata,
    int progress = 0,
  }) {
    return SessionGoal(
      id: _goalId(templateId, dateKey, metadata.hashCode.abs()),
      templateId: templateId,
      title: title,
      subtitle: subtitle,
      target: target,
      rewardXp: rewardXp,
      progress: progress,
      completed: progress >= target,
      rewarded: false,
      dateKey: dateKey,
      metadata: metadata,
    );
  }

  static List<SessionGoal> generateGoals({
    required String todayKey,
    required int xp,
    required int xpToNextLevel,
    required int currentCombo,
    required int totalDiscoveries,
    required int countriesExplored,
    required int dailyCompletedCount,
    required List<CountryCollectionProgress> progressList,
    required List<String> recentTemplateIds,
  }) {
    final goals = <SessionGoal>[];
    final usedTemplates = <String>{};

    SessionGoal? nearLevelGoal;
    if (xpToNextLevel <= 20) {
      nearLevelGoal = _buildGoal(
        templateId: 'earn_xp',
        title: 'Earn $xpToNextLevel XP to level up',
        subtitle: 'You are very close to your next level.',
        target: xpToNextLevel,
        rewardXp: 20,
        dateKey: todayKey,
        metadata: {
          'startXp': xp,
        },
      );
    }

    SessionGoal? nearCountryGoal;
    final nearCountry = progressList.where((item) {
      final remaining = item.totalCount - item.discoveredCount;
      return item.discoveredCount > 0 &&
          item.completionPercentage < 100 &&
          remaining > 0 &&
          remaining <= 2;
    }).toList();

    if (nearCountry.isNotEmpty) {
      nearCountry.sort((a, b) {
        final aRemaining = a.totalCount - a.discoveredCount;
        final bRemaining = b.totalCount - b.discoveredCount;
        return aRemaining.compareTo(bRemaining);
      });

      final targetCountry = nearCountry.first;
      final country = mockCountries.firstWhere(
        (item) => item.code == targetCountry.countryCode,
      );
      final remaining = targetCountry.totalCount - targetCountry.discoveredCount;

      nearCountryGoal = _buildGoal(
        templateId: 'finish_country',
        title: 'Find $remaining more in ${country.name}',
        subtitle: 'You are close to completing this country.',
        target: remaining,
        rewardXp: 25,
        dateKey: todayKey,
        metadata: {
          'countryCode': targetCountry.countryCode,
          'startDiscovered': targetCountry.discoveredCount,
        },
      );
    }

    SessionGoal? comboGoal;
    if (currentCombo >= 1 && currentCombo < 4) {
      final targetCombo = currentCombo + 1;
      comboGoal = _buildGoal(
        templateId: 'correct_combo',
        title: 'Reach combo x$targetCombo',
        subtitle: 'Keep your streak of correct guesses alive.',
        target: targetCombo,
        rewardXp: 18,
        dateKey: todayKey,
        metadata: {},
        progress: currentCombo,
      );
    }

    SessionGoal? dailyGoal;
    if (dailyCompletedCount == 0) {
      dailyGoal = _buildGoal(
        templateId: 'complete_daily',
        title: 'Complete 1 daily item',
        subtitle: 'Daily content keeps your streak healthy.',
        target: 1,
        rewardXp: 15,
        dateKey: todayKey,
        metadata: {},
        progress: dailyCompletedCount,
      );
    }

    final contextual = [
      nearLevelGoal,
      nearCountryGoal,
      comboGoal,
      dailyGoal,
    ].whereType<SessionGoal>().toList();

    for (final goal in contextual) {
      if (goals.length >= goalSlots) break;
      if (usedTemplates.contains(goal.templateId)) continue;
      goals.add(goal);
      usedTemplates.add(goal.templateId);
    }

    final genericCandidates = <SessionGoal>[
      _buildGoal(
        templateId: 'discover_items',
        title: 'Discover 3 new items',
        subtitle: 'Expand your knowledge collection.',
        target: 3,
        rewardXp: 20,
        dateKey: todayKey,
        metadata: {
          'startDiscoveries': totalDiscoveries,
        },
      ),
      _buildGoal(
        templateId: 'discover_new_country',
        title: 'Discover 1 item from a new country',
        subtitle: 'Push into unfamiliar territory.',
        target: 1,
        rewardXp: 25,
        dateKey: todayKey,
        metadata: {
          'startCountriesExplored': countriesExplored,
        },
      ),
      _buildGoal(
        templateId: 'correct_combo',
        title: 'Get 2 correct guesses in a row',
        subtitle: 'Build momentum with a small combo.',
        target: 2,
        rewardXp: 18,
        dateKey: todayKey,
        metadata: {},
        progress: currentCombo,
      ),
      _buildGoal(
        templateId: 'complete_daily',
        title: 'Complete 1 daily item',
        subtitle: 'Stay consistent and keep moving.',
        target: 1,
        rewardXp: 15,
        dateKey: todayKey,
        metadata: {},
        progress: dailyCompletedCount,
      ),
    ];

    final sortedGeneric = [...genericCandidates];
    sortedGeneric.sort((a, b) {
      final aRecent = recentTemplateIds.contains(a.templateId) ? 1 : 0;
      final bRecent = recentTemplateIds.contains(b.templateId) ? 1 : 0;
      return aRecent.compareTo(bRecent);
    });

    for (final goal in sortedGeneric) {
      if (goals.length >= goalSlots) break;
      if (usedTemplates.contains(goal.templateId)) continue;
      goals.add(goal);
      usedTemplates.add(goal.templateId);
    }

    return goals.take(goalSlots).toList();
  }

  static SessionGoal updateProgress({
    required SessionGoal goal,
    required int xp,
    required int currentCombo,
    required int totalDiscoveries,
    required int countriesExplored,
    required int dailyCompletedCount,
    required List<CountryCollectionProgress> progressList,
  }) {
    int progress = goal.progress;

    switch (goal.templateId) {
      case 'discover_items':
        final start = goal.metadata['startDiscoveries'] as int? ?? totalDiscoveries;
        progress = (totalDiscoveries - start).clamp(0, goal.target);
        break;

      case 'correct_combo':
        progress = currentCombo.clamp(0, goal.target);
        break;

      case 'complete_daily':
        progress = dailyCompletedCount.clamp(0, goal.target);
        break;

      case 'discover_new_country':
        final start =
            goal.metadata['startCountriesExplored'] as int? ?? countriesExplored;
        progress = (countriesExplored - start).clamp(0, goal.target);
        break;

      case 'earn_xp':
        final startXp = goal.metadata['startXp'] as int? ?? xp;
        progress = (xp - startXp).clamp(0, goal.target);
        break;

      case 'finish_country':
        final countryCode = goal.metadata['countryCode'] as String?;
        final startDiscovered =
            goal.metadata['startDiscovered'] as int? ?? 0;

        if (countryCode != null) {
          final countryProgress = progressList.where(
            (item) => item.countryCode == countryCode,
          );
          if (countryProgress.isNotEmpty) {
            progress = (countryProgress.first.discoveredCount - startDiscovered)
                .clamp(0, goal.target);
          }
        }
        break;
    }

    return goal.copyWith(
      progress: progress,
      completed: progress >= goal.target,
    );
  }
}