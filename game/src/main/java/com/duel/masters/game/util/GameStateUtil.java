package com.duel.masters.game.util;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.player.service.PlayerDto;

public class GameStateUtil {

    public static GameStateDto getGameStateDto(String gameId, PlayerDto player, PlayerDto opponent, boolean isPlayer1Chosen) {
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
                .playerGraveyard(player.getPlayerGraveyard())
                .opponentGraveyard(opponent.getPlayerGraveyard())
                .currentTurnPlayerId(isPlayer1Chosen ? player.getId() : opponent.getId())
                .build();
    }

    public static GameStateDto getGameStateDtoPlayer(GameStateDto gameStateDto) {
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
                .playerGraveyard(gameStateDto.getPlayerGraveyard())
                .opponentGraveyard(gameStateDto.getOpponentGraveyard())
                .playedMana(gameStateDto.isPlayedMana())
                .opponentHasBlocker(gameStateDto.isOpponentHasBlocker())
                .hasSelectedBlocker(gameStateDto.isHasSelectedBlocker())
                .attackerId(gameStateDto.getAttackerId())
                .shieldTriggerCard(gameStateDto.getShieldTriggerCard())
                .shieldTriggersFlagsDto(gameStateDto.getShieldTriggersFlagsDto())
                .blockerFlagsDto(gameStateDto.getBlockerFlagsDto())
                .opponentSelectableCreatures(gameStateDto.getOpponentSelectableCreatures())
                .build();
    }

    public static GameStateDto getGameStateDtoOpponent(GameStateDto gameStateDto) {
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
                .playerGraveyard(gameStateDto.getOpponentGraveyard())
                .opponentGraveyard(gameStateDto.getPlayerGraveyard())
                .playedMana(gameStateDto.isPlayedMana())
                .opponentHasBlocker(gameStateDto.isOpponentHasBlocker())
                .hasSelectedBlocker(gameStateDto.isHasSelectedBlocker())
                .attackerId(gameStateDto.getAttackerId())
                .shieldTriggerCard(gameStateDto.getShieldTriggerCard())
                .shieldTriggersFlagsDto(gameStateDto.getShieldTriggersFlagsDto())
                .blockerFlagsDto(gameStateDto.getBlockerFlagsDto())
                .opponentSelectableCreatures(gameStateDto.getOpponentSelectableCreatures())
                .build();
    }
//
//    public static GameStateDto getGameStateDtoPlayerSummonToManaZone(GameStateDto gameStateDto) {
//        return GameStateDto
//                .builder()
//
//                .playedMana(gameStateDto.isPlayedMana())
//
//                .playerHand(gameStateDto.getPlayerHand())
//                .playerManaZone(gameStateDto.getPlayerManaZone())
//
//                .opponentHand(gameStateDto.getOpponentHand())
//                .opponentManaZone(gameStateDto.getOpponentManaZone())
//
//                .shieldTriggersFlagsDto(gameStateDto.getShieldTriggersFlagsDto())
//                .shieldTriggerCard(gameStateDto.getShieldTriggerCard())
//                .build();
//    }
//
//    public static GameStateDto getGameStateDtoOpponentSummonToManaZone(GameStateDto gameStateDto) {
//        return GameStateDto
//                .builder()
//
//                .playedMana(gameStateDto.isPlayedMana())
//
//                .opponentHand(gameStateDto.getPlayerHand())
//                .opponentManaZone(gameStateDto.getPlayerManaZone())
//
//                .playerHand(gameStateDto.getOpponentHand())
//                .playerManaZone(gameStateDto.getOpponentManaZone())
//
//                .shieldTriggersFlagsDto(gameStateDto.getShieldTriggersFlagsDto())
//                .shieldTriggerCard(gameStateDto.getShieldTriggerCard())
//                .build();
//    }
//
//
//    public static GameStateDto getGameStateDtoPlayerEndTurn(GameStateDto gameStateDto) {
//        return GameStateDto
//                .builder()
//
//                .playedMana(gameStateDto.isPlayedMana())
//                .currentTurnPlayerId(gameStateDto.getCurrentTurnPlayerId())
//
//                .playerHand(gameStateDto.getPlayerHand())
//                .opponentHand(gameStateDto.getOpponentHand())
//
//                .playerBattleZone(gameStateDto.getPlayerBattleZone())
//                .opponentBattleZone(gameStateDto.getOpponentBattleZone())
//
//                .shieldTriggersFlagsDto(gameStateDto.getShieldTriggersFlagsDto())
//                .shieldTriggerCard(gameStateDto.getShieldTriggerCard())
//                .build();
//    }
//
//    public static GameStateDto getGameStateDtoOpponentEndTurn(GameStateDto gameStateDto) {
//        return GameStateDto
//                .builder()
//
//                .playedMana(gameStateDto.isPlayedMana())
//                .currentTurnPlayerId(gameStateDto.getCurrentTurnPlayerId())
//
//                .playerHand(gameStateDto.getOpponentHand())
//                .opponentHand(gameStateDto.getPlayerHand())
//
//                .playerBattleZone(gameStateDto.getOpponentBattleZone())
//                .opponentBattleZone(gameStateDto.getPlayerBattleZone())
//
//                .shieldTriggersFlagsDto(gameStateDto.getShieldTriggersFlagsDto())
//                .shieldTriggerCard(gameStateDto.getShieldTriggerCard())
//                .build();
//    }
//
//
//    public static GameStateDto getGameStateDtoPlayerSummonBattleZone(GameStateDto gameStateDto) {
//        return GameStateDto
//                .builder()
//
//                .playedMana(gameStateDto.isPlayedMana())
//
//                .playerHand(gameStateDto.getPlayerHand())
//                .opponentHand(gameStateDto.getOpponentHand())
//
//                .playerBattleZone(gameStateDto.getPlayerBattleZone())
//                .opponentBattleZone(gameStateDto.getOpponentBattleZone())
//
//                .playerManaZone(gameStateDto.getPlayerManaZone())
//                .opponentManaZone(gameStateDto.getOpponentManaZone())
//
//                .shieldTriggersFlagsDto(gameStateDto.getShieldTriggersFlagsDto())
//                .shieldTriggerCard(gameStateDto.getShieldTriggerCard())
//                .build();
//    }
//
//    public static GameStateDto getGameStateDtoOpponentSummonBattleZone(GameStateDto gameStateDto) {
//        return GameStateDto
//                .builder()
//
//                .playedMana(gameStateDto.isPlayedMana())
//
//                .playerHand(gameStateDto.getOpponentHand())
//                .opponentHand(gameStateDto.getPlayerHand())
//
//                .playerBattleZone(gameStateDto.getOpponentBattleZone())
//                .opponentBattleZone(gameStateDto.getPlayerBattleZone())
//
//                .playerManaZone(gameStateDto.getOpponentManaZone())
//                .opponentManaZone(gameStateDto.getPlayerManaZone())
//
//                .shieldTriggersFlagsDto(gameStateDto.getShieldTriggersFlagsDto())
//                .shieldTriggerCard(gameStateDto.getShieldTriggerCard())
//                .build();
//    }
//
//    public static GameStateDto getGameStateDtoPlayerAttack(GameStateDto gameStateDto) {
//        return GameStateDto
//                .builder()
//
//                .shieldTriggersFlagsDto(gameStateDto.getShieldTriggersFlagsDto())
//                .shieldTriggerCard(gameStateDto.getShieldTriggerCard())
//
//                .playerHand(gameStateDto.getPlayerHand())
//                .opponentHand(gameStateDto.getOpponentHand())
//
//                .playerBattleZone(gameStateDto.getPlayerBattleZone())
//                .opponentBattleZone(gameStateDto.getOpponentBattleZone())
//
//                .playerManaZone(gameStateDto.getPlayerManaZone())
//                .opponentManaZone(gameStateDto.getOpponentManaZone())
//
//                .build();
//    }
//
//    public static GameStateDto getGameStateDtoOpponentAttack(GameStateDto gameStateDto) {
//        return GameStateDto
//                .builder()
//
//                .shieldTriggersFlagsDto(gameStateDto.getShieldTriggersFlagsDto())
//                .shieldTriggerCard(gameStateDto.getShieldTriggerCard())
//
//                .playerHand(gameStateDto.getOpponentHand())
//                .opponentHand(gameStateDto.getPlayerHand())
//
//                .playerBattleZone(gameStateDto.getOpponentBattleZone())
//                .opponentBattleZone(gameStateDto.getPlayerBattleZone())
//
//                .playerManaZone(gameStateDto.getOpponentManaZone())
//                .opponentManaZone(gameStateDto.getPlayerManaZone())
//
//                .build();
//    }

}