package com.duel.masters.game.service;

import com.duel.masters.game.config.unity.GameWebSocketHandler;
import com.duel.masters.game.dto.GameStateDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@AllArgsConstructor
@Service
@Slf4j
public class ActionsService {

    private final TurnService turnService;
    private final BlockService blockService;
    private final SummonToManaService summonToManaService;
    private final CastShieldTriggerService castShieldTriggerService;
    private final SummonToBattleZoneService summonToBattleZoneService;
    private final AttackServiceImplementation attackServiceImplementation;

    public void attack(GameStateDto currentState, GameStateDto incomingState, GameWebSocketHandler webSocketHandler) {
        attackServiceImplementation.attack(currentState, incomingState, webSocketHandler);
    }

    public void block(GameStateDto currentState, GameStateDto incomingState, GameWebSocketHandler webSocketHandler) {
        blockService.block(currentState, incomingState, webSocketHandler);
    }

    public void summonCardToManaZone(GameStateDto currentState, GameStateDto incomingState, GameWebSocketHandler webSocketHandler) {
        summonToManaService.summonCardToManaZone(currentState, incomingState, webSocketHandler);
    }

    public void summonToBattleZone(GameStateDto currentState, GameStateDto incomingState, GameWebSocketHandler webSocketHandler) {
        summonToBattleZoneService.summonToBattleZone(currentState, incomingState, webSocketHandler);
    }

    public void endTurn(GameStateDto currentState, GameStateDto incomingState, GameWebSocketHandler webSocketHandler) {
        turnService.endTurn(currentState, incomingState, webSocketHandler);
    }

    public void triggerShieldTriggerLogic(GameStateDto currentState, GameStateDto incomingState, GameWebSocketHandler webSocketHandler) {
        castShieldTriggerService.triggerShieldTriggerLogic(currentState, incomingState, webSocketHandler);
    }

}
