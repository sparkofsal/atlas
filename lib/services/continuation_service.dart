import '../data/mock_countries.dart';
import '../models/continuation_action.dart';
import '../models/discovery_run.dart';
import 'collection_service.dart';

class ContinuationService {
  static ContinuationAction buildNextAction({
    required DiscoveryRun? activeRun,
    required List<CountryCollectionProgress> progressList,
    required int currentCombo,
  }) {
    if (activeRun != null && !activeRun.rewarded && !activeRun.completed) {
      return ContinuationAction(
        title: 'Continue your run 🔥',
        subtitle: activeRun.title,
        buttonLabel: 'Continue Run',
        actionType: 'run',
        countryCode: activeRun.metadata['countryCode'] as String?,
      );
    }

    final nearCompletion = progressList.where((item) {
      final remaining = item.totalCount - item.discoveredCount;
      return item.discoveredCount > 0 &&
          item.completionPercentage < 100 &&
          remaining > 0 &&
          remaining <= 2;
    }).toList();

    if (nearCompletion.isNotEmpty) {
      nearCompletion.sort((a, b) {
        final aRemaining = a.totalCount - a.discoveredCount;
        final bRemaining = b.totalCount - b.discoveredCount;
        return aRemaining.compareTo(bRemaining);
      });

      final target = nearCompletion.first;
      final country = mockCountries.firstWhere(
        (item) => item.code == target.countryCode,
      );

      return ContinuationAction(
        title: 'Finish ${country.name} ${country.flagEmoji}',
        subtitle: 'You are very close to completing this country.',
        buttonLabel: 'Continue',
        actionType: 'country',
        countryCode: target.countryCode,
      );
    }

    if (currentCombo >= 2) {
      return const ContinuationAction(
        title: 'Keep your combo going 👀',
        subtitle: 'Another correct guess will keep the momentum alive.',
        buttonLabel: 'Keep Going',
        actionType: 'combo',
      );
    }

    return const ContinuationAction(
      title: 'Discover something new 🔍',
      subtitle: 'There is always one more interesting belief waiting.',
      buttonLabel: 'Explore More',
      actionType: 'explore',
    );
  }
}