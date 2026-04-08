import 'package:flutter/material.dart';
import '../models/discovery_run.dart';

class ActiveRunCard extends StatelessWidget {
  final DiscoveryRun run;

  const ActiveRunCard({
    super.key,
    required this.run,
  });

  IconData _iconForRun(String type) {
    switch (type) {
      case 'country':
        return Icons.public;
      case 'sayings':
        return Icons.record_voice_over;
      case 'category':
        return Icons.category;
      case 'combo':
        return Icons.local_fire_department;
      default:
        return Icons.bolt;
    }
  }

  String _labelForRun(String type) {
    switch (type) {
      case 'country':
        return 'Country Run';
      case 'sayings':
        return 'Sayings Run';
      case 'category':
        return 'Category Run';
      case 'combo':
        return 'Combo Run';
      default:
        return 'Run';
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressValue =
        run.target == 0 ? 0.0 : (run.progress / run.target).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_iconForRun(run.runType), color: Colors.deepOrange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _labelForRun(run.runType),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(run.rewarded ? 'Done' : '+${run.rewardXp} XP'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              run.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(run.subtitle),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progressValue,
              minHeight: 8,
              borderRadius: BorderRadius.circular(999),
            ),
            const SizedBox(height: 8),
            Text(
              '${run.progress} / ${run.target}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}