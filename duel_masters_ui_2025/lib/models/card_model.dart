import 'package:uuid/uuid.dart';

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
    this.isTapped = false
  }); // 👍 now it works
  void toggleTap() {
    isTapped = !isTapped;
  }

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'gameCardId': gameCardId,
        'name': name,
        'type': type,
        'civilization': civilization,
        'race': race,
        'manaCost': manaCost,
        'manaNumber': manaNumber,
        'ability': ability,
        'specialAbility': specialAbility,
        'isTapped': isTapped
      };

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'],
      power: json['power'],
      gameCardId: json['gameCardId'],
      name: json['name'],
      type: json['type'],
      civilization: json['civilization'],
      race: json['race'],
      manaCost: json['manaCost'],
      manaNumber: json['manaNumber'],
      ability: json['ability'],
      specialAbility: json['specialAbility'],
      isTapped: json['isTapped'] ?? false,
    );
  }


  String get imagePath => 'assets/cards/${id}.jpg';
}
