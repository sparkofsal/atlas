import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

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
          Text(
            'Welcome, Explorer',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Level ${appState.level} • ${appState.xp} XP',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
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
                : '${appState.nextLevelXp - appState.xp} XP to next level',
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Discovery',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  const Text('Early birthday wishes bring bad luck.'),
                  const SizedBox(height: 8),
                  const Text('Country: Germany'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Reveal'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Progress Snapshot'),
                  const SizedBox(height: 12),
                  Text('Saved beliefs: ${appState.favoriteBeliefIds.length}'),
                  Text('Current level: ${appState.level}'),
                  Text('Total XP: ${appState.xp}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}