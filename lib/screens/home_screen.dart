import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_countries.dart';
import '../services/app_state.dart';
import '../services/country_unlock_service.dart';
import '../widgets/player_identity_header.dart';
import 'country_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String? _suggestion(AppState appState) {
    final progress = appState.getCountryProgressList();

    final unlocked = progress.where((item) {
      return CountryUnlockService.isUnlocked(
        countryCode: item.countryCode,
        playerLevel: appState.level,
      );
    }).toList();

    final locked = progress.where((item) {
      return !CountryUnlockService.isUnlocked(
        countryCode: item.countryCode,
        playerLevel: appState.level,
      );
    }).toList();

    unlocked.sort(
      (a, b) => b.completionPercentage.compareTo(a.completionPercentage),
    );

    final nearComplete = unlocked.where((item) {
      final remaining = item.totalCount - item.discoveredCount;
      return item.discoveredCount > 0 && remaining > 0 && remaining <= 2;
    }).toList();

    if (nearComplete.isNotEmpty) {
      final target = nearComplete.first;
      final country = mockCountries.firstWhere(
        (item) => item.code == target.countryCode,
      );
      return 'You\'re close to completing ${country.name}';
    }

    final continueCountry = unlocked.where((item) {
      return item.discoveredCount > 0 && item.completionPercentage < 100;
    }).toList();

    if (continueCountry.isNotEmpty) {
      final target = continueCountry.first;
      final country = mockCountries.firstWhere(
        (item) => item.code == target.countryCode,
      );
      return 'Continue ${country.name} (${target.completionPercentage.toStringAsFixed(0)}%)';
    }

    if (locked.isNotEmpty) {
      locked.sort((a, b) {
        final aReq = CountryUnlockService.requiredLevel(a.countryCode);
        final bReq = CountryUnlockService.requiredLevel(b.countryCode);
        return aReq.compareTo(bReq);
      });

      final target = locked.first;
      final country = mockCountries.firstWhere(
        (item) => item.code == target.countryCode,
      );
      final requiredLevel = CountryUnlockService.requiredLevel(target.countryCode);
      if (requiredLevel == appState.level + 1) {
        return 'New country almost unlocked: ${country.name} at Level $requiredLevel';
      }
    }

    return null;
  }

  String? _suggestionCountryCode(AppState appState) {
    final progress = appState.getCountryProgressList();

    final unlocked = progress.where((item) {
      return CountryUnlockService.isUnlocked(
        countryCode: item.countryCode,
        playerLevel: appState.level,
      );
    }).toList();

    unlocked.sort(
      (a, b) => b.completionPercentage.compareTo(a.completionPercentage),
    );

    final nearComplete = unlocked.where((item) {
      final remaining = item.totalCount - item.discoveredCount;
      return item.discoveredCount > 0 && remaining > 0 && remaining <= 2;
    }).toList();

    if (nearComplete.isNotEmpty) {
      return nearComplete.first.countryCode;
    }

    final continueCountry = unlocked.where((item) {
      return item.discoveredCount > 0 && item.completionPercentage < 100;
    }).toList();

    if (continueCountry.isNotEmpty) {
      return continueCountry.first.countryCode;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final suggestion = _suggestion(appState);
    final suggestionCountryCode = _suggestionCountryCode(appState);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Belief Atlas'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PlayerIdentityHeader(),
          const SizedBox(height: 16),
          Text(
            'Welcome back',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Your journey through the world of beliefs is growing every day.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (suggestion != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suggested Path',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      suggestion,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.indigo,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (suggestionCountryCode != null) ...[
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CountryDetailScreen(
                                countryCode: suggestionCountryCode,
                              ),
                            ),
                          );
                        },
                        child: const Text('Continue Exploring'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Retention Snapshot',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text('Current streak: ${appState.currentStreak}'),
                  Text('Best streak: ${appState.bestStreak}'),
                  const SizedBox(height: 6),
                  Text(
                    appState.currentStreak > 0
                        ? 'Don’t break your streak.'
                        : 'Start a streak today.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.indigo,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text('Current combo: x${appState.currentCombo}'),
                  Text('Best combo: x${appState.bestCombo}'),
                  const SizedBox(height: 6),
                  Text(
                    appState.nextComboGoalHint,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (appState.nearCountryGoalHint != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      appState.nearCountryGoalHint!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text('Total discoveries: ${appState.totalDiscoveries}'),
                  Text('Countries explored: ${appState.countriesExplored}'),
                  Text('Favorites saved: ${appState.favoritesCount}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}