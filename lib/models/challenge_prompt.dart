class ChallengePrompt {
  final String mode; // country_guess | true_fake
  final String prompt;
  final String displayText;
  final List<String> options;
  final String correctAnswer;
  final bool statementIsReal;

  const ChallengePrompt({
    required this.mode,
    required this.prompt,
    required this.displayText,
    required this.options,
    required this.correctAnswer,
    required this.statementIsReal,
  });
}