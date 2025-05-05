package com.duel.masters.game.effects.triggers;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.effects.ShieldTriggerEffect;
import com.duel.masters.game.service.CardsUpdateService;

import static com.duel.masters.game.util.CardsDtoUtil.playCard;
import static com.duel.masters.game.util.CardsDtoUtil.tapCards;

public class HolyAweEffect implements ShieldTriggerEffect {

//    Tap all your opponnents creatures in the battle zone

    @Override
    public void execute(GameStateDto currentState,
                        GameStateDto incomingState,
                        CardsUpdateService cardsUpdateService) {

        var opponentCards = getOpponentCards(currentState, incomingState, cardsUpdateService);
        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);

        tapCards(opponentCards.getBattleZone());
        playCard(ownCards.getShields(), currentState.getTargetId(), ownCards.getGraveyard());

    }

}
