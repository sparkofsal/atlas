import '../data/mock_countries.dart';
import '../models/belief.dart';
import '../models/discovery_run.dart';
import 'collection_service.dart';

class RunService {
  static DiscoveryRun generateRun({
    required String todayKey,
    required int currentCombo,
    required List<CountryCollectionProgress> progressList,
    required List<String> recentRunTypes,
    required int playerLevel,
  }) {
    final candidates = <DiscoveryRun>[];

    final countryTargets = progressList.where((item) {
      final remaining = item.totalCount - item.discoveredCount;
      return item.discoveredCount > 0 &&
          item.completionPercentage < 100 &&
          remaining >= 2;
    }).toList();

    if (countryTargets.isNotEmpty) {
      countryTargets.sort((a, b) {
        final aRemaining = a.totalCount - a.discoveredCount;
        final bRemaining = b.totalCount - b.discoveredCount;
        return aRemaining.compareTo(bRemaining);
      });

      final target = countryTargets.first;
      final country = mockCountries.firstWhere(
        (item) => item.code == target.countryCode,
      );

      candidates.add(
        DiscoveryRun(
          id: 'country-$todayKey',
          runType: 'country',
          title: '${country.name} Run',
          subtitle: 'Discover 3 items from ${country.name}.',
          target: 3,
          progress: 0,
          rewardXp: 30,
          completed: false,
          rewarded: false,
          dateKey: todayKey,
          metadata: {
            'countryCode': target.countryCode,
            'startDiscovered': target.discoveredCount,
          },
        ),
      );
    }

    candidates.add(
      DiscoveryRun(
        id: 'sayings-$todayKey',
        runType: 'sayings',
        title: 'Sayings Run',
        subtitle: 'Discover 3 sayings.',
        target: 3,
        progress: 0,
        rewardXp: 28,
        completed: false,
        rewarded: false,
        dateKey: todayKey,
        metadata: {
          'startDiscoveredIds': <String>[],
        },
      ),
    );

    candidates.add(
      DiscoveryRun(
        id: 'category-$todayKey',
        runType: 'category',
        title: 'Category Run',
        subtitle: 'Discover 3 items from the same category.',
        target: 3,
        progress: 0,
        rewardXp: 32,
        completed: false,
        rewarded: false,
        dateKey: todayKey,
        metadata: {
          'categoryId': null,
          'countedItemIds': <String>[],
        },
      ),
    );

    final comboTarget = currentCombo >= 2 ? currentCombo + 2 : 3;
    candidates.add(
      DiscoveryRun(
        id: 'combo-$todayKey',
        runType: 'combo',
        title: 'Combo Run',
        subtitle: 'Reach combo x$comboTarget.',
        target: comboTarget,
        progress: currentCombo,
        rewardXp: 25,
        completed: false,
        rewarded: false,
        dateKey: todayKey,
        metadata: {},
      ),
    );

    candidates.sort((a, b) {
      final aRecent = recentRunTypes.contains(a.runType) ? 1 : 0;
      final bRecent = recentRunTypes.contains(b.runType) ? 1 : 0;
      return aRecent.compareTo(bRecent);
    });

    return candidates.first;
  }

  static DiscoveryRun updateRunForDiscovery({
    required DiscoveryRun run,
    required Belief belief,
    required int currentCombo,
    required List<CountryCollectionProgress> progressList,
    required Set<String> rewardedIds,
  }) {
    switch (run.runType) {
      case 'country':
        final countryCode = run.metadata['countryCode'] as String?;
        final start = run.metadata['startDiscovered'] as int? ?? 0;

        if (countryCode != null) {
          final match = progressList.where((p) => p.countryCode == countryCode);
          if (match.isNotEmpty) {
            final progress =
                (match.first.discoveredCount - start).clamp(0, run.target);
            return run.copyWith(
              progress: progress,
              completed: progress >= run.target,
            );
          }
        }
        return run;

      case 'sayings':
        if (belief.contentType != 'saying') return run;

        final counted =
            List<String>.from(run.metadata['startDiscoveredIds'] ?? []);
        if (!counted.contains(belief.id)) {
          counted.add(belief.id);
        }

        final progress = counted.length.clamp(0, run.target);

        return run.copyWith(
          progress: progress,
          completed: progress >= run.target,
          metadata: {
            ...run.metadata,
            'startDiscoveredIds': counted,
          },
        );

      case 'category':
        final categoryId = run.metadata['categoryId'] as String?;
        final counted = List<String>.from(run.metadata['countedItemIds'] ?? []);

        String? activeCategory = categoryId;
        if (activeCategory == null) {
          activeCategory = belief.categoryId;
        }

        if (belief.categoryId != activeCategory) {
          return run.copyWith(
            metadata: {
              ...run.metadata,
              'categoryId': activeCategory,
              'countedItemIds': counted,
            },
          );
        }

        if (!counted.contains(belief.id)) {
          counted.add(belief.id);
        }

        final progress = counted.length.clamp(0, run.target);

        return run.copyWith(
          progress: progress,
          completed: progress >= run.target,
          metadata: {
            ...run.metadata,
            'categoryId': activeCategory,
            'countedItemIds': counted,
          },
        );

      case 'combo':
        final progress = currentCombo.clamp(0, run.target);
        return run.copyWith(
          progress: progress,
          completed: progress >= run.target,
        );

      default:
        return run;
    }
  }

  static DiscoveryRun updateRunForCombo({
    required DiscoveryRun run,
    required int currentCombo,
  }) {
    if (run.runType != 'combo') return run;

    final progress = currentCombo.clamp(0, run.target);
    return run.copyWith(
      progress: progress,
      completed: progress >= run.target,
    );
  }
}