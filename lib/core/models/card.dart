import 'element_enum.dart';
import 'rarity_enum.dart';
import 'stats.dart';
import 'archetype_enum.dart';

class CardModel {
  final String cardInstanceId;
  final String templateId;
  final String name;
  final Archetype archetype;
  final int tier;
  final Rarity rarity;
  final ElementType element;
  final Stats stats;
  final String lore;
  final String imagePrompt;
  final int currentHp;
  final int maxHp;
  final String status;
  final DateTime? cooldownUntil;

  const CardModel({
    required this.cardInstanceId,
    required this.templateId,
    required this.name,
    required this.archetype,
    required this.tier,
    required this.rarity,
    required this.element,
    required this.stats,
    required this.lore,
    required this.imagePrompt,
    required this.currentHp,
    required this.maxHp,
    required this.status,
    this.cooldownUntil,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) => CardModel(
        cardInstanceId: json['cardInstanceId'] as String,
        templateId: json['templateId'] as String,
        name: json['name'] as String,
        archetype: Archetype.values.byName(json['archetype'] as String),
        tier: json['tier'] as int,
        rarity: Rarity.values.byName(json['rarity'] as String),
        element: ElementType.values.byName(json['element'] as String),
        stats: Stats.fromJson(json['stats'] as Map<String, dynamic>),
        lore: json['lore'] as String,
        imagePrompt: json['imagePrompt'] as String,
        currentHp: json['currentHp'] as int,
        maxHp: json['maxHp'] as int,
        status: json['status'] as String,
        cooldownUntil: json['cooldownUntil'] == null
            ? null
            : DateTime.parse(json['cooldownUntil'] as String),
      );

  Map<String, dynamic> toJson() => {
        'cardInstanceId': cardInstanceId,
        'templateId': templateId,
        'name': name,
        'archetype': archetype.name,
        'tier': tier,
        'rarity': rarity.name,
        'element': element.name,
        'stats': stats.toJson(),
        'lore': lore,
        'imagePrompt': imagePrompt,
        'currentHp': currentHp,
        'maxHp': maxHp,
        'status': status,
        'cooldownUntil': cooldownUntil?.toIso8601String(),
      };
}

extension CardModelExtension on CardModel {
  int get calculatedAtk => (stats.atk * rarity.multiplier).round();
  int get calculatedDef => (stats.def * rarity.multiplier).round();
  int get calculatedAgi => (stats.agi * rarity.multiplier).round();
}
