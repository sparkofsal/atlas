import 'package:flutter/material.dart';
import '../models/country.dart';
import '../models/belief.dart';
import '../data/mock_beliefs.dart';
import 'belief_detail_screen.dart';

class CountryDetailScreen extends StatelessWidget {
  final Country country;

  const CountryDetailScreen({
    super.key,
    required this.country,
  });

  List<Belief> get countryBeliefs {
    return mockBeliefs
        .where((belief) => belief.countryCode == country.code)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
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
                        const SizedBox(height: 6),
                        Text(
                          '${countryBeliefs.length} beliefs available',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Beliefs',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...countryBeliefs.map(
            (belief) => Card(
              child: ListTile(
                title: Text(belief.title),
                subtitle: Text(
                  belief.categoryName,
                ),
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