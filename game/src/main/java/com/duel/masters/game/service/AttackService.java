package com.duel.masters.game.service;

import com.duel.masters.game.config.unity.GameWebSocketHandler;
import com.duel.masters.game.dto.CardsDto;
import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.dto.card.service.CardDto;

public interface AttackService {
    void attack(GameStateDto currentState,
                GameStateDto incomingState,
                CardDto attackerCard,
                CardDto targetCard,
                String targetId,
                GameWebSocketHandler webSocketHandler);


    void attack(GameStateDto currentState, GameStateDto incomingState, GameWebSocketHandler webSocketHandler);

    default CardsDto getOwnCards(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {
        return cardsUpdateService.getOwnCards(currentState, incomingState);
    }

    default CardsDto getOpponentCards(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {
        return cardsUpdateService.getOpponentCards(currentState, incomingState);
    }
}
