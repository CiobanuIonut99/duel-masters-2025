package com.duel.masters.game.effects;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.service.CardsUpdateService;

import static com.duel.masters.game.util.CardsDtoUtil.*;

public class BrainSerumEffect implements ShieldTriggerEffect {

//    Draw up to 2 cards

    @Override
    public void execute(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {

        var opponentCards = getOpponentCards(currentState, incomingState, cardsUpdateService);
        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);
        var ownDeck = ownCards.getDeck();
        var ownHand = ownCards.getHand();

        var attackerId = currentState.getAttackerId();
        var attackerCard = getCardDtoFromList(opponentCards.getBattleZone(), attackerId);

        var shieldTriggersFlags = currentState.getShieldTriggersFlagsDto();

        if (shieldTriggersFlags.isShieldTriggerDecisionMade()) {
            for (int i = 0; i < incomingState.getShieldTriggersFlagsDto().getCardsDrawn(); i++) {
                var cardDrawnId = ownDeck.getLast().getGameCardId();
                playCard(ownDeck, cardDrawnId, ownHand);
            }

            playCard(ownCards.getShields(), currentState.getTargetId(), ownCards.getGraveyard());

            shieldTriggersFlags.setBrainSerumMustDrawCards(false);
            shieldTriggersFlags.setShieldTriggerDecisionMade(false);

            changeCardState(attackerCard, true, false, true, false);
        } else {
            shieldTriggersFlags.setBrainSerumMustDrawCards(true);
            shieldTriggersFlags.setShieldTriggerDecisionMade(true);
            shieldTriggersFlags.setShieldTrigger(false);
        }
    }
}
