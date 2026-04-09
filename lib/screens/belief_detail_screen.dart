import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/belief.dart';
import '../services/app_state.dart';
import '../services/continuation_service.dart';
import '../services/interaction_service.dart';
import '../widgets/app_feedback.dart';
import '../widgets/continuation_card.dart';
import '../content/narrative_text.dart';
import 'country_detail_screen.dart';
import 'explore_screen.dart';
import '../services/analytics_service.dart';

class BeliefDetailScreen extends StatelessWidget {
  final Belief belief;

  const BeliefDetailScreen({
    super.key,
    required this.belief,
  });

  Color getRarityColor() {
    switch (belief.rarity.toLowerCase()) {
      case 'legendary':
        return Colors.amber;
      case 'epic':
        return Colors.deepPurple;
      case 'rare':
      case 'uncommon':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  Color? getGuessButtonColor(
    String option,
    String correctAnswer,
    String? selectedAnswer,
    bool hasGuessed,
  ) {
    if (!hasGuessed) return null;

    if (option == correctAnswer) {
      return Colors.green.shade200;
    }

    if (option == selectedAnswer && option != correctAnswer) {
      return Colors.red.shade200;
    }

    return null;
  }

  void _handleContinuation(BuildContext context, AppState appState) {
    final action = ContinuationService.buildNextAction(
      activeRun: appState.activeRun,
      progressList: appState.getCountryProgressList(),
      currentCombo: appState.currentCombo,
    );

    switch (action.actionType) {
      case 'country':
      case 'run':
        if (action.countryCode != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CountryDetailScreen(
                countryCode: action.countryCode!,
              ),
            ),
          );
          return;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ExploreScreen(),
          ),
        );
        return;

      case 'combo':
      case 'explore':
      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ExploreScreen(),
          ),
        );
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isSaved = appState.isFavorite(belief.id);
    final interaction = appState.getInteraction(belief.id);
    final prompt = InteractionService.buildPrompt(belief);

    final continuation = ContinuationService.buildNextAction(
      activeRun: appState.activeRun,
      progressList: appState.getCountryProgressList(),
      currentCombo: appState.currentCombo,
    );

    final showContinuationCard =
        interaction.hasGuessed && interaction.hasReacted;

    return Scaffold(
      appBar: AppBar(
        title: Text(belief.countryName),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(
                          belief.contentType == 'saying'
                              ? '🗣️ Saying'
                              : '🌍 Belief',
                        ),
                      ),
                      Chip(
                        label: Text('Combo x${appState.currentCombo}'),
                      ),
                      Chip(
                        label: Text('Streak ${appState.currentStreak}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    belief.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Chip(
                        label: Text(belief.categoryName),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(belief.rarity.toUpperCase()),
                        backgroundColor: getRarityColor().withOpacity(0.2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    appState.nextComboGoalHint,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.indigo,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (appState.nearCountryGoalHint != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      appState.nearCountryGoalHint!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (!interaction.hasGuessed) ...[
                    Text(
                      prompt.prompt,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      prompt.displayText,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    ...prompt.options.map(
                      (option) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              AnalyticsService().logGuessSubmitted();

                              final result =
                                  await appState.submitGuess(belief, option);
                                  
                              if (result.isCorrect) {
                                AnalyticsService().logGuessCorrect(combo: result.comboAfter);
                              } else {
                                AnalyticsService().logGuessWrong();
                              }                            
                              
                              if (!context.mounted) return;

                              String message;
                              IconData icon;

                              if (result.isCorrect) {
                                message = NarrativeText.pick(
                                  NarrativeText.correctMessages,
                                );

                                if (result.comboAfter >= 2) {
                                  message +=
                                      " • ${NarrativeText.pick(NarrativeText.comboMessages)}";
                                }

                                icon = Icons.check_circle_outline;
                              } else {
                                message = NarrativeText.pick(
                                  NarrativeText.incorrectMessages,
                                );
                                icon = Icons.help_outline;
                              }

                              AppFeedback.show(
                                context,
                                message: message,
                                icon: icon,
                              );

                              if (result.surpriseMessage != null) {
                                Future.delayed(
                                  const Duration(milliseconds: 350),
                                  () {
                                    if (!context.mounted) return;
                                    AppFeedback.show(
                                      context,
                                      message: result.surpriseMessage!,
                                      icon: Icons.auto_awesome,
                                    );
                                  },
                                );
                              }
                            },
                            child: Text(option),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Answer revealed',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ...prompt.options.map(
                      (option) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: getGuessButtonColor(
                                option,
                                prompt.correctAnswer,
                                interaction.selectedAnswer,
                                interaction.hasGuessed,
                              ),
                            ),
                            onPressed: null,
                            child: Text(option),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Correct answer: ${prompt.correctAnswer}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    if (prompt.mode == 'true_fake' && !prompt.statementIsReal)
                      Text(
                        'That statement was made up. Here is the real entry from ${belief.countryName}:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.indigo,
                              fontWeight: FontWeight.w600,
                            ),
                      )
                    else if (prompt.mode == 'true_fake' && prompt.statementIsReal)
                      Text(
                        'It was real. Here is the full entry:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.indigo,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    if (prompt.mode == 'true_fake') const SizedBox(height: 12),
                    Text(
                      belief.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.bolt),
                        const SizedBox(width: 6),
                        Text('+${belief.xpReward} discovery XP'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (interaction.hasGuessed) ...[
            const SizedBox(height: 20),
            Text(
              'Choose one reaction',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _reactionButton(
              context: context,
              appState: appState,
              itemId: belief.id,
              reactionType: 'Agree',
              isSelected: interaction.reactionType == 'Agree',
              locked: interaction.hasReacted,
            ),
            _reactionButton(
              context: context,
              appState: appState,
              itemId: belief.id,
              reactionType: 'Disagree',
              isSelected: interaction.reactionType == 'Disagree',
              locked: interaction.hasReacted,
            ),
            _reactionButton(
              context: context,
              appState: appState,
              itemId: belief.id,
              reactionType: 'Mind-blown',
              isSelected: interaction.reactionType == 'Mind-blown',
              locked: interaction.hasReacted,
            ),
          ],
          if (showContinuationCard) ...[
            const SizedBox(height: 20),
            ContinuationCard(
              action: continuation,
              onContinue: () => _handleContinuation(context, appState),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await appState.toggleFavorite(belief.id);

                    if (context.mounted) {
                      final nowSaved = appState.isFavorite(belief.id);

                      AppFeedback.show(
                        context,
                        message: nowSaved
                            ? 'Saved to collection'
                            : 'Removed from collection',
                        icon: nowSaved
                            ? Icons.bookmark_added_outlined
                            : Icons.bookmark_remove_outlined,
                      );
                    }
                  },
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                  ),
                  label: Text(isSaved ? 'Saved' : 'Save'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reactionButton({
    required BuildContext context,
    required AppState appState,
    required String itemId,
    required String reactionType,
    required bool isSelected,
    required bool locked,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected ? Colors.indigo.withOpacity(0.12) : null,
          ),
          onPressed: locked
              ? null
              : () async {
                  final xpGained =
                      await appState.submitReaction(itemId, reactionType);

                  if (context.mounted) {
                    AppFeedback.show(
                      context,
                      message: xpGained > 0
                          ? 'Nice! $reactionType selected • +$xpGained XP'
                          : 'Reaction already submitted',
                      icon: Icons.emoji_objects_outlined,
                    );
                  }
                },
          child: Text(reactionType),
        ),
      ),
    );
  }
}