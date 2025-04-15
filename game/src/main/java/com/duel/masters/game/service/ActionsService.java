package com.duel.masters.game.service;

import com.duel.masters.game.dto.GameStateDto;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@AllArgsConstructor
@Service
@Slf4j
public class ActionsService {

    private final TopicService topicService;
    private final SpecificActionsService specificActionsService;

    public void endTurn(GameStateDto currentState, GameStateDto incomingState) {
        specificActionsService.prepareTurnForOpponent(currentState, incomingState);
        topicService.sendGameStatesToTopics(currentState);
    }

    public void sendCardToMana(GameStateDto currentState, GameStateDto incomingState) {
        specificActionsService.setCardToSendInManaZone(currentState, incomingState);
        topicService.sendGameStatesToTopics(currentState);
        log.info("Mana card played");
    }

    public void summonToBattleZone(GameStateDto currentState, GameStateDto incomingState) {
        specificActionsService.setCardSummonable(currentState, incomingState);
    }

    public void attack(GameStateDto currentState, GameStateDto incomingState) {
        specificActionsService.doAttack(currentState, incomingState);
    }
}
