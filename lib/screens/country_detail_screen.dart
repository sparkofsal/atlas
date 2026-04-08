import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_countries.dart';
import '../data/mock_beliefs.dart';
import '../models/belief.dart';
import '../services/app_state.dart';
import '../services/progression_service.dart';
import 'belief_detail_screen.dart';

class CountryDetailScreen extends StatelessWidget {
  final String countryCode;

  const CountryDetailScreen({
    super.key,
    required this.countryCode,
  });

  List<Belief> getCountryBeliefs(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    final countryItems = mockBeliefs
        .where((belief) => belief.countryCode == countryCode)
        .toList();

    return ProgressionService.filterItemsForLevel(
      items: countryItems,
      playerLevel: appState.level,
      countryCode: countryCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final country = mockCountries.firstWhere((item) => item.code == countryCode);
    final beliefs = getCountryBeliefs(context);
    final progress = appState.getCountryProgressList().firstWhere(
          (item) => item.countryCode == countryCode,
        );

    final totalCountryItems = mockBeliefs
        .where((belief) => belief.countryCode == countryCode)
        .length;

    final visibleCount = beliefs.length;
    final nextDepthLevel = ProgressionService.nextCountryDepthUnlockLevel(
      appState.level,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(country.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    country.flagEmoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          country.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          country.region,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${progress.discoveredCount}/${progress.totalCount} discovered',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress.totalCount == 0
                              ? 0
                              : progress.discoveredCount / progress.totalCount,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${progress.completionPercentage.toStringAsFixed(0)}% complete',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                visibleCount < totalCountryItems && nextDepthLevel != null
                    ? 'More discoveries from ${country.name} unlock at Level $nextDepthLevel.'
                    : 'You currently have access to the full visible pool for this country.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.indigo,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Discoveries',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...beliefs.map(
            (belief) => Card(
              child: ListTile(
                title: Text(belief.title),
                subtitle: Text('${belief.categoryName} • ${belief.contentType}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BeliefDetailScreen(belief: belief),
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