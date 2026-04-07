import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/avatar_presets.dart';
import '../services/app_state.dart';

class PlayerIdentityHeader extends StatelessWidget {
  final bool compact;

  const PlayerIdentityHeader({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final avatarPreset = avatarPresets.firstWhere(
      (preset) => preset.id == appState.avatarId,
      orElse: () => avatarPresets.first,
    );

    final username =
        appState.hasCompletedProfileSetup ? appState.username : 'Explorer';

    final titleStyle = compact
        ? Theme.of(context).textTheme.bodyMedium
        : Theme.of(context).textTheme.titleMedium;

    final usernameStyle = compact
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.headlineSmall;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(compact ? 14 : 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: compact ? 24 : 30,
              backgroundColor: Color(avatarPreset.colorValue).withOpacity(0.18),
              child: Text(
                avatarPreset.emoji,
                style: TextStyle(fontSize: compact ? 22 : 28),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Text(
                        username,
                        style: usernameStyle?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Level ${appState.level}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.indigo,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appState.currentTitle,
                    style: titleStyle?.copyWith(
                      color: Colors.indigo,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0,
                      end: appState.levelProgress.clamp(0.0, 1.0),
                    ),
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: compact ? 8 : 10,
                        borderRadius: BorderRadius.circular(999),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${appState.xpToNextLevel} XP to Level ${appState.level + 1}',
                    style: Theme.of(context).textTheme.bodySmall,
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