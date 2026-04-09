import 'dart:math';

class NarrativeText {
  static final _random = Random();

  // ---------------------------
  // MICROCOPY (COMMON)
  // ---------------------------

  static const correctMessages = [
    "Noted.",
    "That one fits.",
    "That feels right.",
    "You’re starting to see it.",
  ];

  static const incorrectMessages = [
    "Not quite.",
    "Something is off.",
    "That doesn’t hold.",
    "Look again.",
  ];

  static const comboMessages = [
    "It’s connecting.",
    "The pattern continues.",
    "You’re following it now.",
  ];

  static const nearMessages = [
    "You’re getting closer.",
    "You’re starting to notice the pattern...",
  ];

  // ---------------------------
  // RARE DISCOVERY MESSAGES
  // ---------------------------

  static const rareDiscoveryMessages = [
    "Some beliefs travel farther than they should...",
    "This one appears in more places than expected.",
    "This wasn’t meant to be found so easily.",
  ];

  // ---------------------------
  // LEVEL UP
  // ---------------------------

  static const levelUpMessages = [
    "You’re seeing more than before.",
    "Something just shifted.",
    "The map feels different now.",
  ];

  // ---------------------------
  // RARITY FEEDBACK
  // ---------------------------

  static const rarityMessages = [
    "This one is uncommon.",
    "Not everyone finds this.",
    "Some would miss this entirely.",
  ];

  // ---------------------------
  // ONBOARDING
  // ---------------------------

  static const onboardingMessage = 
      "Every culture leaves something behind.\n"
      "A belief. A warning. A pattern.\n\n"
      "You're about to explore them.";

  // ---------------------------
  // HELPERS
  // ---------------------------

  static String pick(List<String> list) {
    return list[_random.nextInt(list.length)];
  }

  static bool shouldTriggerRare({double chance = 0.08}) {
    return _random.nextDouble() < chance;
  }
}