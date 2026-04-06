import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/belief.dart';
import '../services/app_state.dart';
import '../services/interaction_service.dart';

class BeliefDetailScreen extends StatelessWidget {
  final Belief belief;

  const BeliefDetailScreen({
    super.key,
    required this.belief,
  });

  Color getRarityColor() {
    switch (belief.rarity) {
      case 'rare':
        return Colors.purple;
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

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isSaved = appState.isFavorite(belief.id);
    final interaction = appState.getInteraction(belief.id);
    final options = InteractionService.buildGuessOptions(belief);

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
                  Chip(
                    label: Text(
                      belief.contentType == 'saying'
                          ? '🗣️ Saying'
                          : '🌍 Belief',
                    ),
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
                  const SizedBox(height: 20),

                  if (!interaction.hasGuessed) ...[
                    Text(
                      'Guess the country before reveal',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      InteractionService.partialContent(belief),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    ...options.map(
                      (option) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final xpGained =
                                  await appState.submitGuess(belief, option);

                              if (context.mounted) {
                                final updated =
                                    appState.getInteraction(belief.id);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      updated.isCorrect
                                          ? 'Correct! +$xpGained XP'
                                          : 'Not quite • +$xpGained XP',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
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

                    ...options.map(
                      (option) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: getGuessButtonColor(
                                option,
                                belief.countryName,
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
                      'Correct answer: ${belief.countryName}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
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

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await appState.toggleFavorite(belief.id);

                    if (context.mounted) {
                      final nowSaved = appState.isFavorite(belief.id);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            nowSaved
                                ? 'Saved to collection'
                                : 'Removed from collection',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          xpGained > 0
                              ? '$reactionType selected • +$xpGained XP'
                              : 'Reaction already submitted',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
          child: Text(reactionType),
        ),
      ),
    );
  }
}