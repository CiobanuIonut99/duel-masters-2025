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
