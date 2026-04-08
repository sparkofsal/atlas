import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'app_feedback.dart';

class RunRewardListener extends StatefulWidget {
  const RunRewardListener({super.key});

  @override
  State<RunRewardListener> createState() => _RunRewardListenerState();
}

class _RunRewardListenerState extends State<RunRewardListener> {
  String? _lastHandledId;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final event = appState.pendingRunRewardEvent;

    if (event != null && event.id != _lastHandledId) {
      _lastHandledId = event.id;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppFeedback.show(
          context,
          message: event.message,
          icon: Icons.local_fire_department,
        );
        appState.clearPendingRunRewardEvent();
      });
    }

    return const SizedBox.shrink();
  }
}