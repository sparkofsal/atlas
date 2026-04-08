import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(event.message),
            duration: const Duration(seconds: 2),
          ),
        );
        appState.clearPendingProgressionUnlockEvent();
      });
    }

    return const SizedBox.shrink();
  }
}