enum Archetype {
  striker,
  wall,
  dancer,
  allrounder,
}

extension ArchetypeExtension on Archetype {
  String get displayName {
    switch (this) {
      case Archetype.striker:
        return 'Stürmer';
      case Archetype.wall:
        return 'Wall';
      case Archetype.dancer:
        return 'Tänzer';
      case Archetype.allrounder:
        return 'Allrounder';
    }
  }
}
