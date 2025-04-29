package com.duel.masters.game.service;

import com.duel.masters.game.dto.GameStateDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import static com.duel.masters.game.constant.Constant.*;

@AllArgsConstructor
@Service
@Slf4j
public class GameLogicService {

    private final ActionsService actionsService;
    private final GameStateStore gameStateStore;

    public void act(GameStateDto incomingState) {
        var currentState = gameStateStore.getGameState(incomingState.getGameId());

        if (currentState == null) {
            log.error("❌ No game state found for gameId: {}", incomingState.getGameId());
            return;
        }

        switch (incomingState.getAction()) {
            case START -> actionsService.startGame(incomingState.getPlayerDto());
            case BLOCK -> actionsService.block(currentState, incomingState);
            case ATTACK -> actionsService.attack(currentState, incomingState);
            case END_TURN -> actionsService.endTurn(currentState, incomingState);
            case SEND_CARD_TO_MANA -> actionsService.summonCardToManaZone(currentState, incomingState);
            case SUMMON_TO_BATTLE_ZONE -> actionsService.summonToBattleZone(currentState, incomingState);
            case CAST_SHIELD_TRIGGER -> actionsService.triggerShieldTriggerLogic(currentState, incomingState);
        }
    }


}
