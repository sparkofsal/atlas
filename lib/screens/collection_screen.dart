import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../data/mock_beliefs.dart';
import 'belief_detail_screen.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final savedBeliefs = mockBeliefs
        .where((belief) => appState.favoriteBeliefIds.contains(belief.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: savedBeliefs.isEmpty
            ? const Center(
                child: Text('No saved beliefs yet.'),
              )
            : ListView(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Collection',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Text('Saved beliefs: ${savedBeliefs.length}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...savedBeliefs.map(
                    (belief) => Card(
                      child: ListTile(
                        title: Text(belief.title),
                        subtitle: Text(
                          '${belief.countryName} • ${belief.categoryName}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BeliefDetailScreen(belief: belief),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}