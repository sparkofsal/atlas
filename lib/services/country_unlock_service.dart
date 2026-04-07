class CountryUnlockService {
  static const Map<String, int> unlockLevels = {
    'US': 1,
    'MX': 1,
    'JP': 3,
    'DE': 5,
    'TR': 6,
    'BR': 8,
    'CZ': 10,
    'KR': 12,
  };

  static int requiredLevel(String countryCode) {
    return unlockLevels[countryCode] ?? 1;
  }

  static bool isUnlocked({
    required String countryCode,
    required int playerLevel,
  }) {
    return playerLevel >= requiredLevel(countryCode);
  }
}