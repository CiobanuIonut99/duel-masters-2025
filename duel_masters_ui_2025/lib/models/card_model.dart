class CardModel {
  final int id;
  final String gameCardId;
  final String name;
  final String type;
  final String civilization;
  final String race;
  final int manaCost;
  final int manaNumber;
  final int power;
  final String ability;
  final String specialAbility;

  bool tapped;
  bool summonable;
  bool summoningSickness;
  bool canBeAttacked;
  bool canAttack;
  bool? shield; // NEW

  CardModel({
    required this.id,
    required this.power,
    required this.gameCardId,
    required this.name,
    required this.type,
    required this.civilization,
    required this.race,
    required this.manaCost,
    required this.manaNumber,
    required this.ability,
    required this.specialAbility,
    this.tapped = false,
    this.summonable = false,
    this.summoningSickness = false,
    this.canBeAttacked = false,
    this.canAttack = false,
    this.shield = false, // NEW
  });

  void toggleTap() {
    tapped = !tapped;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'gameCardId': gameCardId,
    'name': name,
    'type': type,
    'civilization': civilization,
    'race': race,
    'manaCost': manaCost,
    'manaNumber': manaNumber,
    'power': power,
    'ability': ability,
    'specialAbility': specialAbility,
    'tapped': tapped,
    'summonable': summonable,
    'summoningSickness': summoningSickness,
    'canBeAttacked': canBeAttacked,
    'canAttack': canAttack,
    'shield': shield, // NEW
  };

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'],
      gameCardId: json['gameCardId'],
      name: json['name'] ?? "Unknown",
      type: json['type'] ?? "UNKNOWN",
      civilization: json['civilization'],
      race: json['race'] ?? "UNKNOWN",
      manaCost: json['manaCost'],
      manaNumber: json['manaNumber'],
      power: json['power'],
      ability: json['ability'] ?? "",
      specialAbility: json['specialAbility'] ?? "",
      tapped: json['tapped'] ?? false,
      summonable: json['summonable'] ?? false,
      summoningSickness: json['summoningSickness'] ?? false,
      canBeAttacked: json['canBeAttacked'] ?? false,
      canAttack: json['canAttack'] ?? false,
      shield: json['shield'] ?? false, // NEW
    );
  }

  static List<CardModel> fromList(List<dynamic> jsonList) =>
      jsonList.map((e) => CardModel.fromJson(e)).toList();

  String get imagePath => 'assets/cards/$id.jpg';
}
