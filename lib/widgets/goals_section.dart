import 'package:flutter/material.dart';
import '../models/session_goal.dart';

class GoalsSection extends StatelessWidget {
  final List<SessionGoal> goals;

  const GoalsSection({
    super.key,
    required this.goals,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Goals 🎯',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Short, satisfying goals to guide this session.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        ...goals.map(
          (goal) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            goal.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Chip(
                          label: Text(goal.rewarded ? 'Done' : '+${goal.rewardXp} XP'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(goal.subtitle),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: goal.target == 0
                          ? 0
                          : (goal.progress / goal.target).clamp(0.0, 1.0),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${goal.progress}/${goal.target}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}