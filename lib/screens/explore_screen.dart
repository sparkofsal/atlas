import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/play_style.dart';
import '../services/app_state.dart';
import '../services/daily_service.dart';
import '../services/exploration_service.dart';
import '../widgets/active_run_card.dart';
import '../widgets/goals_section.dart';
import '../widgets/play_style_selector.dart';
import '../widgets/player_identity_header.dart';
import '../content/narrative_text.dart';
import 'belief_detail_screen.dart';
import 'country_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('has_seen_onboarding') ?? false;

    if (!hasSeen) {
      await prefs.setBool('has_seen_onboarding', true);

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Text(
              NarrativeText.onboardingMessage,
              style: const TextStyle(height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      });
    }
  }

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

    final feed = ExplorationService.buildFeed(
      playStyle: appState.activePlayStyle,
      playerLevel: appState.level,
      discoveredIds: appState.rewardedBeliefIds,
      progressList: progressList,
      selectedCountryCode: appState.lastSelectedCountryCode,
    );

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

          Text(
            'Choose Your Path',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Pick how you want to explore right now.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),

          PlayStyleSelector(
            selectedStyle: appState.activePlayStyle,
            sayingsUnlocked: appState.level >= 2,
            onSelected: (style) async {
              if (style == PlayStyle.finishCountry) {
                final target = ExplorationService.bestCountryToFinish(
                  progressList: progressList,
                  playerLevel: appState.level,
                  preferredCountryCode: appState.lastSelectedCountryCode,
                );
                await appState.setPlayStyle(style, countryCode: target);
              } else {
                await appState.setPlayStyle(style);
              }
            },
          ),

          const SizedBox(height: 24),

          Text(
            'Recommended Feed',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            appState.activePlayStyle.subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),

          if (feed.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  appState.activePlayStyle == PlayStyle.exploreSayings
                      ? 'No sayings available yet. Reach Level 2 or unlock more depth.'
                      : 'Nothing here right now. Try another path.',
                ),
              ),
            )
          else
            ...feed.take(10).map(
              (item) {
                final discovered = appState.rewardedBeliefIds.contains(item.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      leading: Text(
                        item.contentType == 'saying' ? '🗣️' : '🌍',
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(item.title),
                      subtitle: Text(
                        '${item.countryName} • ${item.categoryName}',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            discovered
                                ? Icons.check_circle
                                : Icons.auto_awesome,
                            color: discovered ? Colors.green : Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            discovered ? 'Seen' : 'New',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      onTap: () async {
                        await appState.setSelectedCountryCode(item.countryCode);

                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BeliefDetailScreen(belief: item),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 24),

          Text(
            'Daily Discovery',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),

          _DailyMiniCard(
            title: dailyBelief.title,
            label: 'Daily Belief',
            completed: appState.dailyBeliefCompleted,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BeliefDetailScreen(belief: dailyBelief),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _DailyMiniCard(
            title: dailySaying.title,
            label: 'Daily Saying',
            completed: appState.dailySayingCompleted,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BeliefDetailScreen(belief: dailySaying),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DailyMiniCard extends StatelessWidget {
  final String title;
  final String label;
  final bool completed;
  final VoidCallback onTap;

  const _DailyMiniCard({
    required this.title,
    required this.label,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(label),
        trailing: Chip(
          label: Text(completed ? 'Done' : 'Open'),
        ),
        onTap: onTap,
      ),
    );
  }
}