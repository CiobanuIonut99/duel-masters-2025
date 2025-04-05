class CardModel {
  final int id;
  final String name;
  final int manaCost;
  bool isTapped;

  CardModel({
    required this.id,
    required this.name,
    required this.manaCost,
    this.isTapped = false,
  });
  void toggleTap() {
    isTapped = !isTapped;
  }
  String get imagePath => 'assets/cards/${id}.jpg';
}
