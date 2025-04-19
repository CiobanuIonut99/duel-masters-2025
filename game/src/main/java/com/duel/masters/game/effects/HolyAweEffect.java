package com.duel.masters.game.effects;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.service.CardsUpdateService;

import static com.duel.masters.game.util.CardsDtoUtil.playCard;
import static com.duel.masters.game.util.CardsDtoUtil.tapCards;

public class HolyAweEffect implements ShieldTriggerEffect {

    @Override
    public void execute(GameStateDto currentState,
                        GameStateDto incomingState,
                        CardsUpdateService cardsUpdateService) {

        var opponentCards = cardsUpdateService.getOpponentCards(currentState, incomingState);
        var ownCards = cardsUpdateService.getOwnCards(currentState, incomingState);

        tapCards(opponentCards.getBattleZone());
        playCard(ownCards.getShields(), currentState.getTargetId(), ownCards.getGraveyard());

    }

}
