package com.duel.masters.game.effects.summoning;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.effects.Effect;
import com.duel.masters.game.service.CardsUpdateService;

// When you put this creature into the battle zone,choose up to 2 creatures in the battle zone and return them to their owners hands

public class AquaSniperEffect implements Effect {
    @Override
    public void execute(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {

    }
}
