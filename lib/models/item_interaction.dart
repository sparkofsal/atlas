class ItemInteraction {
  final bool hasGuessed;
  final String? selectedAnswer;
  final bool isCorrect;
  final bool hasReacted;
  final String? reactionType;
  final bool discoveryRewarded;
  final bool guessRewarded;
  final bool reactionRewarded;

  const ItemInteraction({
    this.hasGuessed = false,
    this.selectedAnswer,
    this.isCorrect = false,
    this.hasReacted = false,
    this.reactionType,
    this.discoveryRewarded = false,
    this.guessRewarded = false,
    this.reactionRewarded = false,
  });

  ItemInteraction copyWith({
    bool? hasGuessed,
    String? selectedAnswer,
    bool? isCorrect,
    bool? hasReacted,
    String? reactionType,
    bool? discoveryRewarded,
    bool? guessRewarded,
    bool? reactionRewarded,
  }) {
    return ItemInteraction(
      hasGuessed: hasGuessed ?? this.hasGuessed,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      hasReacted: hasReacted ?? this.hasReacted,
      reactionType: reactionType ?? this.reactionType,
      discoveryRewarded: discoveryRewarded ?? this.discoveryRewarded,
      guessRewarded: guessRewarded ?? this.guessRewarded,
      reactionRewarded: reactionRewarded ?? this.reactionRewarded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasGuessed': hasGuessed,
      'selectedAnswer': selectedAnswer,
      'isCorrect': isCorrect,
      'hasReacted': hasReacted,
      'reactionType': reactionType,
      'discoveryRewarded': discoveryRewarded,
      'guessRewarded': guessRewarded,
      'reactionRewarded': reactionRewarded,
    };
  }

  factory ItemInteraction.fromJson(Map<String, dynamic> json) {
    return ItemInteraction(
      hasGuessed: json['hasGuessed'] ?? false,
      selectedAnswer: json['selectedAnswer'],
      isCorrect: json['isCorrect'] ?? false,
      hasReacted: json['hasReacted'] ?? false,
      reactionType: json['reactionType'],
      discoveryRewarded: json['discoveryRewarded'] ?? false,
      guessRewarded: json['guessRewarded'] ?? false,
      reactionRewarded: json['reactionRewarded'] ?? false,
    );
  }
}