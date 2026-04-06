import '../data/mock_beliefs.dart';
import '../models/belief.dart';

class InteractionService {
  static List<String> buildGuessOptions(Belief belief) {
    final allCountries = mockBeliefs
        .map((item) => item.countryName)
        .toSet()
        .where((country) => country != belief.countryName)
        .toList()
      ..sort();

    final seed = belief.id.codeUnits.fold<int>(0, (sum, c) => sum + c);

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
      final scoreA = (a.codeUnits.fold<int>(0, (sum, c) => sum + c) + seed) % 100;
      final scoreB = (b.codeUnits.fold<int>(0, (sum, c) => sum + c) + seed) % 100;
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
}