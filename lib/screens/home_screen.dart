import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../widgets/player_identity_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

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