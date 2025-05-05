package com.duel.masters.game.effects.triggers;

import com.duel.masters.game.dto.GameStateDto;
import com.duel.masters.game.effects.ShieldTriggerEffect;
import com.duel.masters.game.service.CardsUpdateService;

import java.util.Collections;

import static com.duel.masters.game.util.CardsDtoUtil.*;

public class CrystalMemoryEffect implements ShieldTriggerEffect {

//    Search your deck, you may take a card from your deck and put it in your hand, then shuffle your deck

    @Override
    public void execute(GameStateDto currentState, GameStateDto incomingState, CardsUpdateService cardsUpdateService) {

        var opponentCards = getOpponentCards(currentState, incomingState, cardsUpdateService);
        var ownCards = getOwnCards(currentState, incomingState, cardsUpdateService);

        var attackerId = currentState.getAttackerId();
        var attackerCard = getCardDtoFromList(opponentCards.getBattleZone(), attackerId);

        if (currentState.getShieldTriggersFlagsDto().isShieldTriggerDecisionMade()) {

            var cardsChosenFromDeck = incomingState
                    .getShieldTriggersFlagsDto()
                    .getCardsChosen()
                    .stream()
                    .map(idChosenFromDeck -> getCardDtoFromList(ownCards.getDeck(), idChosenFromDeck))
                    .toList();

            cardsChosenFromDeck
                    .forEach(card -> playCard(ownCards.getDeck(), card.getGameCardId(), ownCards.getHand()));

            playCard(ownCards.getShields(), currentState.getTargetId(), ownCards.getGraveyard());

            currentState.getShieldTriggersFlagsDto().setCrystalMemoryMustDrawCard(false);
            currentState.getShieldTriggersFlagsDto().setShieldTriggerDecisionMade(false);

            changeCardState(attackerCard, true, false, true, false);

            Collections.shuffle(ownCards.getDeck());

        } else {

            currentState.getShieldTriggersFlagsDto().setCrystalMemoryMustDrawCard(true);
            currentState.getShieldTriggersFlagsDto().setShieldTriggerDecisionMade(true);

        }
    }
}
