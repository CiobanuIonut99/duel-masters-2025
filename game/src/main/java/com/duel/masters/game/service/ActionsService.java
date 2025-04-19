package com.duel.masters.game.service;

import com.duel.masters.game.dto.GameStateDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@AllArgsConstructor
@Service
@Slf4j
public class ActionsService {

    private final TurnService turnService;
    private final AttackService attackService;
    private final BlockService blockService;
    private final SummonToManaService summonToManaService;
    private final SummonToBattleZoneService summonToBattleZoneService;
    private final CastShieldTriggerService castShieldTriggerService;

    public void attack(GameStateDto currentState, GameStateDto incomingState) {
        attackService.attack(currentState, incomingState);
    }

    public void block(GameStateDto currentState, GameStateDto incomingState) {
        blockService.block(currentState, incomingState);
    }

    public void summonCardToManaZone(GameStateDto currentState, GameStateDto incomingState) {
        summonToManaService.summonCardToManaZone(currentState, incomingState);
    }

    public void summonToBattleZone(GameStateDto currentState, GameStateDto incomingState) {
        summonToBattleZoneService.summonToBattleZone(currentState, incomingState);
    }

    public void endTurn(GameStateDto currentState, GameStateDto incomingState) {
        turnService.endTurn(currentState, incomingState);
    }

    public void triggerShieldTriggerLogic(GameStateDto currentState, GameStateDto incomingState) {
        castShieldTriggerService.triggerShieldTriggerLogic(currentState, incomingState);
    }

}
