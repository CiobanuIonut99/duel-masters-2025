import 'package:uuid/uuid.dart';

class CardModel {
  final int id;
  final String name;
  final int manaCost;
  bool isTapped;
  String instanceId;

  CardModel({
    required this.id,
    required this.name,
    required this.manaCost,
    this.isTapped = false,
    String? instanceId,
  }) : instanceId = instanceId ?? Uuid().v4(); // 👍 now it works
  void toggleTap() {
    isTapped = !isTapped;
  }

  String get imagePath => 'assets/cards/${id}.jpg';
}
