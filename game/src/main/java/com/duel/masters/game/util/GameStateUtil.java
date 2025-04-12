package com.duel.masters.game.util;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.player.service.PlayerDto;

public class GameStateUtil {

    public static GameStateDto getGameStateDto(String gameId, PlayerDto player, PlayerDto opponent, boolean isPlayer1Chosen, String playerTopic) {
        return GameStateDto
                .builder()
                .gameId(gameId)
                .playerId(player.getId())
                .opponentId(opponent.getId())
                .playerName(player.getUsername())
                .opponentName(opponent.getUsername())
                .playerShields(player.getPlayerShields())
                .opponentShields(opponent.getPlayerShields())
                .playerHand(player.getPlayerHand())
                .opponentHand(opponent.getPlayerHand())
                .playerDeck(player.getPlayerDeck())
                .opponentDeck(opponent.getPlayerDeck())
                .playerManaZone(player.getPlayerManaZone())
                .opponentManaZone(opponent.getPlayerManaZone())
                .currentTurnPlayerId(isPlayer1Chosen ? player.getId() : opponent.getId())
                .playerTopic(playerTopic)
                .build();
    }

    public static GameStateDto getGameStateDtoPlayer(GameStateDto gameStateDto, String topic) {
        return GameStateDto
                .builder()
                .gameId(gameStateDto.getGameId())
                .playerId(gameStateDto.getPlayerId())
                .opponentId(gameStateDto.getOpponentId())
                .playerName(gameStateDto.getPlayerName())
                .opponentName(gameStateDto.getOpponentName())
                .playerShields(gameStateDto.getPlayerShields())
                .opponentShields(gameStateDto.getOpponentShields())
                .playerHand(gameStateDto.getPlayerHand())
                .opponentHand(gameStateDto.getOpponentHand())
                .playerDeck(gameStateDto.getPlayerDeck())
                .opponentDeck(gameStateDto.getOpponentDeck())
                .currentTurnPlayerId(gameStateDto.getCurrentTurnPlayerId())
                .playerManaZone(gameStateDto.getPlayerManaZone())
                .opponentManaZone(gameStateDto.getOpponentManaZone())
                .playerBattleZone(gameStateDto.getPlayerBattleZone())
                .opponentBattleZone(gameStateDto.getOpponentBattleZone())
                .playerTopic(topic)
                .playedMana(gameStateDto.isPlayedMana())
                .build();


    }

    public static GameStateDto getGameStateDtoOpponent(GameStateDto gameStateDto, String topic) {
        return GameStateDto
                .builder()
                .gameId(gameStateDto.getGameId())
                .playerId(gameStateDto.getOpponentId())
                .opponentId(gameStateDto.getPlayerId())
                .playerName(gameStateDto.getOpponentName())
                .opponentName(gameStateDto.getPlayerName())
                .playerShields(gameStateDto.getOpponentShields())
                .opponentShields(gameStateDto.getPlayerShields())
                .playerHand(gameStateDto.getOpponentHand())
                .opponentHand(gameStateDto.getPlayerHand())
                .playerDeck(gameStateDto.getOpponentDeck())
                .opponentDeck(gameStateDto.getPlayerDeck())
                .currentTurnPlayerId(gameStateDto.getCurrentTurnPlayerId())
                .playerManaZone(gameStateDto.getOpponentManaZone())
                .opponentManaZone(gameStateDto.getPlayerManaZone())
                .playerBattleZone(gameStateDto.getOpponentBattleZone())
                .opponentBattleZone(gameStateDto.getPlayerBattleZone())
                .playerTopic(topic)
                .playedMana(gameStateDto.isPlayedMana())
                .build();
    }

}