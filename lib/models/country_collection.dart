class CountryCollection {
  final String countryCode;
  final List<String> discoveredItemIds;
  final List<String> milestonesUnlocked;

  const CountryCollection({
    required this.countryCode,
    required this.discoveredItemIds,
    required this.milestonesUnlocked,
  });

  factory CountryCollection.initial(String countryCode) {
    return CountryCollection(
      countryCode: countryCode,
      discoveredItemIds: const [],
      milestonesUnlocked: const [],
    );
  }

  int discoveredCount() => discoveredItemIds.length;

  CountryCollection copyWith({
    String? countryCode,
    List<String>? discoveredItemIds,
    List<String>? milestonesUnlocked,
  }) {
    return CountryCollection(
      countryCode: countryCode ?? this.countryCode,
      discoveredItemIds: discoveredItemIds ?? this.discoveredItemIds,
      milestonesUnlocked: milestonesUnlocked ?? this.milestonesUnlocked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode,
      'discoveredItemIds': discoveredItemIds,
      'milestonesUnlocked': milestonesUnlocked,
    };
  }

  factory CountryCollection.fromJson(Map<String, dynamic> json) {
    return CountryCollection(
      countryCode: json['countryCode'] as String,
      discoveredItemIds: List<String>.from(json['discoveredItemIds'] ?? []),
      milestonesUnlocked: List<String>.from(json['milestonesUnlocked'] ?? []),
    );
  }
}