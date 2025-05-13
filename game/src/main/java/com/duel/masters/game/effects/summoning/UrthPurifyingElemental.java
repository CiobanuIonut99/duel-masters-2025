package com.duel.masters.game.effects.summoning;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.effects.Effect;
import com.duel.masters.game.service.CardsUpdateService;

public class UrthPurifyingElemental implements Effect {

//    At the end of each of your turns, you may untap this creature

    @Override
    public void execute(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {
        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);
        var ownBattleZone = ownCards.getBattleZone();
        ownBattleZone
                .stream()
                .filter(ownCard -> ownCard.getId().equals(2L))
                .forEach(ownCard -> ownCard.setTapped(false));
    }
}
