import 'package:flutter/material.dart';
import '../models/continuation_action.dart';

class ContinuationCard extends StatelessWidget {
  final ContinuationAction action;
  final VoidCallback onContinue;

  const ContinuationCard({
    super.key,
    required this.action,
    required this.onContinue,
  });

  IconData _iconForType(String type) {
    switch (type) {
      case 'run':
        return Icons.local_fire_department;
      case 'country':
        return Icons.public;
      case 'combo':
        return Icons.bolt;
      default:
        return Icons.explore;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.indigo.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _iconForType(action.actionType),
              color: Colors.indigo,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    action.subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton(
                      onPressed: onContinue,
                      child: Text(action.buttonLabel),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}