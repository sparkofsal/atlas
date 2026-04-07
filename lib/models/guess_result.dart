class GuessResult {
  final bool alreadyGuessed;
  final bool isCorrect;
  final int totalXp;
  final int baseXp;
  final int comboBonusXp;
  final int discoveryXp;
  final int milestoneXp;
  final int surpriseXp;
  final int comboBefore;
  final int comboAfter;
  final bool comboBroken;
  final String? surpriseMessage;

  const GuessResult({
    required this.alreadyGuessed,
    required this.isCorrect,
    required this.totalXp,
    required this.baseXp,
    required this.comboBonusXp,
    required this.discoveryXp,
    required this.milestoneXp,
    required this.surpriseXp,
    required this.comboBefore,
    required this.comboAfter,
    required this.comboBroken,
    required this.surpriseMessage,
  });

  factory GuessResult.empty() {
    return const GuessResult(
      alreadyGuessed: true,
      isCorrect: false,
      totalXp: 0,
      baseXp: 0,
      comboBonusXp: 0,
      discoveryXp: 0,
      milestoneXp: 0,
      surpriseXp: 0,
      comboBefore: 0,
      comboAfter: 0,
      comboBroken: false,
      surpriseMessage: null,
    );
  }
}