class CardModel {
  final int id;
  final String name;
  final int manaCost;

  CardModel({
    required this.id,
    required this.name,
    required this.manaCost,
  });

  String get imagePath => 'assets/cards/${id}.jpg';
}
