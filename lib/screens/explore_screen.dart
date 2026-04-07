import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_countries.dart';
import '../data/mock_beliefs.dart';
import '../services/app_state.dart';
import '../services/daily_service.dart';
import '../widgets/player_identity_header.dart';
import 'country_detail_screen.dart';
import 'belief_detail_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  int getBeliefCount(String countryCode) {
    return mockBeliefs
        .where((belief) => belief.countryCode == countryCode)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final dailyBelief = DailyService.getDailyBelief();
    final dailySaying = DailyService.getDailySaying();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PlayerIdentityHeader(compact: true),
          const SizedBox(height: 16),
          Text(
            'Today’s Discovery 🌍',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Current streak: ${appState.currentStreak} day${appState.currentStreak == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _DailyCard(
            item: dailyBelief,
            completed: appState.dailyBeliefCompleted,
            rewardText: '+25 XP',
            buttonLabel:
                appState.dailyBeliefCompleted ? 'Completed' : 'Complete',
            onComplete: () async {
              if (appState.dailyBeliefCompleted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BeliefDetailScreen(belief: dailyBelief),
                  ),
                );
                return;
              }

              final granted = await appState.completeDailyBelief();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      granted
                          ? 'Daily Belief completed • +25 XP'
                          : 'Daily Belief already completed',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
            onOpen: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BeliefDetailScreen(belief: dailyBelief),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _DailyCard(
            item: dailySaying,
            completed: appState.dailySayingCompleted,
            rewardText: '+25 XP',
            buttonLabel:
                appState.dailySayingCompleted ? 'Completed' : 'Complete',
            onComplete: () async {
              if (appState.dailySayingCompleted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BeliefDetailScreen(belief: dailySaying),
                  ),
                );
                return;
              }

              final granted = await appState.completeDailySaying();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      granted
                          ? 'Daily Saying completed • +25 XP'
                          : 'Daily Saying already completed',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
            onOpen: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BeliefDetailScreen(belief: dailySaying),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search countries or beliefs',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Countries',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...mockCountries.map(
            (country) => Card(
              child: ListTile(
                leading: Text(
                  country.flagEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(country.name),
                subtitle: Text(
                  '${getBeliefCount(country.code)} beliefs available',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CountryDetailScreen(country: country),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyCard extends StatelessWidget {
  final dynamic item;
  final bool completed;
  final String rewardText;
  final String buttonLabel;
  final Future<void> Function() onComplete;
  final VoidCallback onOpen;

  const _DailyCard({
    required this.item,
    required this.completed,
    required this.rewardText,
    required this.buttonLabel,
    required this.onComplete,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final typeLabel =
        item.contentType == 'saying' ? '🗣️ Daily Saying' : '🌍 Daily Belief';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(typeLabel, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(item.description),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text(completed ? 'Completed' : 'Not completed'),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(rewardText),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onOpen,
                    child: const Text('Open'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onComplete,
                    child: Text(buttonLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}