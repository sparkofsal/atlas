import '../data/mock_beliefs.dart';
import '../models/belief.dart';
import '../models/daily_state.dart';

class DailyService {
  static String todayKey([DateTime? now]) {
    final localNow = now ?? DateTime.now();
    final localDate = DateTime(localNow.year, localNow.month, localNow.day);
    final month = localDate.month.toString().padLeft(2, '0');
    final day = localDate.day.toString().padLeft(2, '0');
    return '${localDate.year}-$month-$day';
  }

  static String yesterdayKey([DateTime? now]) {
    final localNow = now ?? DateTime.now();
    final yesterday = DateTime(
      localNow.year,
      localNow.month,
      localNow.day,
    ).subtract(const Duration(days: 1));

    final month = yesterday.month.toString().padLeft(2, '0');
    final day = yesterday.day.toString().padLeft(2, '0');
    return '${yesterday.year}-$month-$day';
  }

  static int _daySeed([DateTime? now]) {
    final localNow = now ?? DateTime.now();
    final localDate = DateTime(localNow.year, localNow.month, localNow.day);
    return localDate.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
  }

  static Belief getDailyBelief([DateTime? now]) {
    final beliefs = mockBeliefs
        .where((item) => item.contentType == 'belief')
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    final index = _daySeed(now) % beliefs.length;
    return beliefs[index];
  }

  static Belief getDailySaying([DateTime? now]) {
    final sayings = mockBeliefs
        .where((item) => item.contentType == 'saying')
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    final index = (_daySeed(now) + 3) % sayings.length;
    return sayings[index];
  }

  static DailyState syncState(DailyState state, [DateTime? now]) {
    final today = todayKey(now);
    final yesterday = yesterdayKey(now);

    DailyState updated = state;

    if (updated.dateKey != today) {
      updated = updated.copyWith(
        dateKey: today,
        dailyBeliefCompleted: false,
        dailySayingCompleted: false,
      );
    }

    if (updated.lastActiveDateKey != null &&
        updated.lastActiveDateKey != today &&
        updated.lastActiveDateKey != yesterday) {
      updated = updated.copyWith(currentStreak: 0);
    }

    return updated;
  }

  static DailyState completeDailyItem(
    DailyState state, {
    required String itemType,
    DateTime? now,
  }) {
    final synced = syncState(state, now);
    final today = todayKey(now);
    final yesterday = yesterdayKey(now);

    final firstCompletionToday = synced.lastActiveDateKey != today;

    int updatedStreak = synced.currentStreak;
    if (firstCompletionToday) {
      if (synced.lastActiveDateKey == yesterday) {
        updatedStreak = synced.currentStreak + 1;
      } else {
        updatedStreak = 1;
      }
    }

    final updatedBestStreak =
        updatedStreak > synced.bestStreak ? updatedStreak : synced.bestStreak;

    return synced.copyWith(
      dailyBeliefCompleted:
          itemType == 'belief' ? true : synced.dailyBeliefCompleted,
      dailySayingCompleted:
          itemType == 'saying' ? true : synced.dailySayingCompleted,
      lastActiveDateKey: today,
      currentStreak: updatedStreak,
      bestStreak: updatedBestStreak,
    );
  }
}