import '../models/card_model.dart';

class GameStateParser {
  static List<CardModel>? _parseOptionalCardList(dynamic data) {
    if (data == null) return null;
    return (data as List).map((c) => CardModel.fromJson(c)).toList();
  }

  static GameZones parse(Map<String, dynamic> responseBody) {
    return GameZones(
      playerHand: responseBody.containsKey('playerHand')
          ? _parseOptionalCardList(responseBody['playerHand'])
          : null,
      playerDeck: responseBody.containsKey('playerDeck')
          ? _parseOptionalCardList(responseBody['playerDeck'])
          : null,
      playerShields: responseBody.containsKey('playerShields')
          ? _parseOptionalCardList(responseBody['playerShields'])
          : null,
      playerManaZone: responseBody.containsKey('playerManaZone')
          ? _parseOptionalCardList(responseBody['playerManaZone'])
          : null,
      playerBattleZone: responseBody.containsKey('playerBattleZone')
          ? _parseOptionalCardList(responseBody['playerBattleZone'])
          : null,
      playerGraveyard: responseBody.containsKey('playerGraveyard')
          ? _parseOptionalCardList(responseBody['playerGraveyard'])
          : null,
      opponentHand: responseBody.containsKey('opponentHand')
          ? _parseOptionalCardList(responseBody['opponentHand'])
          : null,
      opponentDeck: responseBody.containsKey('opponentDeck')
          ? _parseOptionalCardList(responseBody['opponentDeck'])
          : null,
      opponentShields: responseBody.containsKey('opponentShields')
          ? _parseOptionalCardList(responseBody['opponentShields'])
          : null,
      opponentManaZone: responseBody.containsKey('opponentManaZone')
          ? _parseOptionalCardList(responseBody['opponentManaZone'])
          : null,
      opponentBattleZone: responseBody.containsKey('opponentBattleZone')
          ? _parseOptionalCardList(responseBody['opponentBattleZone'])
          : null,
      opponentGraveyard: responseBody.containsKey('opponentGraveyard')
          ? _parseOptionalCardList(responseBody['opponentGraveyard'])
          : null,
    );
  }
}
class GameZones {
  final List<CardModel>? playerHand;
  final List<CardModel>? playerDeck;
  final List<CardModel>? playerShields;
  final List<CardModel>? playerManaZone;
  final List<CardModel>? playerBattleZone;
  final List<CardModel>? playerGraveyard;

  final List<CardModel>? opponentHand;
  final List<CardModel>? opponentDeck;
  final List<CardModel>? opponentShields;
  final List<CardModel>? opponentManaZone;
  final List<CardModel>? opponentBattleZone;
  final List<CardModel>? opponentGraveyard;

  GameZones({
    this.playerHand,
    this.playerDeck,
    this.playerShields,
    this.playerManaZone,
    this.playerBattleZone,
    this.playerGraveyard,
    this.opponentHand,
    this.opponentDeck,
    this.opponentShields,
    this.opponentManaZone,
    this.opponentBattleZone,
    this.opponentGraveyard,
  });
}
