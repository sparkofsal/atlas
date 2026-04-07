import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/level_up_event.dart';
import '../services/app_state.dart';

class LevelUpListener extends StatefulWidget {
  const LevelUpListener({super.key});

  @override
  State<LevelUpListener> createState() => _LevelUpListenerState();
}

class _LevelUpListenerState extends State<LevelUpListener> {
  String? _lastHandledEventId;
  bool _isShowingDialog = false;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final event = appState.pendingLevelUpEvent;

    if (event != null &&
        event.id != _lastHandledEventId &&
        !_isShowingDialog) {
      _lastHandledEventId = event.id;
      _isShowingDialog = true;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await _showLevelUpDialog(context, event);
        if (!mounted) return;
        appState.clearPendingLevelUpEvent();
        _isShowingDialog = false;
      });
    }

    return const SizedBox.shrink();
  }

  Future<void> _showLevelUpDialog(
    BuildContext context,
    LevelUpEvent event,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 42,
                  color: Colors.indigo,
                ),
                const SizedBox(height: 14),
                Text(
                  'LEVEL UP!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Level ${event.oldLevel} → Level ${event.newLevel}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 14),
                if (event.titleChanged) ...[
                  Text(
                    'New Title Unlocked',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      event.newTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.indigo,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ] else ...[
                  Text(
                    'Keep going — your knowledge journey is growing.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Awesome'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}