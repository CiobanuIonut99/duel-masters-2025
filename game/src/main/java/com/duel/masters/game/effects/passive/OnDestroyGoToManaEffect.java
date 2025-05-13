package com.duel.masters.game.effects.passive;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.effects.Effect;
import com.duel.masters.game.service.CardsUpdateService;

public class OnDestroyGoToManaEffect implements Effect {
    @Override
    public void execute(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {

        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);



    }
}
