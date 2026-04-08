import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/exploration_service.dart';
import '../widgets/active_run_card.dart';
import '../widgets/goals_section.dart';
import '../widgets/player_identity_header.dart';
import 'country_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final progressList = appState.getCountryProgressList();
    final suggestion = ExplorationService.buildSuggestion(
      playerLevel: appState.level,
      xpToNextLevel: appState.xpToNextLevel,
      currentCombo: appState.currentCombo,
      lastSelectedPlayStyle: appState.activePlayStyle,
      lastSelectedCountryCode: appState.lastSelectedCountryCode,
      progressList: progressList,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Belief Atlas'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const PlayerIdentityHeader(),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Smart Suggestion',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    suggestion.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.indigo,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(suggestion.subtitle),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      await appState.setPlayStyle(
                        suggestion.playStyle,
                        countryCode: suggestion.countryCode,
                      );

                      if (suggestion.countryCode != null && context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CountryDetailScreen(
                              countryCode: suggestion.countryCode!,
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(suggestion.ctaLabel),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (appState.activeRun != null) ...[
            Text(
              'Active Run 🔥',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            ActiveRunCard(run: appState.activeRun!),
            const SizedBox(height: 16),
          ],

          GoalsSection(goals: appState.activeGoals),

          const SizedBox(height: 20),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You\'re getting close...',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text('${appState.xpToNextLevel} XP to next level'),
                  Text(appState.nextComboGoalHint),
                  if (appState.nearCountryGoalHint != null)
                    Text(appState.nearCountryGoalHint!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}