import 'package:flutter/material.dart';
import '../data/mock_countries.dart';
import '../data/mock_beliefs.dart';
import 'country_detail_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  int getBeliefCount(String countryCode) {
    return mockBeliefs
        .where((belief) => belief.countryCode == countryCode)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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