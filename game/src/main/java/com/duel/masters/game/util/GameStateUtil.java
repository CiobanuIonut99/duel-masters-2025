package com.duel.masters.game.util;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.player.service.PlayerDto;

public class GameStateUtil {

    public static GameStateDto getGameStateDto(String gameId, PlayerDto player, PlayerDto opponent, String playerTopic) {
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
                .currentTurnPlayerId(player.getId())
                .playerTopic(playerTopic)
                .build();
    }
}
