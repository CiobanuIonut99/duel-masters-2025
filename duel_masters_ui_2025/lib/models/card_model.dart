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
  bool summonable;  // NEW

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
    this.summonable = false, // NEW
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
    'summonable': summonable, // NEW
  };

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'],
      gameCardId: json['gameCardId'],
      name: json['name'],
      type: json['type'],
      civilization: json['civilization'],
      race: json['race'],
      manaCost: json['manaCost'],
      manaNumber: json['manaNumber'],
      power: json['power'],
      ability: json['ability'],
      specialAbility: json['specialAbility'],
      tapped: json['tapped'] ?? false,
      summonable: json['summonable'] ?? false,
    );
  }

  String get imagePath => 'assets/cards/$id.jpg';
}
