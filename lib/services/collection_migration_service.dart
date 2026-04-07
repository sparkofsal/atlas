import '../data/mock_beliefs.dart';
import '../models/country_collection.dart';
import '../models/item_interaction.dart';
import 'collection_service.dart';

class CollectionMigrationResult {
  final Map<String, CountryCollection> updatedCollections;
  final int xpAwarded;

  const CollectionMigrationResult({
    required this.updatedCollections,
    required this.xpAwarded,
  });
}

class CollectionMigrationService {
  static const int currentMigrationVersion = 1;

  static CollectionMigrationResult backfillCollections({
    required Set<String> rewardedItemIds,
    required Map<String, ItemInteraction> interactions,
    required Map<String, CountryCollection> existingCollections,
  }) {
    final updatedCollections = <String, CountryCollection>{}
      ..addAll(existingCollections);

    final discoveredIds = <String>{}
      ..addAll(rewardedItemIds)
      ..addAll(
        interactions.entries
            .where(
              (entry) =>
                  entry.value.discoveryRewarded || entry.value.hasGuessed,
            )
            .map((entry) => entry.key),
      );

    for (final itemId in discoveredIds) {
      final match = mockBeliefs.where((item) => item.id == itemId);
      if (match.isEmpty) continue;

      final item = match.first;
      final existing =
          updatedCollections[item.countryCode] ??
          CountryCollection.initial(item.countryCode);

      if (!existing.discoveredItemIds.contains(item.id)) {
        final mergedIds = [...existing.discoveredItemIds, item.id];
        updatedCollections[item.countryCode] = existing.copyWith(
          discoveredItemIds: mergedIds,
        );
      }
    }

    int xpAwarded = 0;

    updatedCollections.forEach((countryCode, collection) {
      final progress = CollectionService.buildProgress(collection);
      final unlocked = [...collection.milestonesUnlocked];
      final newMilestones = <String>[];

      for (final milestone in ['25', '50', '100']) {
        final threshold = double.parse(milestone);

        if (progress.completionPercentage >= threshold &&
            !unlocked.contains(milestone)) {
          unlocked.add(milestone);
          newMilestones.add(milestone);
          xpAwarded += CollectionService.milestoneXpRewards[milestone] ?? 0;
        }
      }

      if (newMilestones.isNotEmpty) {
        updatedCollections[countryCode] = collection.copyWith(
          milestonesUnlocked: unlocked,
        );
      }
    });

    return CollectionMigrationResult(
      updatedCollections: updatedCollections,
      xpAwarded: xpAwarded,
    );
  }
}