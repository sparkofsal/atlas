import '../data/mock_beliefs.dart';
import '../models/belief.dart';
import '../models/country_collection.dart';

class CountryCollectionProgress {
  final String countryCode;
  final int discoveredCount;
  final int totalCount;
  final double completionPercentage;
  final List<String> milestonesUnlocked;

  const CountryCollectionProgress({
    required this.countryCode,
    required this.discoveredCount,
    required this.totalCount,
    required this.completionPercentage,
    required this.milestonesUnlocked,
  });
}

class CollectionUpdateResult {
  final CountryCollection updatedCollection;
  final bool wasNewDiscovery;
  final int xpAwarded;
  final List<String> newlyUnlockedMilestones;

  const CollectionUpdateResult({
    required this.updatedCollection,
    required this.wasNewDiscovery,
    required this.xpAwarded,
    required this.newlyUnlockedMilestones,
  });
}

class CollectionService {
  static const Map<String, int> milestoneXpRewards = {
    '25': 15,
    '50': 30,
    '100': 75,
  };

  static int totalCountForCountry(String countryCode) {
    return mockBeliefs.where((item) => item.countryCode == countryCode).length;
  }

  static double completionPercentage({
    required int discoveredCount,
    required int totalCount,
  }) {
    if (totalCount == 0) return 0;
    return (discoveredCount / totalCount) * 100;
  }

  static CountryCollectionProgress buildProgress(CountryCollection collection) {
    final totalCount = totalCountForCountry(collection.countryCode);
    final discoveredCount = collection.discoveredItemIds.length;

    return CountryCollectionProgress(
      countryCode: collection.countryCode,
      discoveredCount: discoveredCount,
      totalCount: totalCount,
      completionPercentage: completionPercentage(
        discoveredCount: discoveredCount,
        totalCount: totalCount,
      ),
      milestonesUnlocked: collection.milestonesUnlocked,
    );
  }

  static CollectionUpdateResult registerDiscovery({
    required CountryCollection collection,
    required Belief item,
  }) {
    if (collection.discoveredItemIds.contains(item.id)) {
      return CollectionUpdateResult(
        updatedCollection: collection,
        wasNewDiscovery: false,
        xpAwarded: 0,
        newlyUnlockedMilestones: const [],
      );
    }

    final updatedItemIds = [...collection.discoveredItemIds, item.id];
    final updatedMilestones = [...collection.milestonesUnlocked];

    final updatedCollection = collection.copyWith(
      discoveredItemIds: updatedItemIds,
    );

    final progress = buildProgress(updatedCollection);

    int xpAwarded = 0;
    final newlyUnlockedMilestones = <String>[];

    for (final milestone in ['25', '50', '100']) {
      final threshold = double.parse(milestone);

      if (progress.completionPercentage >= threshold &&
          !updatedMilestones.contains(milestone)) {
        updatedMilestones.add(milestone);
        newlyUnlockedMilestones.add(milestone);
        xpAwarded += milestoneXpRewards[milestone] ?? 0;
      }
    }

    return CollectionUpdateResult(
      updatedCollection: updatedCollection.copyWith(
        milestonesUnlocked: updatedMilestones,
      ),
      wasNewDiscovery: true,
      xpAwarded: xpAwarded,
      newlyUnlockedMilestones: newlyUnlockedMilestones,
    );
  }
}