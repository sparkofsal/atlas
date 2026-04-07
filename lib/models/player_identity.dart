class PlayerIdentity {
  final String username;
  final String avatarId;
  final bool hasCompletedProfileSetup;

  const PlayerIdentity({
    required this.username,
    required this.avatarId,
    required this.hasCompletedProfileSetup,
  });

  factory PlayerIdentity.initial() {
    return const PlayerIdentity(
      username: '',
      avatarId: 'owl',
      hasCompletedProfileSetup: false,
    );
  }

  PlayerIdentity copyWith({
    String? username,
    String? avatarId,
    bool? hasCompletedProfileSetup,
  }) {
    return PlayerIdentity(
      username: username ?? this.username,
      avatarId: avatarId ?? this.avatarId,
      hasCompletedProfileSetup:
          hasCompletedProfileSetup ?? this.hasCompletedProfileSetup,
    );
  }
}