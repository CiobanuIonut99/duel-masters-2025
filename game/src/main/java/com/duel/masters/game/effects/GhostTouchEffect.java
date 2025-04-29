package com.duel.masters.game.effects;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.service.CardsUpdateService;

import java.util.Collections;

import static com.duel.masters.game.util.CardsDtoUtil.playCard;

public class GhostTouchEffect implements ShieldTriggerEffect {

//    Your opponent discards a card at random from his hand
// NEED TEST!

    @Override
    public void execute(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {
        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);

        var opponentCards = getOpponentCards(currentState, incomingState, cardsUpdateService);
        var opponentGraveyard = opponentCards.getGraveyard();
        var opponentHand = opponentCards.getHand();

        var shieldTriggersFlags = currentState.getShieldTriggersFlagsDto();

        if (shieldTriggersFlags.isShieldTriggerDecisionMade()) {
            Collections.shuffle(opponentHand);
            var chosenCard = opponentHand
                    .stream()
                    .findFirst()
                    .orElseThrow();
            playCard(opponentHand, chosenCard.getGameCardId(), opponentGraveyard);
        } else {
            if (opponentHand.isEmpty()) {
                playCard(ownCards.getShields(), currentState.getTriggeredGameCardId(), ownCards.getHand());
                shieldTriggersFlags.setGhostTouchMustSelectCreature(false);
            } else {
                shieldTriggersFlags.setGhostTouchMustSelectCreature(true);
            }
            shieldTriggersFlags.setShieldTriggerDecisionMade(true);
            shieldTriggersFlags.setShieldTrigger(false);
        }
    }
}
