package com.duel.masters.game.effects;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.service.CardsUpdateService;

import java.util.Collections;

import static com.duel.masters.game.util.CardsDtoUtil.*;

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

        var attackerId = currentState.getAttackerId();
        var attackerCard = getCardDtoFromList(opponentCards.getBattleZone(), attackerId);

        if (shieldTriggersFlags.isShieldTriggerDecisionMade()) {
            Collections.shuffle(opponentHand);
            var chosenCard = opponentHand
                    .stream()
                    .findFirst()
                    .orElseThrow();
            playCard(opponentHand, chosenCard.getGameCardId(), opponentGraveyard);
            playCard(ownCards.getShields(), currentState.getTargetId(), ownCards.getGraveyard());
            changeCardState(attackerCard, true, false, true, false);

        } else {
            if (opponentHand.isEmpty()) {
                playCard(ownCards.getShields(), currentState.getTriggeredGameCardId(), ownCards.getHand());
            }
            shieldTriggersFlags.setShieldTriggerDecisionMade(true);
            shieldTriggersFlags.setShieldTrigger(false);
        }
    }
}
