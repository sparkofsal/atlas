import 'package:flutter/material.dart';
import '../data/mock_countries.dart';
import '../services/collection_service.dart';
import '../services/country_unlock_service.dart';

class CountryProgressCard extends StatelessWidget {
  final CountryCollectionProgress progress;
  final int playerLevel;
  final VoidCallback? onTap;

  const CountryProgressCard({
    super.key,
    required this.progress,
    required this.playerLevel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final country = mockCountries.firstWhere(
      (item) => item.code == progress.countryCode,
    );

    final unlockLevel = CountryUnlockService.requiredLevel(country.code);
    final unlocked = CountryUnlockService.isUnlocked(
      countryCode: country.code,
      playerLevel: playerLevel,
    );

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: unlocked ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Opacity(
            opacity: unlocked ? 1 : 0.72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      country.flagEmoji,
                      style: const TextStyle(fontSize: 26),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        country.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Icon(
                      unlocked ? Icons.lock_open : Icons.lock,
                      size: 18,
                      color: unlocked ? Colors.green : Colors.grey[700],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (unlocked) ...[
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
                ] else ...[
                  Text(
                    'Unlock at Level $unlockLevel',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.indigo,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (playerLevel / unlockLevel).clamp(0.0, 1.0),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${unlockLevel - playerLevel} more level${unlockLevel - playerLevel == 1 ? '' : 's'} needed',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}