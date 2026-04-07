import '../data/mock_beliefs.dart';
import '../models/belief.dart';
import '../models/challenge_prompt.dart';

class InteractionService {
  static int stableSeed(String input) {
    return input.codeUnits.fold<int>(0, (sum, c) => sum + c);
  }

  static List<String> buildGuessOptions(Belief belief) {
    final allCountries = mockBeliefs
        .map((item) => item.countryName)
        .toSet()
        .where((country) => country != belief.countryName)
        .toList()
      ..sort();

    final seed = stableSeed(belief.id);

    final wrongOptions = <String>[];
    for (int i = 0; i < allCountries.length && wrongOptions.length < 3; i++) {
      final index = (seed + i * 7) % allCountries.length;
      final candidate = allCountries[index];
      if (!wrongOptions.contains(candidate)) {
        wrongOptions.add(candidate);
      }
    }

    for (final country in allCountries) {
      if (wrongOptions.length >= 3) break;
      if (!wrongOptions.contains(country)) {
        wrongOptions.add(country);
      }
    }

    final options = <String>[belief.countryName, ...wrongOptions.take(3)];

    options.sort((a, b) {
      final scoreA = (stableSeed(a) + seed) % 100;
      final scoreB = (stableSeed(b) + seed) % 100;
      return scoreA.compareTo(scoreB);
    });

    return options;
  }

  static String partialContent(Belief belief) {
    final text = belief.description.trim();

    if (text.length <= 55) {
      return '${text.substring(0, text.length ~/ 2)}...';
    }

    return '${text.substring(0, 55)}...';
  }

  static bool shouldUseTrueFake(Belief belief) {
    return stableSeed('${belief.id}_mode') % 4 == 0;
  }

  static String buildFakeStatement(Belief belief) {
    const fakeTemplates = [
      'In {country}, people say that carrying salt in your left pocket guarantees clear weather.',
      'A common tale in {country} says that stepping over a closed book brings seven days of confusion.',
      'Some claim in {country} that touching a window before sunrise brings instant luck in travel.',
      'In {country}, it is said that placing shoes upside down invites noisy visitors.',
      'An old story from {country} says that whistling at noon calls bad weather.',
      'People in {country} are said to believe that tying a red thread to a doorknob prevents arguments.',
      'A local myth in {country} says that turning a cup three times keeps bad dreams away.',
      'In {country}, some supposedly say that counting stars on a cloudy night brings misfortune.',
    ];

    final seed = stableSeed('${belief.id}_fake');
    final template = fakeTemplates[seed % fakeTemplates.length];
    return template.replaceAll('{country}', belief.countryName);
  }

  static ChallengePrompt buildPrompt(Belief belief) {
    if (shouldUseTrueFake(belief)) {
      final statementIsReal = stableSeed('${belief.id}_truth') % 2 == 0;
      final text = statementIsReal
          ? belief.description
          : buildFakeStatement(belief);

      return ChallengePrompt(
        mode: 'true_fake',
        prompt: 'Is this real or made up?',
        displayText: text,
        options: const ['Real', 'Made up'],
        correctAnswer: statementIsReal ? 'Real' : 'Made up',
        statementIsReal: statementIsReal,
      );
    }

    return ChallengePrompt(
      mode: 'country_guess',
      prompt: 'Which country is this from?',
      displayText: partialContent(belief),
      options: buildGuessOptions(belief),
      correctAnswer: belief.countryName,
      statementIsReal: true,
    );
  }

  static int comboBonus(int combo) {
    if (combo <= 1) return 0;
    if (combo == 2) return 2;
    if (combo == 3) return 5;
    if (combo == 4) return 7;
    return 10 + ((combo - 5) * 2);
  }

  static int surpriseBonus(Belief belief, int combo, bool isCorrect) {
    if (!isCorrect) return 0;

    final seed = stableSeed('${belief.id}_surprise');

    if (combo >= 5 && seed % 6 == 0) {
      return 6;
    }

    if (combo >= 3 && seed % 11 == 0) {
      return 4;
    }

    return 0;
  }

  static String? surpriseMessage(Belief belief, int combo, bool isCorrect) {
    final bonus = surpriseBonus(belief, combo, isCorrect);
    if (bonus == 0) return null;

    if (bonus >= 6) {
      return 'Hot streak bonus! +$bonus XP';
    }

    return 'Rare insight! +$bonus XP';
  }
}