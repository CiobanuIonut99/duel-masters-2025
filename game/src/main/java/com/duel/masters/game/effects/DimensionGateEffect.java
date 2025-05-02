package com.duel.masters.game.effects;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.service.CardsUpdateService;

import static com.duel.masters.game.util.CardsDtoUtil.playCard;

public class DimensionGateEffect implements ShieldTriggerEffect {

//    Search your deck. You may take a creature from your deck, show that creature to your opponent, and put it into your hand. Then shuffle your deck.

    @Override
    public void execute(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {
        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);
        var ownDeck = ownCards.getDeck();

        var shieldTriggersFlags = currentState.getShieldTriggersFlagsDto();

        if (shieldTriggersFlags.isShieldTriggerDecisionMade()) {
            ownDeck
                    .stream()
                    .filter(ownCard -> ownCard.getType().equalsIgnoreCase("CREATURE") && ownCard.getGameCardId().equalsIgnoreCase(incomingState.getTriggeredGameCardId()))
                    .forEach(ownCard ->
                            playCard(ownDeck, ownCard.getGameCardId(), ownCards.getHand()));
            playCard(ownCards.getShields(), currentState.getTargetId(), ownCards.getGraveyard());
            currentState.getShieldTriggersFlagsDto().setShieldTriggerDecisionMade(false);

        } else {
            shieldTriggersFlags.setDimensionGateMustDrawCard(true);
            shieldTriggersFlags.setShieldTriggerDecisionMade(true);
            shieldTriggersFlags.setShieldTrigger(false);
        }
    }
}
