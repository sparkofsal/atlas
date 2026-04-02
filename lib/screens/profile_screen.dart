import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}