class Belief {
  final String id;
  final String title;
  final String description;
  final String countryCode;
  final String countryName;
  final String categoryId;
  final String categoryName;
  final List<String> tags;
  final String rarity;
  final int xpReward;
  final bool isFeatured;

  final String contentType; // NEW: "belief" or "saying"

  Belief({
    required this.id,
    required this.title,
    required this.description,
    required this.countryCode,
    required this.countryName,
    required this.categoryId,
    required this.categoryName,
    required this.tags,
    required this.rarity,
    required this.xpReward,
    required this.isFeatured,
    required this.contentType, // NEW
  });
}