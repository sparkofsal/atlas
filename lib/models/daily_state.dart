class DailyState {
  final String dateKey;
  final bool dailyBeliefCompleted;
  final bool dailySayingCompleted;
  final String? lastActiveDateKey;
  final int currentStreak;
  final int bestStreak;

  const DailyState({
    required this.dateKey,
    required this.dailyBeliefCompleted,
    required this.dailySayingCompleted,
    required this.lastActiveDateKey,
    required this.currentStreak,
    required this.bestStreak,
  });

  factory DailyState.initial(String todayKey) {
    return DailyState(
      dateKey: todayKey,
      dailyBeliefCompleted: false,
      dailySayingCompleted: false,
      lastActiveDateKey: null,
      currentStreak: 0,
      bestStreak: 0,
    );
  }

  DailyState copyWith({
    String? dateKey,
    bool? dailyBeliefCompleted,
    bool? dailySayingCompleted,
    String? lastActiveDateKey,
    int? currentStreak,
    int? bestStreak,
  }) {
    return DailyState(
      dateKey: dateKey ?? this.dateKey,
      dailyBeliefCompleted:
          dailyBeliefCompleted ?? this.dailyBeliefCompleted,
      dailySayingCompleted:
          dailySayingCompleted ?? this.dailySayingCompleted,
      lastActiveDateKey: lastActiveDateKey ?? this.lastActiveDateKey,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
    );
  }
}