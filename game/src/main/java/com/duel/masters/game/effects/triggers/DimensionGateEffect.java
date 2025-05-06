package com.duel.masters.game.effects.triggers;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.effects.ShieldTriggerEffect;
import com.duel.masters.game.service.CardsUpdateService;

import static com.duel.masters.game.util.CardsDtoUtil.*;

public class DimensionGateEffect implements ShieldTriggerEffect {

//    Search your deck. You may take a creature from your deck, show that creature to your opponent, and put it into your hand. Then shuffle your deck.

    @Override
    public void execute(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {
        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);
        var ownDeck = ownCards.getDeck();

        var opponentCards = getOpponentCards(currentState, incomingState, cardsUpdateService);

        var shieldTriggersFlags = currentState.getShieldTriggersFlagsDto();

        var attackerId = currentState.getAttackerId();
        var attackerCard = getCardDtoFromList(opponentCards.getBattleZone(), attackerId);

        if (shieldTriggersFlags.isShieldTriggerDecisionMade()) {
            var cardsChosenFromDeck = incomingState
                    .getShieldTriggersFlagsDto()
                    .getCardsChosen()
                    .stream()
                    .map(idChosenFromDeck -> getCardDtoFromList(ownDeck, idChosenFromDeck))
                    .toList();

            shieldTriggersFlags.setLastSelectedCreatureFromDeck(getCardDtoFromList(ownDeck, cardsChosenFromDeck.getFirst().getGameCardId()));
            cardsChosenFromDeck
                    .forEach(card -> playCard(ownDeck, card.getGameCardId(), ownCards.getHand()));

            playCard(ownCards.getShields(), currentState.getTargetId(), ownCards.getGraveyard());
            currentState.getShieldTriggersFlagsDto().setShieldTriggerDecisionMade(false);
            shieldTriggersFlags.setDimensionGateMustDrawCard(false);

            changeCardState(attackerCard, true, false, true, false);
        } else {
            var playerCreatureDeck = shieldTriggersFlags.getPlayerCreatureDeck();
            playerCreatureDeck.clear();
            ownDeck
                    .stream()
                    .filter(ownCard -> ownCard.getType().equalsIgnoreCase("CREATURE"))
                    .forEach(playerCreatureDeck::add);

            shieldTriggersFlags.setDimensionGateMustDrawCard(true);
            shieldTriggersFlags.setShieldTriggerDecisionMade(true);
            shieldTriggersFlags.setShieldTrigger(false);
        }
    }
}
