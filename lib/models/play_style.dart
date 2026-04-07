enum PlayStyle {
  exploreFreely,
  findNewDiscoveries,
  finishCountry,
  exploreSayings,
}

extension PlayStyleX on PlayStyle {
  String get id {
    switch (this) {
      case PlayStyle.exploreFreely:
        return 'explore_freely';
      case PlayStyle.findNewDiscoveries:
        return 'find_new_discoveries';
      case PlayStyle.finishCountry:
        return 'finish_country';
      case PlayStyle.exploreSayings:
        return 'explore_sayings';
    }
  }

  String get title {
    switch (this) {
      case PlayStyle.exploreFreely:
        return 'Explore Freely';
      case PlayStyle.findNewDiscoveries:
        return 'Find New Discoveries';
      case PlayStyle.finishCountry:
        return 'Finish a Country';
      case PlayStyle.exploreSayings:
        return 'Explore Sayings';
    }
  }

  String get subtitle {
    switch (this) {
      case PlayStyle.exploreFreely:
        return 'A mixed path through unlocked content';
      case PlayStyle.findNewDiscoveries:
        return 'Focus on items you have not discovered yet';
      case PlayStyle.finishCountry:
        return 'Push toward country completion';
      case PlayStyle.exploreSayings:
        return 'Browse cultural sayings and proverbs';
    }
  }

  String get emoji {
    switch (this) {
      case PlayStyle.exploreFreely:
        return '🧭';
      case PlayStyle.findNewDiscoveries:
        return '✨';
      case PlayStyle.finishCountry:
        return '🏁';
      case PlayStyle.exploreSayings:
        return '🗣️';
    }
  }

  static PlayStyle fromId(String? value) {
    switch (value) {
      case 'find_new_discoveries':
        return PlayStyle.findNewDiscoveries;
      case 'finish_country':
        return PlayStyle.finishCountry;
      case 'explore_sayings':
        return PlayStyle.exploreSayings;
      case 'explore_freely':
      default:
        return PlayStyle.exploreFreely;
    }
  }
}