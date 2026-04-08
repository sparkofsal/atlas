import '../data/mock_beliefs.dart';
import '../data/mock_countries.dart';
import '../models/belief.dart';
import '../models/play_style.dart';
import 'collection_service.dart';
import 'progression_service.dart';

class SmartSuggestion {
  final String title;
  final String subtitle;
  final String ctaLabel;
  final PlayStyle playStyle;
  final String? countryCode;

  const SmartSuggestion({
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.playStyle,
    this.countryCode,
  });
}

class ExplorationService {
  static List<Belief> _availableItemsForLevel({
    required int playerLevel,
  }) {
    return ProgressionService.filterItemsForLevel(
      items: mockBeliefs,
      playerLevel: playerLevel,
    );
  }

  static String? bestCountryToFinish({
    required List<CountryCollectionProgress> progressList,
    required int playerLevel,
    String? preferredCountryCode,
  }) {
    final availableItems = _availableItemsForLevel(playerLevel: playerLevel);
    final availableCountryCodes = availableItems
        .map((item) => item.countryCode)
        .toSet();

    final eligible = progressList.where((item) {
      final remaining = item.totalCount - item.discoveredCount;

      return item.discoveredCount > 0 &&
          item.completionPercentage < 100 &&
          remaining > 0 &&
          availableCountryCodes.contains(item.countryCode);
    }).toList();

    if (eligible.isEmpty) return null;

    if (preferredCountryCode != null) {
      final preferred = eligible.where(
        (e) => e.countryCode == preferredCountryCode,
      );
      if (preferred.isNotEmpty) {
        return preferred.first.countryCode;
      }
    }

    eligible.sort((a, b) {
      final aRemaining = a.totalCount - a.discoveredCount;
      final bRemaining = b.totalCount - b.discoveredCount;

      if (aRemaining != bRemaining) {
        return aRemaining.compareTo(bRemaining);
      }

      return b.completionPercentage.compareTo(a.completionPercentage);
    });

    return eligible.first.countryCode;
  }

  static SmartSuggestion buildSuggestion({
    required int playerLevel,
    required int xpToNextLevel,
    required int currentCombo,
    required PlayStyle lastSelectedPlayStyle,
    required String? lastSelectedCountryCode,
    required List<CountryCollectionProgress> progressList,
  }) {
    if (xpToNextLevel <= 15) {
      return SmartSuggestion(
        title: '$xpToNextLevel XP to Level ${playerLevel + 1}',
        subtitle: 'A few more discoveries and you level up.',
        ctaLabel: 'Push to Level Up',
        playStyle: PlayStyle.findNewDiscoveries,
      );
    }

    final availableItems = _availableItemsForLevel(playerLevel: playerLevel);
    final availableCountryCodes = availableItems
        .map((item) => item.countryCode)
        .toSet();

    final nearCompletion = progressList.where((item) {
      final remaining = item.totalCount - item.discoveredCount;

      return item.discoveredCount > 0 &&
          item.completionPercentage < 100 &&
          remaining > 0 &&
          remaining <= 2 &&
          availableCountryCodes.contains(item.countryCode);
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
      final remaining = target.totalCount - target.discoveredCount;

      return SmartSuggestion(
        title: 'Only $remaining more to complete ${country.name}',
        subtitle: 'Finish this country and grow your collection.',
        ctaLabel: 'Finish ${country.name}',
        playStyle: PlayStyle.finishCountry,
        countryCode: target.countryCode,
      );
    }

    if (currentCombo >= 2) {
      return SmartSuggestion(
        title: 'Keep your combo going 🔥',
        subtitle: 'Another correct guess will extend your momentum.',
        ctaLabel: 'Keep the Combo Alive',
        playStyle: PlayStyle.exploreFreely,
      );
    }

    if (lastSelectedPlayStyle == PlayStyle.finishCountry) {
      final countryCode = bestCountryToFinish(
        progressList: progressList,
        playerLevel: playerLevel,
        preferredCountryCode: lastSelectedCountryCode,
      );

      if (countryCode != null) {
        final country = mockCountries.firstWhere(
          (item) => item.code == countryCode,
        );
        return SmartSuggestion(
          title: 'Continue ${country.name}',
          subtitle: 'You already started this path — keep going.',
          ctaLabel: 'Continue',
          playStyle: PlayStyle.finishCountry,
          countryCode: countryCode,
        );
      }
    }

    return SmartSuggestion(
      title: lastSelectedPlayStyle.title,
      subtitle: lastSelectedPlayStyle.subtitle,
      ctaLabel: 'Resume',
      playStyle: lastSelectedPlayStyle,
      countryCode: lastSelectedCountryCode,
    );
  }

  static List<Belief> buildFeed({
    required PlayStyle playStyle,
    required int playerLevel,
    required Set<String> discoveredIds,
    required List<CountryCollectionProgress> progressList,
    String? selectedCountryCode,
  }) {
    final items = _availableItemsForLevel(playerLevel: playerLevel);

    final progressByCountry = {
      for (final item in progressList) item.countryCode: item,
    };

    switch (playStyle) {
      case PlayStyle.findNewDiscoveries:
        return items.where((item) => !discoveredIds.contains(item.id)).toList();

      case PlayStyle.finishCountry:
        final countryCode = bestCountryToFinish(
          progressList: progressList,
          playerLevel: playerLevel,
          preferredCountryCode: selectedCountryCode,
        );

        if (countryCode == null) {
          return [];
        }

        final filtered = items
            .where((item) => item.countryCode == countryCode)
            .toList();

        filtered.sort((a, b) {
          final aNew = discoveredIds.contains(a.id) ? 1 : 0;
          final bNew = discoveredIds.contains(b.id) ? 1 : 0;
          return aNew.compareTo(bNew);
        });

        return filtered;

      case PlayStyle.exploreSayings:
        return items.where((item) => item.contentType == 'saying').toList();

      case PlayStyle.exploreFreely:
        final mixed = [...items];
        mixed.sort((a, b) {
          int score(Belief item) {
            final discovered = discoveredIds.contains(item.id);
            final progress = progressByCountry[item.countryCode];
            final inProgressCountry = progress != null &&
                progress.discoveredCount > 0 &&
                progress.completionPercentage < 100;

            int total = 0;
            if (!discovered) total += 100;
            if (inProgressCountry) total += 20;
            if (item.contentType == 'saying') total += 8;

            final rarity = ProgressionService.normalizeRarity(item.rarity);
            if (playerLevel >= 3 && rarity == 'rare') total += 8;
            if (playerLevel >= 6 && rarity == 'epic') total += 12;
            if (playerLevel >= 10 && rarity == 'legendary') total += 18;

            return total;
          }

          return score(b).compareTo(score(a));
        });
        return mixed;
    }
  }
}