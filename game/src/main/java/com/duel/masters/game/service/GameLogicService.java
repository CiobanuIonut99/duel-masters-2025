package com.duel.masters.game.service;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Map;

import static com.duel.masters.game.util.ObjectMapperUtil.convertToGameStateDto;

@AllArgsConstructor
@Service
@Slf4j
public class GameLogicService {


    private final ActionsService actionsService;
    private final GameStateStore gameStateStore;


    public void doAction(Map<String, Object> payload) {
        var incomingDto = convertToGameStateDto(payload);
        var currentState = gameStateStore.getGameState(incomingDto.getGameId());

        if (currentState == null) {
            log.error("❌ No game state found for gameId: {}", incomingDto.getGameId());
            return;
        }

        boolean isPlayer = currentState.getPlayerId().equals(incomingDto.getPlayerId());
        var hand = isPlayer ? currentState.getPlayerHand() : currentState.getOpponentHand();
        var manaZone = isPlayer ? currentState.getPlayerManaZone() : currentState.getOpponentManaZone();
//        var deck = isPlayer ? currentState.getPlayerDeck() : currentState.getOpponentDeck();
//        var graveyard = isPlayer ? currentState.getPlayerGraveyard() : currentState.getOpponentGraveyard();
//        var battleZone = isPlayer ? currentState.getPlayerBattleZone() : currentState.getOpponentBattleZone();

        switch (incomingDto.getAction()) {
            case "SEND_CARD_TO_MANA" -> {
                actionsService.sendCardToMana(currentState, hand, incomingDto, manaZone);
            }
            case "END_TURN" -> {
                actionsService.endTurn(currentState, incomingDto);
            }
        }
    }


}
