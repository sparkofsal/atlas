import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'app_feedback.dart';

class ProgressionUnlockListener extends StatefulWidget {
  const ProgressionUnlockListener({super.key});

  @override
  State<ProgressionUnlockListener> createState() =>
      _ProgressionUnlockListenerState();
}

class _ProgressionUnlockListenerState extends State<ProgressionUnlockListener> {
  String? _lastHandledId;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final event = appState.pendingProgressionUnlockEvent;

    if (event != null && event.id != _lastHandledId) {
      _lastHandledId = event.id;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppFeedback.show(
          context,
          message: event.message,
          icon: Icons.auto_awesome,
        );
        appState.clearPendingProgressionUnlockEvent();
      });
    }

    return const SizedBox.shrink();
  }
}