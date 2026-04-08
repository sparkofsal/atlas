import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'app_feedback.dart';

class GoalRewardListener extends StatefulWidget {
  const GoalRewardListener({super.key});

  @override
  State<GoalRewardListener> createState() => _GoalRewardListenerState();
}

class _GoalRewardListenerState extends State<GoalRewardListener> {
  String? _lastHandledId;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final event = appState.pendingGoalRewardEvent;

    if (event != null && event.id != _lastHandledId) {
      _lastHandledId = event.id;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppFeedback.show(
          context,
          message: event.message,
          icon: Icons.check_circle_outline,
        );
        appState.clearPendingGoalRewardEvent();
      });
    }

    return const SizedBox.shrink();
  }
}