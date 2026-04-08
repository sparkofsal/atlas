class ContinuationAction {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final String actionType; // run, country, combo, explore
  final String? countryCode;

  const ContinuationAction({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.actionType,
    this.countryCode,
  });
}