import 'package:uuid/uuid.dart';

class CardModel {
  final int id;
  final String name;
  final String type;
  final String civilization;
  final String race;
  final int manaCost;
  final int manaNumber;
  final String ability;
  final String specialAbility;
  bool isTapped;
  String instanceId;



  CardModel({
    required this.id,
    required this.name,
    required this.type,
    required this.civilization,
    required this.race,
    required this.manaCost,
    required this.manaNumber,
    required this.ability,
    required this.specialAbility,
    this.isTapped = false,
    String? instanceId,
  }) : instanceId = instanceId ?? Uuid().v4(); // 👍 now it works
  void toggleTap() {
    isTapped = !isTapped;
  }

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name': name,
        'type': type,
        'civilization': civilization,
        'race': race,
        'manaCost': manaCost,
        'manaNumber': manaNumber,
        'ability': ability,
        'specialAbility': specialAbility,
        'isTapped': isTapped,
        'instanceId': instanceId,
      };

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      civilization: json['civilization'],
      race: json['race'],
      manaCost: json['manaCost'],
      manaNumber: json['manaNumber'],
      ability: json['ability'],
      specialAbility: json['specialAbility'],
      isTapped: json['isTapped'] ?? false,
      instanceId: json['instanceId'],
    );
  }


  String get imagePath => 'assets/cards/${id}.jpg';
}
