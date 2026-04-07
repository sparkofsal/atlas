import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/avatar_presets.dart';
import '../data/mock_countries.dart';
import '../services/app_state.dart';
import '../services/collection_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AvatarPreset _presetById(String id) {
    return avatarPresets.firstWhere(
      (preset) => preset.id == id,
      orElse: () => avatarPresets.first,
    );
  }

  String _countryName(String code) {
    final country = mockCountries.firstWhere((item) => item.code == code);
    return country.name;
  }

  String _countryFlag(String code) {
    final country = mockCountries.firstWhere((item) => item.code == code);
    return country.flagEmoji;
  }

  Color _milestoneColor(CountryCollectionProgress progress) {
    if (progress.completionPercentage >= 100) return Colors.amber;
    if (progress.completionPercentage >= 50) return Colors.indigo;
    if (progress.completionPercentage >= 25) return Colors.green;
    return Colors.grey;
  }

  Future<void> _showProfileEditor(BuildContext context, AppState appState) async {
    final usernameController = TextEditingController(text: appState.username);
    String selectedAvatarId = appState.avatarId;
    String? errorText;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      appState.hasCompletedProfileSetup
                          ? 'Edit Profile'
                          : 'Set Up Your Profile',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        hintText: '3-16 chars, letters/numbers/_',
                        errorText: errorText,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Choose an avatar',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: avatarPresets.map((preset) {
                        final isSelected = preset.id == selectedAvatarId;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedAvatarId = preset.id;
                            });
                          },
                          child: Container(
                            width: 72,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(preset.colorValue).withOpacity(0.18)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? Color(preset.colorValue)
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  preset.emoji,
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  preset.label,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final value = usernameController.text.trim();

                          if (!AppState.isValidUsername(value)) {
                            setModalState(() {
                              errorText =
                                  'Use 3-16 characters: letters, numbers, underscore';
                            });
                            return;
                          }

                          await appState.updatePlayerProfile(
                            username: value,
                            avatarId: selectedAvatarId,
                          );

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile saved'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        child: Text(
                          appState.hasCompletedProfileSetup
                              ? 'Save Changes'
                              : 'Start Exploring',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    if (!appState.hasCompletedProfileSetup) {
      final selectedPreset = _presetById(appState.avatarId);

      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile Setup'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor:
                          Color(selectedPreset.colorValue).withOpacity(0.2),
                      child: Text(
                        selectedPreset.emoji,
                        style: const TextStyle(fontSize: 34),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Create Your Explorer Identity',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Choose a username and avatar to begin building your legend.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showProfileEditor(context, appState),
                        child: const Text('Set Up Profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final avatarPreset = _presetById(appState.avatarId);
    final countryProgress = appState.getCountryProgressList()
      ..sort((a, b) => b.completionPercentage.compareTo(a.completionPercentage));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => _showProfileEditor(context, appState),
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor:
                        Color(avatarPreset.colorValue).withOpacity(0.2),
                    child: Text(
                      avatarPreset.emoji,
                      style: const TextStyle(fontSize: 34),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    appState.username,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    appState.currentTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.indigo,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Level ${appState.level}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: appState.levelProgress,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  const SizedBox(height: 8),
                  Text('XP: ${appState.xp}'),
                  const SizedBox(height: 4),
                  Text('${appState.xpToNextLevel} XP to next level'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _StatCard(
                label: 'Total Discoveries',
                value: '${appState.totalDiscoveries}',
                icon: Icons.auto_awesome,
              ),
              _StatCard(
                label: 'Countries Explored',
                value: '${appState.countriesExplored}',
                icon: Icons.public,
              ),
              _StatCard(
                label: 'Current Streak',
                value: '${appState.currentStreak}',
                icon: Icons.local_fire_department,
              ),
              _StatCard(
                label: 'Best Streak',
                value: '${appState.bestStreak}',
                icon: Icons.workspace_premium,
              ),
              _StatCard(
                label: 'Current Combo',
                value: 'x${appState.currentCombo}',
                icon: Icons.flash_on,
              ),
              _StatCard(
                label: 'Best Combo',
                value: 'x${appState.bestCombo}',
                icon: Icons.bolt,
              ),
              _StatCard(
                label: 'Favorites',
                value: '${appState.favoritesCount}',
                icon: Icons.bookmark,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Countries Explored 🌍',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...countryProgress.map(
            (progress) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          _countryFlag(progress.countryCode),
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _countryName(progress.countryCode),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          '${progress.discoveredCount}/${progress.totalCount}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: progress.totalCount == 0
                          ? 0
                          : progress.discoveredCount / progress.totalCount,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(12),
                      color: _milestoneColor(progress),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${progress.completionPercentage.toStringAsFixed(0)}% complete',
                        ),
                        const Spacer(),
                        if (progress.milestonesUnlocked.isNotEmpty)
                          Text(
                            'Milestones: ${progress.milestonesUnlocked.join(', ')}%',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}