import '../models/belief.dart';

class ProgressionService {
  static String normalizeRarity(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'uncommon':
        return 'rare'; // backward compatibility with earlier content
      case 'common':
      case 'rare':
      case 'epic':
      case 'legendary':
        return rarity.toLowerCase();
      default:
        return 'common';
    }
  }

  static int requiredLevelForRarity(String rarity) {
    switch (normalizeRarity(rarity)) {
      case 'rare':
        return 3;
      case 'epic':
        return 6;
      case 'legendary':
        return 10;
      case 'common':
      default:
        return 1;
    }
  }

  static bool isRarityUnlocked({
    required String rarity,
    required int playerLevel,
  }) {
    return playerLevel >= requiredLevelForRarity(rarity);
  }

  static bool areSayingsUnlocked(int playerLevel) {
    return playerLevel >= 2;
  }

  static int countryDepthLimit(int playerLevel) {
    if (playerLevel >= 10) return 999;
    if (playerLevel >= 6) return 8;
    if (playerLevel >= 3) return 5;
    return 3;
  }

  static int? nextCountryDepthUnlockLevel(int playerLevel) {
    if (playerLevel < 3) return 3;
    if (playerLevel < 6) return 6;
    if (playerLevel < 10) return 10;
    return null;
  }

  static List<Belief> filterItemsForLevel({
    required List<Belief> items,
    required int playerLevel,
    String? countryCode,
  }) {
    final filtered = items.where((item) {
      final inCountry = countryCode == null || item.countryCode == countryCode;
      final sayingsOk =
          item.contentType != 'saying' || areSayingsUnlocked(playerLevel);
      final rarityOk = isRarityUnlocked(
        rarity: item.rarity,
        playerLevel: playerLevel,
      );

      return inCountry && sayingsOk && rarityOk;
    }).toList();

    final grouped = <String, List<Belief>>{};
    for (final item in filtered) {
      grouped.putIfAbsent(item.countryCode, () => []).add(item);
    }

    final depthLimit = countryDepthLimit(playerLevel);
    final result = <Belief>[];

    grouped.forEach((_, countryItems) {
      countryItems.sort((a, b) {
        final aFeatured = a.isFeatured ? 1 : 0;
        final bFeatured = b.isFeatured ? 1 : 0;
        if (aFeatured != bFeatured) {
          return bFeatured.compareTo(aFeatured);
        }
        return a.id.compareTo(b.id);
      });

      result.addAll(countryItems.take(depthLimit));
    });

    return result;
  }

  static int comboBonusForLevel({
    required int combo,
    required int level,
  }) {
    int base;
    if (combo <= 1) {
      base = 0;
    } else if (combo == 2) {
      base = 2;
    } else if (combo == 3) {
      base = 5;
    } else if (combo == 4) {
      base = 7;
    } else {
      base = 10 + ((combo - 5) * 2);
    }

    if (base == 0) return 0;

    if (level >= 10) return base + 2;
    if (level >= 6) return base + 1;
    return base;
  }

  static String? unlockMessageForLevelCrossed({
    required int oldLevel,
    required int newLevel,
  }) {
    if (oldLevel < 10 && newLevel >= 10) {
      return 'Legendary discoveries unlocked ✨';
    }
    if (oldLevel < 6 && newLevel >= 6) {
      return 'Epic items now available 👀';
    }
    if (oldLevel < 3 && newLevel >= 3) {
      return 'Rare discoveries unlocked 🔓';
    }
    return null;
  }
}