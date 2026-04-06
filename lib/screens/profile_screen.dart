import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_countries.dart';
import '../services/app_state.dart';
import '../services/collection_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _countryName(String code) {
    final country = mockCountries.firstWhere(
      (item) => item.code == code,
    );
    return country.name;
  }

  String _countryFlag(String code) {
    final country = mockCountries.firstWhere(
      (item) => item.code == code,
    );
    return country.flagEmoji;
  }

  Color _milestoneColor(CountryCollectionProgress progress) {
    if (progress.completionPercentage >= 100) return Colors.amber;
    if (progress.completionPercentage >= 50) return Colors.indigo;
    if (progress.completionPercentage >= 25) return Colors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final countryProgress = appState.getCountryProgressList()
      ..sort((a, b) => b.completionPercentage.compareTo(a.completionPercentage));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    child: Icon(Icons.person, size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Explorer Level ${appState.level}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('XP: ${appState.xp}'),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: appState.levelProgress,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appState.level >= 5
                        ? 'Max level reached'
                        : 'Next level at ${appState.nextLevelXp} XP',
                  ),
                  const SizedBox(height: 8),
                  Text('Current streak: ${appState.currentStreak}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Countries Explored 🌍',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...countryProgress.map(
            (progress) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          _countryFlag(progress.countryCode),
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _countryName(progress.countryCode),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          '${progress.discoveredCount}/${progress.totalCount}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: progress.totalCount == 0
                          ? 0
                          : progress.discoveredCount / progress.totalCount,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(12),
                      color: _milestoneColor(progress),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${progress.completionPercentage.toStringAsFixed(0)}% complete',
                        ),
                        const Spacer(),
                        if (progress.milestonesUnlocked.isNotEmpty)
                          Text(
                            'Milestones: ${progress.milestonesUnlocked.join(', ')}%',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}