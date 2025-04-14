package com.duel.masters.game.service;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Map;

import static com.duel.masters.game.constant.Constant.*;
import static com.duel.masters.game.util.ObjectMapperUtil.convertToGameStateDto;

@AllArgsConstructor
@Service
@Slf4j
public class GameLogicService {

    private final ActionsService actionsService;
    private final GameStateStore gameStateStore;

    public void doAction(Map<String, Object> payload) {
        var incomingState = convertToGameStateDto(payload);
        var currentState = gameStateStore.getGameState(incomingState.getGameId());

        if (currentState == null) {
            log.error("❌ No game state found for gameId: {}", incomingState.getGameId());
            return;
        }

        switch (incomingState.getAction()) {
            case END_TURN -> actionsService.endTurn(currentState, incomingState);
            case SEND_CARD_TO_MANA -> actionsService.sendCardToMana(currentState, incomingState);
            case SUMMON_TO_BATTLE_ZONE -> actionsService.summonToBattleZone(currentState, incomingState);
//            case "ATTACL" -> actionsService.attack(currentState, incomingState);
        }
    }


}
