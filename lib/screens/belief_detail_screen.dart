import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/belief.dart';
import '../services/app_state.dart';

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

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isSaved = appState.isFavorite(belief.id);

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
                      Text('+${belief.xpReward} XP'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Have you heard this?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              _reactionButton('Very common'),
              _reactionButton('Heard it before'),
              _reactionButton('Never heard this'),
              _reactionButton('Only older people say this'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final wasSaved = appState.isFavorite(belief.id);

                    await appState.toggleFavorite(belief.id);

                    if (!wasSaved) {
                      final rewarded = await appState.rewardIfFirstTime(
                        belief.id,
                        belief.xpReward,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            rewarded
                                ? 'Saved • +${belief.xpReward} XP'
                                : 'Saved (already discovered)',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Removed from collection'),
                          duration: Duration(seconds: 1),
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

  Widget _reactionButton(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {},
          child: Text(text),
        ),
      ),
    );
  }
}