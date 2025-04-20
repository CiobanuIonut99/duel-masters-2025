package com.duel.masters.game.effects;

import com.duel.masters.game.dto.CardsDto;
import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.service.CardsUpdateService;

public interface ShieldTriggerEffect {
    void execute(GameStateDto currentState,
                 GameStateDto incomingState,
                 CardsUpdateService cardsUpdateService);

    default CardsDto getOwnCards(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {
        return cardsUpdateService.getOwnCards(currentState, incomingState);
    }

    default CardsDto getOpponentCards(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {
        return cardsUpdateService.getOpponentCards(currentState, incomingState);
    }


}
