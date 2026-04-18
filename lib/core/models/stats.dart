class Stats {
  final int atk;
  final int def;
  final int agi;

  const Stats({
    required this.atk,
    required this.def,
    required this.agi,
  });

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
        atk: json['atk'] as int,
        def: json['def'] as int,
        agi: json['agi'] as int,
      );

  Map<String, dynamic> toJson() => {
        'atk': atk,
        'def': def,
        'agi': agi,
      };
}
