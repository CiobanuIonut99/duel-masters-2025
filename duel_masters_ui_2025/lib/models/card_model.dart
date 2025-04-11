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
  bool isTapped;
  bool isSummonable;  // NEW

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
    this.isTapped = false,
    this.isSummonable = false, // NEW
  });

  void toggleTap() {
    isTapped = !isTapped;
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
    'isTapped': isTapped,
    'isSummonable': isSummonable, // NEW
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
      isTapped: json['isTapped'] ?? false,
      isSummonable: json['isSummonable'] ?? false,  // NEW
    );
  }

  String get imagePath => 'assets/cards/$id.jpg';
}
