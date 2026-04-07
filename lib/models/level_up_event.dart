class LevelUpEvent {
  final String id;
  final int oldLevel;
  final int newLevel;
  final String oldTitle;
  final String newTitle;

  const LevelUpEvent({
    required this.id,
    required this.oldLevel,
    required this.newLevel,
    required this.oldTitle,
    required this.newTitle,
  });

  bool get titleChanged => oldTitle != newTitle;
}