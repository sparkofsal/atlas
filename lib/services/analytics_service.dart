class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();

  factory AnalyticsService() => _instance;

  AnalyticsService._internal();

  void logEvent(String name, {Map<String, dynamic>? params}) {
    // For now: debug print
    // Later: Firebase or other analytics

    print('[Analytics] $name ${params ?? {}}');
  }

  // --- SESSION ---

  void logAppOpen() => logEvent('app_open');

  void logSessionStart() => logEvent('session_start');

  void logSessionEnd({int? actionsCount}) =>
      logEvent('session_end', params: {
        'actions_count': actionsCount,
      });

  // --- GAMEPLAY ---

  void logBeliefViewed(String beliefId) =>
      logEvent('belief_viewed', params: {
        'belief_id': beliefId,
      });

  void logGuessSubmitted() => logEvent('guess_submitted');

  void logGuessCorrect({int? combo}) =>
      logEvent('guess_correct', params: {
        'combo': combo,
      });

  void logGuessWrong() => logEvent('guess_wrong');

  // --- COMBO ---

  void logComboExtended(int combo) =>
      logEvent('combo_extended', params: {
        'combo': combo,
      });

  void logComboBroken(int combo) =>
      logEvent('combo_broken', params: {
        'combo': combo,
      });

  // --- RUNS ---

  void logRunStarted() => logEvent('run_started');

  void logRunCompleted({int? length}) =>
      logEvent('run_completed', params: {
        'length': length,
      });

  // --- SUGGESTIONS ---

  void logSuggestionShown(String type) =>
      logEvent('suggestion_shown', params: {
        'type': type,
      });

  void logSuggestionClicked(String type) =>
      logEvent('suggestion_clicked', params: {
        'type': type,
      });

  // --- COLLECTION ---

  void logCountryCompleted(String countryCode) =>
      logEvent('country_completed', params: {
        'country': countryCode,
      });

  // --- STREAK ---

  void logStreakContinued(int days) =>
      logEvent('streak_continued', params: {
        'days': days,
      });

  void logStreakBroken() => logEvent('streak_broken');
}