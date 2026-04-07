class AvatarPreset {
  final String id;
  final String emoji;
  final String label;
  final int colorValue;

  const AvatarPreset({
    required this.id,
    required this.emoji,
    required this.label,
    required this.colorValue,
  });
}

const List<AvatarPreset> avatarPresets = [
  AvatarPreset(
    id: 'owl',
    emoji: '🦉',
    label: 'Owl',
    colorValue: 0xFF5C6BC0,
  ),
  AvatarPreset(
    id: 'fox',
    emoji: '🦊',
    label: 'Fox',
    colorValue: 0xFFFF7043,
  ),
  AvatarPreset(
    id: 'wolf',
    emoji: '🐺',
    label: 'Wolf',
    colorValue: 0xFF78909C,
  ),
  AvatarPreset(
    id: 'cat',
    emoji: '🐱',
    label: 'Cat',
    colorValue: 0xFFAB47BC,
  ),
  AvatarPreset(
    id: 'dragon',
    emoji: '🐉',
    label: 'Dragon',
    colorValue: 0xFF26A69A,
  ),
  AvatarPreset(
    id: 'unicorn',
    emoji: '🦄',
    label: 'Unicorn',
    colorValue: 0xFFEC407A,
  ),
  AvatarPreset(
    id: 'eagle',
    emoji: '🦅',
    label: 'Eagle',
    colorValue: 0xFF8D6E63,
  ),
  AvatarPreset(
    id: 'bear',
    emoji: '🐻',
    label: 'Bear',
    colorValue: 0xFF8E24AA,
  ),
];