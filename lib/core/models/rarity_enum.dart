enum Rarity {
  bronze,
  silver,
  gold,
  diamond,
}

extension RarityExtension on Rarity {
  double get multiplier {
    switch (this) {
      case Rarity.bronze:
        return 1.0;
      case Rarity.silver:
        return 1.2;
      case Rarity.gold:
        return 1.5;
      case Rarity.diamond:
        return 2.0;
    }
  }

  int get maxHp {
    switch (this) {
      case Rarity.bronze:
        return 1;
      case Rarity.silver:
        return 2;
      case Rarity.gold:
        return 3;
      case Rarity.diamond:
        return 4;
    }
  }

  int get deckPoints {
    switch (this) {
      case Rarity.bronze:
        return 1;
      case Rarity.silver:
        return 2;
      case Rarity.gold:
        return 4;
      case Rarity.diamond:
        return 7;
    }
  }
}
