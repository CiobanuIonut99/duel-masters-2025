import '../models/card_model.dart';

class GameStateParser {
  static List<CardModel> _parseCardList(List? data) {
    return (data ?? []).map((c) => CardModel.fromJson(c)).toList();
  }

  static GameZones parse(Map<String, dynamic> responseBody) {
    return GameZones(
      playerHand: _parseCardList(responseBody['playerHand']),
      playerDeck: _parseCardList(responseBody['playerDeck']),
      playerShields: _parseCardList(responseBody['playerShields']),
      playerManaZone: _parseCardList(responseBody['playerManaZone']),
      playerBattleZone: _parseCardList(responseBody['playerBattleZone']),
      playerGraveyard: _parseCardList(responseBody['playerGraveyard']),

      opponentHand: _parseCardList(responseBody['opponentHand']),
      opponentDeck: _parseCardList(responseBody['opponentDeck']),
      opponentShields: _parseCardList(responseBody['opponentShields']),
      opponentManaZone: _parseCardList(responseBody['opponentManaZone']),
      opponentBattleZone: _parseCardList(responseBody['opponentBattleZone']),
      opponentGraveyard: _parseCardList(responseBody['opponentGraveyard']),
    );
  }
}

class GameZones {
  final List<CardModel> playerHand;
  final List<CardModel> playerDeck;
  final List<CardModel> playerShields;
  final List<CardModel> playerManaZone;
  final List<CardModel> playerBattleZone;
  final List<CardModel> playerGraveyard;

  final List<CardModel> opponentHand;
  final List<CardModel> opponentDeck;
  final List<CardModel> opponentShields;
  final List<CardModel> opponentManaZone;
  final List<CardModel> opponentBattleZone;
  final List<CardModel> opponentGraveyard;

  GameZones({
    required this.playerHand,
    required this.playerDeck,
    required this.playerShields,
    required this.playerManaZone,
    required this.playerBattleZone,
    required this.playerGraveyard,
    required this.opponentHand,
    required this.opponentDeck,
    required this.opponentShields,
    required this.opponentManaZone,
    required this.opponentBattleZone,
    required this.opponentGraveyard,
  });
}
