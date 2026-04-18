enum ElementType {
  fire,
  earth,
  air,
  water,
}

extension ElementTypeExtension on ElementType {
  bool getsAdvantageOver(ElementType other) {
    switch (this) {
      case ElementType.fire:
        return other == ElementType.earth;
      case ElementType.earth:
        return other == ElementType.air;
      case ElementType.air:
        return other == ElementType.water;
      case ElementType.water:
        return other == ElementType.fire;
    }
  }
}
